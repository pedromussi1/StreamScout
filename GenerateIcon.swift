#!/usr/bin/env swift
import AppKit
import CoreGraphics

let size = CGFloat(1024)
let image = NSImage(size: NSSize(width: size, height: size))

image.lockFocus()
guard let ctx = NSGraphicsContext.current?.cgContext else { exit(1) }

// -- Background: dark gradient --
let bgColors = [
    CGColor(red: 0.012, green: 0.027, blue: 0.071, alpha: 1), // #030712
    CGColor(red: 0.043, green: 0.067, blue: 0.137, alpha: 1)  // #0b1123
] as CFArray
let bgGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                             colors: bgColors,
                             locations: [0, 1])!
ctx.drawLinearGradient(bgGradient,
                       start: CGPoint(x: size / 2, y: size),
                       end:   CGPoint(x: size / 2, y: 0),
                       options: [])

// -- Subtle film strip in background --
let stripColor = CGColor(red: 1, green: 1, blue: 1, alpha: 0.04)
ctx.setFillColor(stripColor)

// Vertical film strip left
let stripW = CGFloat(90)
let stripX1 = CGFloat(180)
ctx.fill(CGRect(x: stripX1, y: 0, width: stripW, height: size))

// Vertical film strip right
let stripX2 = size - 180 - stripW
ctx.fill(CGRect(x: stripX2, y: 0, width: stripW, height: size))

// Film perforations on left strip
let perfColor = CGColor(red: 1, green: 1, blue: 1, alpha: 0.06)
ctx.setFillColor(perfColor)
let perfW = CGFloat(20)
let perfH = CGFloat(30)
let perfSpacing = CGFloat(70)
for i in 0..<15 {
    let y = CGFloat(i) * perfSpacing + 20
    // Left strip perforations
    ctx.fill(CGRect(x: stripX1 + 10, y: y, width: perfW, height: perfH))
    ctx.fill(CGRect(x: stripX1 + stripW - 30, y: y, width: perfW, height: perfH))
    // Right strip perforations
    ctx.fill(CGRect(x: stripX2 + 10, y: y, width: perfW, height: perfH))
    ctx.fill(CGRect(x: stripX2 + stripW - 30, y: y, width: perfW, height: perfH))
}

// -- Magnifying glass --
let glassRadius = CGFloat(200)
let glassCenterX = size * 0.45
let glassCenterY = size * 0.48

// Glass circle - outer ring
let ringWidth = CGFloat(28)
let outerColors = [
    CGColor(red: 0.75, green: 0.78, blue: 0.82, alpha: 1), // silver
    CGColor(red: 0.55, green: 0.58, blue: 0.62, alpha: 1)  // darker silver
] as CFArray
let ringGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                               colors: outerColors,
                               locations: [0, 1])!

// Draw the ring as a stroked circle
ctx.saveGState()
ctx.setLineWidth(ringWidth)
let ringPath = CGMutablePath()
ringPath.addEllipse(in: CGRect(x: glassCenterX - glassRadius,
                                y: glassCenterY - glassRadius,
                                width: glassRadius * 2,
                                height: glassRadius * 2))
ctx.addPath(ringPath)
ctx.replacePathWithStrokedPath()
ctx.clip()
ctx.drawLinearGradient(ringGradient,
                       start: CGPoint(x: glassCenterX, y: glassCenterY + glassRadius),
                       end: CGPoint(x: glassCenterX, y: glassCenterY - glassRadius),
                       options: [])
ctx.restoreGState()

// Glass inner fill - slight tint
let glassInnerColor = CGColor(red: 0.063, green: 0.725, blue: 0.506, alpha: 0.08)
ctx.setFillColor(glassInnerColor)
ctx.fillEllipse(in: CGRect(x: glassCenterX - glassRadius + ringWidth/2,
                            y: glassCenterY - glassRadius + ringWidth/2,
                            width: (glassRadius - ringWidth/2) * 2,
                            height: (glassRadius - ringWidth/2) * 2))

// Glass shine highlight
ctx.saveGState()
let shineColor = CGColor(red: 1, green: 1, blue: 1, alpha: 0.08)
ctx.setFillColor(shineColor)
let shineRect = CGRect(x: glassCenterX - glassRadius * 0.6,
                        y: glassCenterY + glassRadius * 0.1,
                        width: glassRadius * 0.8,
                        height: glassRadius * 0.7)
ctx.fillEllipse(in: shineRect)
ctx.restoreGState()

// -- Handle of magnifying glass --
let handleAngle = -CGFloat.pi / 4  // 45 degrees down-right
let handleStartX = glassCenterX + glassRadius * cos(handleAngle)
let handleStartY = glassCenterY + glassRadius * sin(handleAngle)
let handleLength = CGFloat(220)
let handleEndX = handleStartX + handleLength * cos(handleAngle)
let handleEndY = handleStartY + handleLength * sin(handleAngle)

// Handle shadow
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 4, height: -4), blur: 12,
              color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.5))

let handleColors = [
    CGColor(red: 0.65, green: 0.68, blue: 0.72, alpha: 1),
    CGColor(red: 0.45, green: 0.48, blue: 0.52, alpha: 1)
] as CFArray
let handleGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                 colors: handleColors,
                                 locations: [0, 1])!

ctx.setLineWidth(36)
ctx.setLineCap(.round)
ctx.move(to: CGPoint(x: handleStartX, y: handleStartY))
ctx.addLine(to: CGPoint(x: handleEndX, y: handleEndY))
ctx.replacePathWithStrokedPath()
ctx.clip()
ctx.drawLinearGradient(handleGradient,
                       start: CGPoint(x: handleStartX, y: handleStartY),
                       end: CGPoint(x: handleEndX, y: handleEndY),
                       options: [])
ctx.restoreGState()

// -- Play triangle inside the magnifying glass --
let triSize = CGFloat(90)
let triCenterX = glassCenterX + 10  // slight offset right for visual centering of play button
let triCenterY = glassCenterY

// Green accent play button
let playColors = [
    CGColor(red: 0.063, green: 0.725, blue: 0.506, alpha: 1),  // #10b981
    CGColor(red: 0.204, green: 0.827, blue: 0.600, alpha: 1)   // #34d399
] as CFArray
let playGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                               colors: playColors,
                               locations: [0, 1])!

let triPath = CGMutablePath()
let triLeft = CGPoint(x: triCenterX - triSize * 0.4, y: triCenterY - triSize * 0.5)
let triRight = CGPoint(x: triCenterX + triSize * 0.6, y: triCenterY)
let triBottom = CGPoint(x: triCenterX - triSize * 0.4, y: triCenterY + triSize * 0.5)
triPath.move(to: triLeft)
triPath.addLine(to: triRight)
triPath.addLine(to: triBottom)
triPath.closeSubpath()

// Shadow for play button
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -4), blur: 16,
              color: CGColor(red: 0.063, green: 0.725, blue: 0.506, alpha: 0.4))
ctx.addPath(triPath)
ctx.clip()
ctx.drawLinearGradient(playGradient,
                       start: CGPoint(x: triCenterX, y: triCenterY + triSize * 0.5),
                       end: CGPoint(x: triCenterX, y: triCenterY - triSize * 0.5),
                       options: [])
ctx.restoreGState()

image.unlockFocus()

// Save PNG
let tiff = image.tiffRepresentation!
let bitmap = NSBitmapImageRep(data: tiff)!
let png = bitmap.representation(using: .png, properties: [:])!

let outputPath = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : "AppIcon.png"

try! png.write(to: URL(fileURLWithPath: outputPath))
print("Icon written to \(outputPath)")
