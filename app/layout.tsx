import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Skill India Certificate Verification",
  description: "Verified Skill India candidate certificate details.",
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="en"><body>{children}</body></html>;
}
