"use client";

import { useEffect, useMemo, useRef } from "react";
import { Canvas, useFrame } from "@react-three/fiber";
import * as THREE from "three";
import type { Pt } from "@/lib/print-shapes";

/**
 * Hero'nun 3D sahnesi: seçilen figür, seçilen renkle katman katman basılır.
 *
 * Neden bu mimari:
 *
 * - **Figür ayakta, açılış bir klip düzlemiyle.** Katmanları ayrı ayrı mesh
 *   yapmak (ya da InstancedMesh'e koymak) bir siluet için işe yaramıyor: dairesel
 *   kesitli vazoda her katman ölçeklenmiş bir daireydi, ama bir dinozorun her
 *   katmanı siluetin farklı bir YATAY DİLİMİ — bacaklar gibi kopuk parçalar dahil.
 *   Tek `ExtrudeGeometry` + dünya uzayında yükselen bir klip düzlemi bunu bedavaya
 *   çözüyor: tek geometri, tek draw call, kare başına matris yazımı yok.
 *
 * - **Klip düzlemi katman yüksekliğine yuvarlanıyor.** Düzgün bir silme "baskı"
 *   değil "perde" gibi okunuyordu. Basamaklı olunca katmanlar sayılabiliyor —
 *   `globals.css`'teki `.layer-print`'in `steps()` kullanmasıyla aynı gerekçe.
 *
 * - **Nozul, o katmanın GERÇEK genişliğinde geziniyor.** `spans` her katman için
 *   siluetin en sol/en sağ x'ini tutuyor; uç ince kuyrukta kısa, geniş karında
 *   uzun yol alıyor. Baskı hissini veren asıl ayrıntı bu, ve bir silme efekti
 *   bunu taklit edemez.
 *
 * - **İlerleme birikimli `delta` ile, `clock.elapsedTime` ile DEĞİL.** R3F
 *   `setFrameloop` içinde `clock.stop()`/`start()` çağırıyor
 *   (events-b389eeca.esm.js:1091) ve `THREE.Clock.start()` `elapsedTime`'ı
 *   sıfırlıyor. Görünürlük duraklatması her tetiklendiğinde baskı baştan
 *   başlıyordu; kullanıcı seçimi de aynı değeri sıfırlayınca iki kaynak
 *   birbiriyle kavga ederdi.
 *
 * - **Işıklar nötr, tone mapping kapalı.** Renkli dolgu ışıkları nesneyi
 *   çocuğun seçtiği swatch'tan başka bir tona kaydırıyordu; seçim yalan olurdu.
 *   ACES ise katalog renklerini soluklaştırıyor, o yüzden `NoToneMapping`.
 *
 * - **Sahnenin kendi zemini var, sayfa kremi değil.** Krem üstünde Kar Beyazı ve
 *   Şeffaf filamentler kayboluyordu. Serin bir sahne tonu (`--color-stage`) hem
 *   bunu çözüyor hem sayfadaki sıcak turuncu yığınını kırıyor. Kabın CSS'i aynı
 *   değeri kullanıyor: WebGL yüklenirken ya da hiç yüklenmediğinde geçiş flaşı
 *   olmuyor.
 *
 * - **`preserveDrawingBuffer` şart.** Baskı bitince render döngüsünü durduruyoruz;
 *   bu bayrak olmadan çizim tamponu boşalıp hero boş bir kutuya dönüşüyor.
 */

const LAYERS = 54;
/** Siluet normalize (x ∈ [-1,1]); sahnede bu kadar büyütülüyor. */
const S = 1.5;
const DEPTH = 0.45;
const PRINT_SECONDS = 3.2;
/** Baskı bitince kaç saniye sonra render döngüsü uyusun. */
const SLEEP_AFTER = 1.5;
/** Tablanın dünya y'si — klip düzlemi dünya uzayında çalışıyor, sabit şart. */
const GROUND_Y = -1.35;

