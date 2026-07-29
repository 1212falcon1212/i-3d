"use client";

import dynamic from "next/dynamic";
import { useEffect, useRef, useState } from "react";

/**
 * WebGL sahnesinin yükleme kapısı.
 *
 * Sahne YALNIZCA şu koşullarda indirilir:
 *   - ekran ≥ 768px (mobilde three.js paketi hiç inmesin)
 *   - kullanıcı prefers-reduced-motion demiyorsa
 *   - tarayıcıda WebGL varsa
 * Aksi halde aynı kadrajın statik posteri gösterilir.
 *
 * Ayrıca sahne görünür alandan çıkınca render döngüsü durur; arka planda
 * boşuna GPU harcamaz.
 */

const PrintSceneCanvas = dynamic(() => import("./PrintSceneCanvas"), {
  ssr: false,
  loading: () => <Poster />,
});

function supportsWebGL() {
  try {
    const canvas = document.createElement("canvas");
    return !!(
      window.WebGLRenderingContext &&
      (canvas.getContext("webgl") || canvas.getContext("experimental-webgl"))
    );
  } catch {
    return false;
  }
}

/** Sahnenin statik karşılığı — mobil, reduced-motion ve WebGL'siz cihazlar için. */
function Poster() {
  return (
    <div
      className="absolute inset-0 bg-bg-footer"
      style={{
        backgroundImage: "url(/brand/scene-poster.svg)",
        backgroundSize: "cover",
        backgroundPosition: "center",
      }}
      aria-hidden
    />
  );
}

export default function PrintScene() {
  const [enabled, setEnabled] = useState(false);
  const [visible, setVisible] = useState(true);
  const host = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const wide = window.matchMedia("(min-width: 768px)").matches;
    const calm = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    setEnabled(wide && !calm && supportsWebGL());
  }, []);

  useEffect(() => {
    if (!enabled || !host.current) return;
    const io = new IntersectionObserver(
      ([entry]) => setVisible(entry.isIntersecting),
      { rootMargin: "120px" }
    );
    io.observe(host.current);
    return () => io.disconnect();
  }, [enabled]);

  return (
    <div ref={host} className="absolute inset-0">
      {enabled ? <PrintSceneCanvas paused={!visible} /> : <Poster />}
    </div>
  );
}
