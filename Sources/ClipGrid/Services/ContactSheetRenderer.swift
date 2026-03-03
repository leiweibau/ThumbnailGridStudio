import AppKit
import Foundation

struct ContactSheetMetadataVisibility {
    let showFileName: Bool
    let showDuration: Bool
    let showFileSize: Bool
    let showResolution: Bool
}

struct ContactSheetRenderOptions {
    let columns: Int
    let rows: Int
    let spacing: CGFloat
    let thumbnailSize: CGSize
    let backgroundColor: NSColor
    let metadataVisibility: ContactSheetMetadataVisibility
}

enum ContactSheetRenderer {
    static func render(
        title: String,
        durationText: String,
        resolutionText: String,
        fileSizeText: String,
        thumbnails: [ThumbnailFrame],
        options: ContactSheetRenderOptions
    ) -> NSImage {
        let horizontalPadding: CGFloat = 28
        let verticalPadding: CGFloat = 28
        let headerHeight = calculatedHeaderHeight(for: options.metadataVisibility)
        let gridWidth =
            CGFloat(options.columns) * options.thumbnailSize.width +
            CGFloat(max(options.columns - 1, 0)) * options.spacing
        let gridHeight =
            CGFloat(options.rows) * options.thumbnailSize.height +
            CGFloat(max(options.rows - 1, 0)) * options.spacing

        let canvasSize = CGSize(
            width: horizontalPadding * 2 + gridWidth,
            height: verticalPadding * 2 + headerHeight + gridHeight
        )

        let image = NSImage(size: canvasSize)
        image.lockFocus()

        options.backgroundColor.setFill()
        NSBezierPath(rect: NSRect(origin: .zero, size: canvasSize)).fill()

        let textColor = preferredTextColor(for: options.backgroundColor)
        let secondaryColor = textColor.withAlphaComponent(0.72)

        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 26, weight: .semibold),
            .foregroundColor: textColor
        ]
        let metaAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: secondaryColor
        ]

        var currentY = canvasSize.height - verticalPadding - 36

        if options.metadataVisibility.showFileName {
            let titleRect = NSRect(
                x: horizontalPadding,
                y: currentY,
                width: canvasSize.width - horizontalPadding * 2,
                height: 32
            )
            title.draw(in: titleRect, withAttributes: titleAttributes)
            currentY -= 26
        }

        let primaryMetadata = [options.metadataVisibility.showDuration ? durationText : nil,
                               options.metadataVisibility.showFileSize ? fileSizeText : nil]
            .compactMap { $0 }
            .joined(separator: "  •  ")

        if !primaryMetadata.isEmpty {
            let metaRect = NSRect(
                x: horizontalPadding,
                y: currentY,
                width: canvasSize.width - horizontalPadding * 2,
                height: 22
            )
            primaryMetadata.draw(in: metaRect, withAttributes: metaAttributes)
            currentY -= 22
        }

        if options.metadataVisibility.showResolution {
            let detailRect = NSRect(
                x: horizontalPadding,
                y: currentY,
                width: canvasSize.width - horizontalPadding * 2,
                height: 22
            )
            resolutionText.draw(in: detailRect, withAttributes: metaAttributes)
        }

        for row in 0..<options.rows {
            for column in 0..<options.columns {
                let index = row * options.columns + column
                let x = horizontalPadding + CGFloat(column) * (options.thumbnailSize.width + options.spacing)
                let y = verticalPadding + CGFloat(options.rows - 1 - row) * (options.thumbnailSize.height + options.spacing)
                let frame = NSRect(origin: CGPoint(x: x, y: y), size: options.thumbnailSize)

                let placeholder = NSBezierPath(roundedRect: frame, xRadius: 10, yRadius: 10)
                NSColor.white.withAlphaComponent(0.08).setFill()
                placeholder.fill()

                guard index < thumbnails.count else { continue }
                drawThumbnail(thumbnails[index], in: frame)
            }
        }

        image.unlockFocus()
        return image
    }

    static func renderPlaceholder(
        title: String,
        durationText: String,
        resolutionText: String,
        fileSizeText: String,
        options: ContactSheetRenderOptions
    ) -> NSImage {
        let placeholderThumbnails = (0..<(options.columns * options.rows)).map { index in
            ThumbnailFrame(
                image: placeholderThumbnail(index: index, size: options.thumbnailSize),
                timestamp: Double(index) * 10
            )
        }

        return render(
            title: title,
            durationText: durationText,
            resolutionText: resolutionText,
            fileSizeText: fileSizeText,
            thumbnails: placeholderThumbnails,
            options: options
        )
    }

    private static func drawThumbnail(_ thumbnail: ThumbnailFrame, in frame: NSRect) {
        let image = thumbnail.image
        let sourceSize = image.size
        guard sourceSize.width > 0, sourceSize.height > 0 else { return }

        let scale = max(frame.width / sourceSize.width, frame.height / sourceSize.height)
        let drawSize = CGSize(width: sourceSize.width * scale, height: sourceSize.height * scale)
        let drawOrigin = CGPoint(
            x: frame.midX - drawSize.width / 2,
            y: frame.midY - drawSize.height / 2
        )
        let drawRect = NSRect(origin: drawOrigin, size: drawSize)

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current?.imageInterpolation = .high
        let clipPath = NSBezierPath(roundedRect: frame, xRadius: 10, yRadius: 10)
        clipPath.addClip()
        image.draw(in: drawRect)
        drawTimestamp(timestampText(for: thumbnail.timestamp), in: frame)
        NSGraphicsContext.restoreGraphicsState()
    }

    private static func drawTimestamp(_ text: String, in frame: NSRect) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .semibold),
            .foregroundColor: NSColor.white
        ]
        let textSize = text.size(withAttributes: attributes)
        let badgeRect = NSRect(
            x: frame.maxX - textSize.width - 18,
            y: frame.minY + 10,
            width: textSize.width + 12,
            height: textSize.height + 6
        )

        NSColor.black.withAlphaComponent(0.6).setFill()
        NSBezierPath(roundedRect: badgeRect, xRadius: 7, yRadius: 7).fill()

        let textRect = NSRect(
            x: badgeRect.minX + 6,
            y: badgeRect.minY + 3,
            width: textSize.width,
            height: textSize.height
        )
        text.draw(in: textRect, withAttributes: attributes)
    }

    private static func timestampText(for seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds.rounded())
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let secs = totalSeconds % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        }
        return String(format: "%02d:%02d", minutes, secs)
    }

    private static func calculatedHeaderHeight(for visibility: ContactSheetMetadataVisibility) -> CGFloat {
        var height: CGFloat = 18
        if visibility.showFileName { height += 30 }
        if visibility.showDuration || visibility.showFileSize { height += 22 }
        if visibility.showResolution { height += 22 }
        return max(height, 18)
    }

    private static func preferredTextColor(for color: NSColor) -> NSColor {
        guard let rgb = color.usingColorSpace(.deviceRGB) else { return .white }
        let luminance = (0.299 * rgb.redComponent) + (0.587 * rgb.greenComponent) + (0.114 * rgb.blueComponent)
        return luminance > 0.62 ? .black : .white
    }

    private static func placeholderThumbnail(index: Int, size: CGSize) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()

        let hue = CGFloat((index % 8)) / 8.0
        let topColor = NSColor(calibratedHue: hue, saturation: 0.35, brightness: 0.92, alpha: 1)
        let bottomColor = NSColor(calibratedHue: hue, saturation: 0.45, brightness: 0.62, alpha: 1)
        let gradient = NSGradient(starting: topColor, ending: bottomColor)
        gradient?.draw(in: NSRect(origin: .zero, size: size), angle: -90)

        NSColor.white.withAlphaComponent(0.22).setStroke()
        let path = NSBezierPath()
        path.lineWidth = 6
        path.move(to: CGPoint(x: size.width * 0.12, y: size.height * 0.2))
        path.curve(
            to: CGPoint(x: size.width * 0.88, y: size.height * 0.76),
            controlPoint1: CGPoint(x: size.width * 0.28, y: size.height * 0.62),
            controlPoint2: CGPoint(x: size.width * 0.64, y: size.height * 0.34)
        )
        path.stroke()

        image.unlockFocus()
        return image
    }
}
