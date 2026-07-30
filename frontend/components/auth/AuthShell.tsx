"use client";

import Link from "next/link";
import Logo from "@/components/brand/Logo";

interface AuthShellProps {
  children: React.ReactNode;
  title: React.ReactNode;
  subtitle?: React.ReactNode;
}

/**
 * Giriş / kayıt / şifre akışları için tam ekran iki kolon — Header/Footer yok.
 *
 * Prop imzası bilerek değiştirilmedi: dört sayfa (giris-yap, kayit-ol,
 * sifremi-unuttum, sifremi-sifirla) bu bileşeni aynı şekilde kullanıyor.
 *
 * Sol kolon marka anlatısı, sağ kolon form. Mobilde marka kolonu gizleniyor —
 * küçük ekranda formla yarışmasın.
 */
export default function AuthShell({ children, title, subtitle }: AuthShellProps) {
  return (
    <div className="min-h-screen w-full flex flex-col bg-bg-primary">
      <header className="px-6 md:px-10 py-5 flex items-center justify-between">
        <Link href="/" aria-label="Ana sayfa">
          <Logo height={26} />
        </Link>
        <Link
          href="/magaza"
          className="font-mono text-[11px] uppercase tracking-wider text-text-secondary hover:text-primary-dark transition-colors"
        >
          Kataloğa dön →
        </Link>
      </header>

      <div className="flex-1 flex items-center justify-center px-4 pb-10 md:px-8">
        <div className="w-full max-w-5xl grid lg:grid-cols-2 rounded-3xl border-2 border-text-primary overflow-hidden shadow-toy bg-card-bg">
          {/* --- Marka kolonu (yalnızca lg ve üstü) --- */}
          <aside className="relative hidden lg:flex flex-col justify-between bg-bg-footer text-white p-9 overflow-hidden">
            <PlateGrid />

            <div className="relative">
              <span className="inline-flex items-center gap-2 font-mono text-[10px] uppercase tracking-[0.2em] bg-white/[0.06] border border-white/10 rounded-full px-3.5 py-1.5">
                <span className="w-1.5 h-1.5 rounded-full bg-primary" />
                Ankara / atölye
              </span>

              <h2 className="mt-6 font-display text-[32px] xl:text-[40px] leading-[1.08] max-w-[380px]">
                Sipariş ver,
                <br />
                <span className="text-primary">tezgâha koyalım.</span>
              </h2>

              <p className="mt-5 text-sm text-white/65 leading-relaxed max-w-[340px]">
                Hesabınla siparişlerini takip eder, favori baskılarını
                kaydeder, adreslerini bir kez girersin.
              </p>
            </div>

            <div className="relative flex-1 flex items-center justify-center my-6">
              <WorkshopIllustration />
            </div>

            <dl className="relative grid grid-cols-3 gap-3 pt-6 border-t border-white/10">
              {[
                { v: "0.12 mm", t: "katman" },
                { v: "8 renk", t: "filament" },
                { v: "aynı gün", t: "kargo" },
              ].map((s) => (
                <div key={s.t}>
                  <dt className="font-display text-lg xl:text-xl leading-none">{s.v}</dt>
                  <dd className="mt-1.5 font-mono text-[10px] uppercase tracking-wider text-white/45">
                    {s.t}
                  </dd>
                </div>
              ))}
            </dl>
          </aside>

          {/* --- Form kolonu --- */}
          <main className="p-7 sm:p-10 flex flex-col justify-center">
            <h1 className="font-display text-2xl sm:text-3xl text-text-primary">
              {title}
            </h1>
            {subtitle && (
              <p className="mt-2 text-sm text-text-secondary leading-relaxed">
                {subtitle}
              </p>
            )}
            <div className="mt-7">{children}</div>
          </main>
        </div>
      </div>
    </div>
  );
}

/** Koyu kolonun arka planındaki baskı tablası ızgarası. */
function PlateGrid() {
  return (
    <span
      aria-hidden
      className="absolute inset-0 opacity-[0.18]"
      style={{
        backgroundImage:
          "linear-gradient(rgba(255,255,255,0.25) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.25) 1px, transparent 1px)",
        backgroundSize: "26px 26px",
      }}
    />
  );
}

/**
 * İzometrik atölye: baskı tablası üzerinde katman katman oluşan bir parça,
 * üstünde nozul, yanında filament makarası.
 *
 * Eski illüstrasyon kozmetik ürünleriydi (krem kavanozu, serum damlalığı,
 * "SPF 50+" yazılı şişe) — bu markanın dünyasıyla ilgisi yoktu.
 */
function WorkshopIllustration() {
  return (
    <svg
      viewBox="0 0 320 260"
      className="w-full max-w-[320px]"
      role="img"
      aria-label="Baskı tablası üzerinde katman katman oluşan bir parça"
    >
      {/* tabla */}
      <path d="M160 214 L296 150 L160 86 L24 150 Z" fill="#20293B" />
      <path
        d="M160 214 L296 150 L160 86 L24 150 Z"
        fill="none"
        stroke="#FF6B2C"
        strokeWidth="2"
        opacity="0.55"
      />
      <g stroke="#3A4560" strokeWidth="1" opacity="0.5">
        <path d="M58 167 L194 103 M92 184 L228 120 M126 69 L262 133 M92 52 L228 116" />
      </g>

      {/* katmanlar */}
      <g>
        <ellipse cx="160" cy="146" rx="52" ry="20" fill="#FF6B2C" />
        <ellipse cx="160" cy="134" rx="55" ry="21" fill="#FA7A2B" />
        <ellipse cx="160" cy="122" rx="54" ry="21" fill="#F79429" />
        <ellipse cx="160" cy="110" rx="48" ry="18" fill="#FBB32F" />
        <ellipse cx="160" cy="99" rx="40" ry="15" fill="#FFC53D" />
        <ellipse cx="160" cy="89" rx="33" ry="13" fill="#8CBE7A" />
        <ellipse cx="160" cy="80" rx="30" ry="12" fill="#12B5A5" />
      </g>

      {/* nozul */}
      <g>
        <rect
          x="146"
          y="14"
          width="28"
          height="34"
          rx="6"
          fill="#141A26"
          stroke="#3A4560"
          strokeWidth="2"
        />
        <rect x="152" y="22" width="16" height="4" rx="2" fill="#3A4560" />
        <path d="M152 48 h16 l-8 14 z" fill="#8A8F9C" />
        <rect x="157" y="62" width="6" height="12" rx="3" fill="#12B5A5" opacity="0.7" />
      </g>

      {/* filament makarası */}
      <g transform="translate(48 62)">
        <circle r="26" fill="none" stroke="#FF6B2C" strokeWidth="10" />
        <circle r="11" fill="#20293B" stroke="#3A4560" strokeWidth="3" />
        <path
          d="M26 4 q22 14 10 36"
          stroke="#FF6B2C"
          strokeWidth="4"
          fill="none"
          strokeLinecap="round"
        />
      </g>
    </svg>
  );
}
