// Generates Fuori's original geometric mark for the web manifest.
// Run on macOS with: swift scripts/make-web-icons.swift
import AppKit
import Foundation

func makeIcon(size: Int, destination: String) throws {
    let side = CGFloat(size)
    let image = NSImage(size: NSSize(width: side, height: side))
    image.lockFocus()

    NSColor(calibratedRed: 0.776, green: 0.243, blue: 0.157, alpha: 1).setFill()
    NSRect(x: 0, y: 0, width: side, height: side).fill()

    NSColor.white.setFill()
    let stem = NSBezierPath(roundedRect: NSRect(x: side * 0.35, y: side * 0.25, width: side * 0.13, height: side * 0.48), xRadius: side * 0.035, yRadius: side * 0.035)
    stem.fill()
    let top = NSBezierPath(roundedRect: NSRect(x: side * 0.35, y: side * 0.61, width: side * 0.30, height: side * 0.12), xRadius: side * 0.04, yRadius: side * 0.04)
    top.fill()
    let middle = NSBezierPath(roundedRect: NSRect(x: side * 0.24, y: side * 0.43, width: side * 0.36, height: side * 0.11), xRadius: side * 0.04, yRadius: side * 0.04)
    middle.fill()
    let dot = NSBezierPath(ovalIn: NSRect(x: side * 0.64, y: side * 0.25, width: side * 0.115, height: side * 0.115))
    dot.fill()

    image.unlockFocus()
    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let png = bitmap.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "FuoriIcons", code: 1)
    }
    try png.write(to: URL(fileURLWithPath: destination))
}

try makeIcon(size: 32, destination: "web/favicon.png")
try makeIcon(size: 192, destination: "web/icons/Icon-192.png")
try makeIcon(size: 512, destination: "web/icons/Icon-512.png")
try makeIcon(size: 192, destination: "web/icons/Icon-maskable-192.png")
try makeIcon(size: 512, destination: "web/icons/Icon-maskable-512.png")