const INK = "#141a26";
const PLATE = "#e3d3ba";
const PLATE_LINE = "#c2ad8c";
/** globals.css'teki --color-stage ile aynı değer; kabın CSS'i de bunu kullanıyor. */
const STAGE = "#e9f3fb";

/** Verilen yükseklikte siluetin en sol ve en sağ x'i. */
function spanAt(pts: readonly THREE.Vector2[], y: number): [number, number] {
  let lo = Infinity;
  let hi = -Infinity;
  for (let i = 0; i < pts.length; i++) {
    const a = pts[i];
    const b = pts[(i + 1) % pts.length];
    // Kenar bu yüksekliği kesmiyorsa atla.
    if ((a.y - y) * (b.y - y) > 0) continue;
    const dy = b.y - a.y;
    const x = Math.abs(dy) < 1e-6 ? a.x : a.x + (b.x - a.x) * ((y - a.y) / dy);
    if (x < lo) lo = x;
    if (x > hi) hi = x;
  }
  return lo === Infinity ? [0, 0] : [lo, hi];
}

interface Figure {
  geo: THREE.ExtrudeGeometry;
  height: number;
  layerH: number;
  spans: [number, number][];
}

function buildFigure(points: readonly Pt[]): Figure {
  const shape = new THREE.Shape(
    points.map(([x, y]) => new THREE.Vector2(x * S, y * S))
  );
  const geo = new THREE.ExtrudeGeometry(shape, {
    depth: DEPTH,
    bevelEnabled: false,
    steps: 1,
    curveSegments: 1,
  });
  geo.computeBoundingBox();
  const bb = geo.boundingBox!;
  const cx = (bb.min.x + bb.max.x) / 2;
  const minY = bb.min.y;
  // Taban tam y=0'a otursun, x ve z ortalı olsun: klip düzlemi ve tabla
  // hizası buna bağlı.
  geo.translate(-cx, -minY, -DEPTH / 2);
  geo.computeVertexNormals();

  const height = bb.max.y - bb.min.y;
  const layerH = height / LAYERS;

  // Aynı dönüşümü uygulanmış noktalar üzerinden katman açıklıkları.
  const pts = points.map(
    ([x, y]) => new THREE.Vector2(x * S - cx, y * S - minY)
  );
  const spans = Array.from({ length: LAYERS }, (_, i) =>
    spanAt(pts, ((i + 0.5) / LAYERS) * height)
  );

  return { geo, height, layerH, spans };
}

/** Yumuşak temas gölgesi dokusu — drei ContactShadows olmadığı için elde. */
function makeShadowTexture(): THREE.Texture {
  const c = document.createElement("canvas");
  c.width = 128;
  c.height = 128;
  const g = c.getContext("2d")!;
  const rg = g.createRadialGradient(64, 64, 0, 64, 64, 64);
  // Gri değil kobalt: aydınlık krem zeminde gölge ölü değil canlı duruyor.
  rg.addColorStop(0, "rgba(31,58,147,0.38)");
  rg.addColorStop(0.6, "rgba(31,58,147,0.12)");
  rg.addColorStop(1, "rgba(31,58,147,0)");
  g.fillStyle = rg;
  g.fillRect(0, 0, 128, 128);
  const t = new THREE.CanvasTexture(c);
  t.colorSpace = THREE.SRGBColorSpace;
  return t;
}

interface StageProps {
  points: readonly Pt[];
  colorHex: string;
  /** Şekil değişince baskı baştan başlar. Renk değişimi baskıyı SIFIRLAMAZ. */
  printKey: string;
  onSettled: () => void;
}

