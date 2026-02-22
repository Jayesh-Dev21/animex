import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'Animex - CLI Anime Streaming',
  description: 'Stream and download anime from your terminal with quality control and powerful features',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}
