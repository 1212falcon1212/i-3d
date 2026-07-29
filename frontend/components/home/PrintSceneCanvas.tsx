"use client";

import { useMemo, useRef } from "react";
import { Canvas, useFrame } from "@react-three/fiber";
import * as THREE from "three";

/**
 * Hero'daki 3D sahne: bir baskı katman katman oluşur, sonra yavaşça döner.
 *
 * Geometri prosedürel — henüz gerçek .glb dosyamız yok. Model dosyaları
 * hazırlandığında bu bileşenin içindeki `PrintedObject` değiştirilir, sahnenin
 * geri kalanı (tabla, nozul, ışık, kamera) aynı kalır.
 *
 * Performans: render döngüsü yalnızca sahne görünürken çalışır (bkz. PrintScene),
 * mobilde ve reduced-motion'da bu dosya hiç indirilmez.
 */

const ORANGE = "#ff6b2c";
const AMBER = "#ffc53d";
const TEAL = "#12b5a5";
const NAVY = "#141a26";
const PLATE = "#20293b";

const LAYERS = 54;
const LAYER_H = 0.075;
const PRINT_SECONDS = 4.2;

/** Vazo siluetı: yüksekliğe göre yarıçap. */
function radiusAt(t: number) {
  return 0.62 + 0.34 * Math.sin(t * Math.PI * 1.15) - 0.18 * t;
}

function PrintedObject({ started }: { started: number }) {
  const group = useRef<THREE.Group>(null);
  const nozzle = useRef<THREE.Group>(null);

  // Katmanlar tek bir InstancedMesh'te: 54 ayrı mesh yerine tek draw call.
  const geometry = useMemo(
    () => new THREE.CylinderGeometry(1, 1, LAYER_H, 48, 1, true),
    []
  );
  const material = useMemo(
    () =>
      new THREE.MeshStandardMaterial({
        // Beyaz taban: renk instanceColor'dan geliyor. Turuncu taban ile
        // çarpılınca gradyan koyu kırmızıya düşüp okunmaz oluyordu.
        color: "#ffffff",
        roughness: 0.42,
        metalness: 0.05,
        side: THREE.DoubleSide,
      }),
    []
  );

  const dummy = useMemo(() => new THREE.Object3D(), []);
  const mesh = useRef<THREE.InstancedMesh>(null);
  const colors = useMemo(() => {
    const arr = new Float32Array(LAYERS * 3);
    const a = new THREE.Color(ORANGE);
    const b = new THREE.Color(AMBER);
    const c = new THREE.Color(TEAL);
    for (let i = 0; i < LAYERS; i++) {
      const t = i / (LAYERS - 1);
      // Alt üçte bir turuncu → sarı, üst kısımda turkuaza doğru bir kayma:
      // tek renk filamentin ısıyla değişen tonu gibi okunuyor.
      const col = t < 0.55 ? a.clone().lerp(b, t / 0.55) : b.clone().lerp(c, (t - 0.55) / 0.45);
      arr.set([col.r, col.g, col.b], i * 3);
    }
    return arr;
  }, []);

  // İlerleme bilerek state değil ref: her karede setState çağırmak saniyede
  // 60 React render'ı demek olurdu.
  useFrame((state) => {
    const elapsed = state.clock.elapsedTime - started;
    const p = Math.min(1, Math.max(0, elapsed / PRINT_SECONDS));

    const visible = Math.floor(p * LAYERS);
    if (mesh.current) {
      for (let i = 0; i < LAYERS; i++) {
        const t = i / (LAYERS - 1);
        const r = radiusAt(t);
        const shown = i < visible;
        // Yeni inen katman hafifçe oturuyormuş gibi: ölçek 0'dan 1'e.
        const grow = i === visible ? (p * LAYERS) % 1 : shown ? 1 : 0;
        dummy.position.set(0, i * LAYER_H + LAYER_H / 2, 0);
        dummy.rotation.y = t * Math.PI * 0.9; // hafif burgu
        dummy.scale.set(r * grow, 1, r * grow);
        dummy.updateMatrix();
        mesh.current.setMatrixAt(i, dummy.matrix);
      }
      mesh.current.instanceMatrix.needsUpdate = true;
    }

    // Nozul: basılan katmanın hemen üstünde daire çizerek ilerler,
    // baskı bitince yukarı çekilir.
    if (nozzle.current) {
      const done = p >= 1;
      const a = state.clock.elapsedTime * 2.4;
      const r = radiusAt(Math.min(0.999, p));
      nozzle.current.position.set(
        done ? 0 : Math.cos(a) * r,
        done ? LAYERS * LAYER_H + 1.2 : p * LAYERS * LAYER_H + 0.42,
        done ? 0 : Math.sin(a) * r
      );
    }

    // Baskı bitince yavaş dönüş.
    if (group.current) {
      group.current.rotation.y =
        p < 1 ? -0.2 : -0.2 + (state.clock.elapsedTime - started - PRINT_SECONDS) * 0.22;
    }
  });

  return (
    <group ref={group} position={[0, -1.05, 0]}>
      <instancedMesh
        ref={mesh}
        args={[geometry, material, LAYERS]}
        castShadow
        receiveShadow
      >
        <instancedBufferAttribute attach="instanceColor" args={[colors, 3]} />
      </instancedMesh>

      <group ref={nozzle}>
        <mesh position={[0, 0.34, 0]} castShadow>
          <boxGeometry args={[0.34, 0.42, 0.34]} />
          <meshStandardMaterial color={NAVY} roughness={0.35} metalness={0.6} />
        </mesh>
        <mesh position={[0, 0.03, 0]} castShadow>
          <coneGeometry args={[0.16, 0.28, 16]} />
          <meshStandardMaterial color="#8a8f9c" roughness={0.25} metalness={0.85} />
        </mesh>
      </group>
    </group>
  );
}