function Stage({ points, colorHex, printKey, onSettled }: StageProps) {
  const clip = useMemo(
    () => new THREE.Plane(new THREE.Vector3(0, -1, 0), GROUND_Y),
    []
  );

  const figure = useMemo(() => buildFigure(points), [points]);
  useEffect(() => () => figure.geo.dispose(), [figure]);

  const bodyMat = useMemo(
    () =>
      new THREE.MeshStandardMaterial({
        color: colorHex,
        roughness: 0.55,
        metalness: 0,
        flatShading: true,
        clippingPlanes: [clip],
      }),
    // Renk aşağıdaki effect ile güncelleniyor; materyal yeniden kurulmuyor.
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [clip]
  );
  /**
   * Sert offset gölge — kontur yerine bu.
   *
   * Önce geometriyi merkezden büyütüp `BackSide` çizerek kontur denedim: kalınlık
   * merkezden uzaklıkla arttığı için düzensiz çıkıyordu, bir kenarda kalın bir
   * bant, başka kenarda hiç yok. Aynı geometriyi mürekkep renginde sağ-aşağı
   * kaydırmak hem tanım gereği eşit kalınlıkta, hem de sayfadaki her kartın
   * `shadow-toy`'uyla (0 4px 0 0) birebir aynı dili konuşuyor.
   */
  const shadeMat = useMemo(
    () =>
      new THREE.MeshBasicMaterial({
        color: INK,
        clippingPlanes: [clip],
      }),
    [clip]
  );
  useEffect(
    () => () => {
      bodyMat.dispose();
      shadeMat.dispose();
    },
    [bodyMat, shadeMat]
  );

  // Renk değişimi anında uygulanıyor ve baskıyı yeniden başlatmıyor: çocuk
  // swatch'lara hızla basınca baskı hiç bitmez ve nesne hiç görünmez olurdu.
  // Şekil değişmek baskıyı gerektiriyor, renk değişmek gerektirmiyor.
  useEffect(() => {
    bodyMat.color.set(colorHex);
  }, [bodyMat, colorHex]);

  const nozzle = useRef<THREE.Group>(null);
  const shadow = useRef<THREE.Mesh>(null);

  const p = useRef(0);
  const idle = useRef(0);
  const settled = useRef(false);

  // printKey değişince baskıyı sıfırla. Render sırasında ref karşılaştırması:
  // effect'e bırakmak bir kare eski ilerlemeyi gösterirdi.
  const lastKey = useRef(printKey);
  if (lastKey.current !== printKey) {
    lastKey.current = printKey;
    p.current = 0;
    idle.current = 0;
    settled.current = false;
  }

  useFrame((state, delta) => {
    // Sekme arka plandan dönerken biriken büyük delta ilerlemeyi sıçratmasın.
    const d = Math.min(delta, 1 / 30);
    p.current = Math.min(1, p.current + d / PRINT_SECONDS);

    const done = Math.floor(p.current * LAYERS);
    clip.constant =
      GROUND_Y + Math.min(done * figure.layerH, figure.height);

    if (nozzle.current) {
      const printing = p.current < 1;
      const [lo, hi] = figure.spans[Math.min(done, LAYERS - 1)];
      // Uç, o katmanın açıklığı boyunca gidip geliyor.
      const sweep = (Math.sin(state.clock.elapsedTime * 6.5) + 1) / 2;
      // Konum GRUBA GÖRE yerel: grup zaten GROUND_Y'de duruyor, buraya bir daha
      // eklemek nozulu tablanın altına gömüyordu.
      nozzle.current.position.set(
        printing ? lo + (hi - lo) * sweep : 0,
        printing ? done * figure.layerH : figure.height + 0.7,
        0
      );
      nozzle.current.visible = printing;
    }

    // Gölge, basılan yüksekliğe göre hafifçe koyulaşıyor.
    if (shadow.current) {
      const m = shadow.current.material as THREE.MeshBasicMaterial;
      m.opacity = 0.35 + 0.65 * p.current;
    }

    // Baskı bitti ve bir süre geçtiyse döngüyü uyut.
    if (p.current >= 1 && !settled.current) {
      idle.current += d;
      if (idle.current >= SLEEP_AFTER) {
        settled.current = true;
        onSettled();
      }
    }
  });

  const shadowTex = useMemo(makeShadowTexture, []);
  useEffect(() => () => shadowTex.dispose(), [shadowTex]);

  return (
    <group position={[0, GROUND_Y, 0]}>
      {/* Tabla: aydınlık ama krem zeminden ayrılan orta ton. Ölçü bilerek küçük —
          büyük bir düzlem kareyi kaplayıp figürü ezmişti. Izgara, yüzeyin bir
          baskı tablası olduğunu okutan asıl ipucu. */}
      <mesh rotation={[-Math.PI / 2, 0, 0]}>
        <planeGeometry args={[7, 7]} />
        <meshStandardMaterial color={PLATE} roughness={0.95} metalness={0} />
      </mesh>
      <gridHelper
        args={[7, 14, PLATE_LINE, PLATE_LINE]}
        position={[0, 0.004, 0]}
      />

      <mesh ref={shadow} rotation={[-Math.PI / 2, 0, 0]} position={[0, 0.006, 0]}>
        <planeGeometry args={[4.4, 2.6]} />
        <meshBasicMaterial map={shadowTex} transparent depthWrite={false} />
      </mesh>

      {/* dispose={null}: geometri bizde tutuluyor, R3F ayrılırken atmasın. */}
      <mesh
        geometry={figure.geo}
        material={shadeMat}
        position={[0.06, -0.08, -0.06]}
        dispose={null}
        renderOrder={-1}
      />
      <mesh geometry={figure.geo} material={bodyMat} dispose={null} />

      <group ref={nozzle}>
        <mesh position={[0, 0.4, 0]}>
          <boxGeometry args={[0.24, 0.3, 0.24]} />
          <meshStandardMaterial color={INK} roughness={0.35} metalness={0.55} />
        </mesh>
        <mesh position={[0, 0.16, 0]}>
          <coneGeometry args={[0.1, 0.19, 14]} />
          <meshStandardMaterial color="#8a8f9c" roughness={0.25} metalness={0.8} />
        </mesh>
      </group>
    </group>
  );
}

