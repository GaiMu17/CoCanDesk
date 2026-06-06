import AppKit

let outPath = CommandLine.arguments.dropFirst().first ?? "Sources/CoCanDesk/Resources/AppIcon-1024.png"
let size = 1024
let image = NSImage(size: NSSize(width: size, height: size))

func roundedRect(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat, _ radius: CGFloat) -> NSBezierPath {
    NSBezierPath(roundedRect: NSRect(x: x, y: y, width: width, height: height), xRadius: radius, yRadius: radius)
}

func fill(_ color: NSColor, _ path: NSBezierPath) {
    color.setFill()
    path.fill()
}

func stroke(_ color: NSColor, _ path: NSBezierPath, width: CGFloat) {
    color.setStroke()
    path.lineWidth = width
    path.stroke()
}

func shadowFill(_ path: NSBezierPath, color: NSColor, shadow: NSColor, y: CGFloat, blur: CGFloat) {
    NSGraphicsContext.saveGraphicsState()
    let effect = NSShadow()
    effect.shadowColor = shadow
    effect.shadowOffset = NSSize(width: 0, height: y)
    effect.shadowBlurRadius = blur
    effect.set()
    fill(color, path)
    NSGraphicsContext.restoreGraphicsState()
}

func boltPath() -> NSBezierPath {
    let path = NSBezierPath()
    path.move(to: NSPoint(x: 588, y: 802))
    path.line(to: NSPoint(x: 354, y: 506))
    path.line(to: NSPoint(x: 492, y: 506))
    path.line(to: NSPoint(x: 430, y: 204))
    path.line(to: NSPoint(x: 696, y: 540))
    path.line(to: NSPoint(x: 548, y: 540))
    path.close()
    return path
}

let cream = NSColor(calibratedRed: 0.982, green: 0.965, blue: 0.930, alpha: 1)
let creamLight = NSColor(calibratedRed: 1.0, green: 0.985, blue: 0.955, alpha: 1)
let warmPanel = NSColor(calibratedRed: 1.0, green: 0.915, blue: 0.760, alpha: 1)
let orange = NSColor(calibratedRed: 1.0, green: 0.34, blue: 0.15, alpha: 1)
let orangeDeep = NSColor(calibratedRed: 0.88, green: 0.28, blue: 0.10, alpha: 1)
let amber = NSColor(calibratedRed: 0.98, green: 0.62, blue: 0.18, alpha: 1)
let ink = NSColor(calibratedRed: 0.16, green: 0.15, blue: 0.14, alpha: 1)

image.lockFocus()
NSGraphicsContext.current?.imageInterpolation = .high
NSColor.clear.setFill()
NSRect(x: 0, y: 0, width: size, height: size).fill()

let base = roundedRect(64, 64, 896, 896, 210)
shadowFill(base, color: cream, shadow: NSColor.black.withAlphaComponent(0.10), y: -18, blur: 44)

let inner = roundedRect(112, 112, 800, 800, 178)
fill(creamLight, inner)
stroke(NSColor.white.withAlphaComponent(0.8), inner, width: 2)

let warmBlob = NSBezierPath(ovalIn: NSRect(x: 224, y: 180, width: 576, height: 700))
fill(warmPanel.withAlphaComponent(0.48), warmBlob)

let glow = boltPath()
stroke(NSColor(calibratedRed: 1.0, green: 0.54, blue: 0.22, alpha: 0.22), glow, width: 88)
stroke(NSColor(calibratedRed: 1.0, green: 0.76, blue: 0.36, alpha: 0.32), glow, width: 50)

let bolt = boltPath()
shadowFill(bolt, color: orange, shadow: NSColor(calibratedRed: 1.0, green: 0.40, blue: 0.12, alpha: 0.34), y: -2, blur: 26)
stroke(orangeDeep, bolt, width: 12)
stroke(NSColor.white.withAlphaComponent(0.72), bolt, width: 5)

let highlight = NSBezierPath()
highlight.move(to: NSPoint(x: 554, y: 724))
highlight.line(to: NSPoint(x: 458, y: 524))
highlight.lineCapStyle = .round
stroke(NSColor.white.withAlphaComponent(0.72), highlight, width: 15)

let warmEdge = NSBezierPath()
warmEdge.move(to: NSPoint(x: 430, y: 204))
warmEdge.line(to: NSPoint(x: 696, y: 540))
warmEdge.lineCapStyle = .round
stroke(amber.withAlphaComponent(0.66), warmEdge, width: 12)

let baseLine = NSBezierPath()
baseLine.move(to: NSPoint(x: 300, y: 296))
baseLine.curve(to: NSPoint(x: 724, y: 326), controlPoint1: NSPoint(x: 420, y: 240), controlPoint2: NSPoint(x: 600, y: 250))
baseLine.lineCapStyle = .round
stroke(ink.withAlphaComponent(0.08), baseLine, width: 22)

for (x, y, len) in [(248.0, 590.0, 72.0), (750.0, 382.0, 66.0), (676.0, 738.0, 48.0)] {
    let spark = NSBezierPath()
    spark.move(to: NSPoint(x: x, y: y))
    spark.line(to: NSPoint(x: x + len, y: y + 16))
    spark.lineCapStyle = .round
    stroke(orangeDeep.withAlphaComponent(0.22), spark, width: 8)
}

image.unlockFocus()

guard
    let tiff = image.tiffRepresentation,
    let bitmap = NSBitmapImageRep(data: tiff),
    let png = bitmap.representation(using: .png, properties: [:])
else {
    fatalError("Could not render PNG")
}

try png.write(to: URL(fileURLWithPath: outPath))