/** Baskı tablası: ızgaralı koyu yüzey. */
function BuildPlate() {
  return (
    <group position={[0, -1.1, 0]}>
      <mesh rotation={[-Math.PI / 2, 0, 0]} receiveShadow>
        <planeGeometry args={[9, 9]} />
        <meshStandardMaterial color={PLATE} roughness={0.9} metalness={0.1} />
      </mesh>
      <gridHelper args={[9, 18, ORANGE, "#3a4560"]} position={[0, 0.01, 0]} />
    </group>
  );
}

function Rig({ children }: { children: React.ReactNode }) {
  const group = useRef<THREE.Group>(null);
  useFrame((state) => {
    if (!group.current) return;
    // İmleç takibi — çok hafif, baş döndürmeyecek kadar.
    const { x, y } = state.pointer;
    group.current.rotation.y += (x * 0.22 - group.current.rotation.y) * 0.04;
    group.current.rotation.x += (-y * 0.1 - group.current.rotation.x) * 0.04;
  });
  return <group ref={group}>{children}</group>;
}

export default function PrintSceneCanvas({ paused }: { paused: boolean }) {
  return (
    <Canvas
      frameloop={paused ? "never" : "always"}
      shadows
      dpr={[1, 1.8]}
      camera={{ position: [7.4, 5.2, 8.6], fov: 34 }}
      gl={{
        antialias: true,
        powerPreference: "high-performance",
        // ACES tone mapping marka renklerini soluklaştırıyordu.
        toneMapping: THREE.NoToneMapping,
      }}
    >
      <color attach="background" args={[NAVY]} />
      <fog attach="fog" args={[NAVY, 14, 30]} />

      <ambientLight intensity={0.9} />
      <directionalLight
        position={[5, 9, 5]}
        intensity={2.6}
        castShadow
        shadow-mapSize={[1024, 1024]}
      />
      {/* Arkadan turkuaz kenar ışığı: nesnenin silueti koyu zeminden ayrılsın */}
      <pointLight position={[-5, 3.5, -4]} intensity={70} color={TEAL} distance={18} />
      <pointLight position={[4, 2, 4]} intensity={45} color={ORANGE} distance={14} />

      {/* Sahne sağa kaydırılmış: hero metni solda nefes alsın. */}
      <group position={[1.6, -0.5, 0]} scale={1.18}>
        <Rig>
          <BuildPlate />
          <PrintedObject started={0} />
        </Rig>
      </group>
    </Canvas>
  );
}