interface PrintSceneCanvasProps {
  paused: boolean;
  points: readonly Pt[];
  colorHex: string;
  printKey: string;
  onSettled: () => void;
}

export default function PrintSceneCanvas({
  paused,
  points,
  colorHex,
  printKey,
  onSettled,
}: PrintSceneCanvasProps) {
  return (
    <Canvas
      frameloop={paused ? "never" : "always"}
      dpr={[1, 1.6]}
      camera={{ position: [1.75, 0.85, 5.5], fov: 34 }}
      gl={{
        antialias: true,
        // Klip düzlemi materyal seviyesinde çalışıyor; bu bayrak şart.
        localClippingEnabled: true,
        // ACES tone mapping katalog renklerini soluklaştırıyordu.
        toneMapping: THREE.NoToneMapping,
        // Baskı bitince render döngüsünü durduruyoruz (bkz. PrintStudio). Bu
        // olmadan çizim tamponu bir daha çizilmediği anda boşalabiliyor ve hero
        // boş bir kutuya dönüşüyor — doğrulamada tam bu yaşandı.
        preserveDrawingBuffer: true,
      }}
    >
      <color attach="background" args={[STAGE]} />

      {/* Nötr ışık: seçilen renk swatch'takiyle aynı görünmeli. Renkli dolgu
          ışıkları nesneyi çocuğun seçtiği tondan kaydırıyordu. */}
      <hemisphereLight args={["#ffffff", PLATE, 0.8]} />
      <ambientLight intensity={0.35} />
      <directionalLight position={[4, 7, 6]} intensity={1.3} />

      <Stage
        points={points}
        colorHex={colorHex}
        printKey={printKey}
        onSettled={onSettled}
      />
    </Canvas>
  );
}
