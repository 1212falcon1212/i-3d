import type { Metadata, Viewport } from "next";
import Providers from "@/components/Providers";
import LenisProvider from "@/app/providers/LenisProvider";
import { Toaster } from "sonner";
import "./globals.css";

export const metadata: Metadata = {
  title: {
    default: "i-3d — 3D baskı ürünleri, filament ve yedek parça",
    template: "%s | i-3d",
  },
  description:
    "Figürden ev dekoruna, filamentten yedek parçaya 3D baskı ürünleri i-3d'de. Katman katman basılır, kapına gelir.",
  keywords: [
    "3d baskı",
    "3d yazıcı",
    "filament",
    "figür",
    "3d model",
    "yedek parça",
    "hobi",
  ],
  metadataBase: new URL(
    process.env.NEXT_PUBLIC_SITE_URL || "http://localhost:3200"
  ),
  openGraph: {
    type: "website",
    locale: "tr_TR",
    siteName: "i-3d",
  },
  robots: {
    index: true,
    follow: true,
  },
  manifest: "/manifest.json",
  icons: {
    icon: [{ url: "/favicon.png?v=1", type: "image/png", sizes: "64x64" }],
    shortcut: [{ url: "/favicon.png?v=1", type: "image/png" }],
    apple: [{ url: "/favicon.png?v=1", type: "image/png", sizes: "64x64" }],
  },
};

export const viewport: Viewport = {
  themeColor: "#FF6B2C",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="tr" className="h-full antialiased">
      <body className="min-h-full flex flex-col bg-bg-primary text-text-primary font-body">
        <LenisProvider>
          <Providers>{children}</Providers>
          <Toaster position="top-right" richColors />
        </LenisProvider>
      </body>
    </html>
  );
}
