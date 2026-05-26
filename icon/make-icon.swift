// Renders the btop app icon (1024x1024 PNG) with CoreGraphics.
// Run via icon/make-icon.sh, which then builds btop.icns with iconutil.
import AppKit
import CoreGraphics

let dim = 1024
let f = CGFloat(dim)
let cs = CGColorSpaceCreateDeviceRGB()
guard let ctx = CGContext(data: nil, width: dim, height: dim,
                          bitsPerComponent: 8, bytesPerRow: 0, space: cs,
                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
    fatalError("could not create context")
}

func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor {
    CGColor(srgbRed: r / 255, green: g / 255, blue: b / 255, alpha: a)
}

// Transparent canvas so the squircle's corners are see-through.
ctx.clear(CGRect(x: 0, y: 0, width: f, height: f))

// Rounded-rect (squircle-ish) background with a dark vertical gradient.
let margin: CGFloat = 88
let rect = CGRect(x: margin, y: margin, width: f - 2 * margin, height: f - 2 * margin)
let radius = rect.width * 0.225
let bg = CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
ctx.saveGState()
ctx.addPath(bg)
ctx.clip()
let grad = CGGradient(colorsSpace: cs,
                      colors: [rgb(40, 42, 62), rgb(17, 17, 27)] as CFArray,
                      locations: [0, 1])!
ctx.drawLinearGradient(grad, start: CGPoint(x: 0, y: f), end: CGPoint(x: 0, y: 0), options: [])
ctx.restoreGState()

// Resource-meter bars (Catppuccin-ish palette, echoing btop's gauges).
let palette = [rgb(166, 227, 161), rgb(249, 226, 175), rgb(250, 179, 135),
               rgb(243, 139, 168), rgb(203, 166, 247), rgb(137, 180, 250)]
let heights: [CGFloat] = [0.40, 0.62, 0.48, 0.78, 0.55, 0.68]
let n = palette.count
let barAreaX = rect.minX + rect.width * 0.16
let barAreaW = rect.width * 0.68
let gap = barAreaW * 0.055
let barW = (barAreaW - gap * CGFloat(n - 1)) / CGFloat(n)
let baseY = rect.minY + rect.height * 0.32
let maxBarH = rect.height * 0.44
for i in 0..<n {
    let h = maxBarH * heights[i]
    let x = barAreaX + CGFloat(i) * (barW + gap)
    let br = CGRect(x: x, y: baseY, width: barW, height: h)
    ctx.addPath(CGPath(roundedRect: br, cornerWidth: barW * 0.35, cornerHeight: barW * 0.35, transform: nil))
    ctx.setFillColor(palette[i])
    ctx.fillPath()
}

// "btop" wordmark.
let nsctx = NSGraphicsContext(cgContext: ctx, flipped: false)
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = nsctx
let attrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.monospacedSystemFont(ofSize: rect.height * 0.19, weight: .bold),
    .foregroundColor: NSColor(srgbRed: 166 / 255, green: 227 / 255, blue: 161 / 255, alpha: 1),
]
let text = "btop" as NSString
let ts = text.size(withAttributes: attrs)
text.draw(at: NSPoint(x: rect.midX - ts.width / 2, y: rect.minY + rect.height * 0.09),
          withAttributes: attrs)
NSGraphicsContext.restoreGraphicsState()

guard let cg = ctx.makeImage() else { fatalError("could not render image") }
let rep = NSBitmapImageRep(cgImage: cg)
guard let png = rep.representation(using: .png, properties: [:]) else { fatalError("could not encode png") }
let out = URL(fileURLWithPath: "icon_1024.png")
try! png.write(to: out)
print("wrote \(out.path)")
