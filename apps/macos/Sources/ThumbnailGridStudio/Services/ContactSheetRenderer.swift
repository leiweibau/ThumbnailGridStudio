import AppKit
import Foundation

struct ContactSheetMetadataVisibility {
    let showFileName: Bool
    let showDuration: Bool
    let showFileSize: Bool
    let showResolution: Bool
    let showTimestamp: Bool
    let showBitrate: Bool
    let showVideoCodec: Bool
    let showAudioCodec: Bool
}

struct ContactSheetRenderOptions {
    let columns: Int
    let rows: Int
    let spacing: CGFloat
    let thumbnailSize: CGSize
    let backgroundColor: NSColor
    let metadataTextColor: NSColor
    let fileNameFontSize: CGFloat
    let durationFontSize: CGFloat
    let fileSizeFontSize: CGFloat
    let resolutionFontSize: CGFloat
    let timestampFontSize: CGFloat
    let bitrateFontSize: CGFloat
    let videoCodecFontSize: CGFloat
    let audioCodecFontSize: CGFloat
    let metadataVisibility: ContactSheetMetadataVisibility
}

enum ContactSheetRenderer {
    private static let metadataLeftColumnWidth: CGFloat = 280
    private static let placeholderBackgroundDarkImage: NSImage? = {
        guard let url = Bundle.module.url(forResource: "prev_background_dark", withExtension: "png") else {
            return nil
        }
        return NSImage(contentsOf: url)
    }()
    private static let placeholderBackgroundLightImage: NSImage? = {
        guard let url = Bundle.module.url(forResource: "prev_background_light", withExtension: "png") else {
            return nil
        }
        return NSImage(contentsOf: url)
    }()

    static func render(
        title: String,
        durationText: String,
        resolutionText: String,
        fileSizeText: String,
        bitrateText: String,
        videoCodecText: String,
        audioCodecTexts: [String],
        thumbnails: [ThumbnailFrame],
        options: ContactSheetRenderOptions
    ) -> NSImage {
        let horizontalPadding: CGFloat = 28
        let verticalPadding: CGFloat = 28
        let headerHeight = calculatedHeaderHeight(
            for: options,
            audioCodecLineCount: options.metadataVisibility.showAudioCodec ? max(audioCodecTexts.count, 1) : 0
        )
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

        let titleColor = preferredTextColor(for: options.backgroundColor)
        let metadataColor = options.metadataTextColor
        let secondaryColor = metadataColor.withAlphaComponent(0.82)

        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: options.fileNameFontSize, weight: .semibold),
            .foregroundColor: titleColor
        ]
        let durationAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: options.durationFontSize, weight: .medium),
            .foregroundColor: secondaryColor
        ]
        let fileSizeAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: options.fileSizeFontSize, weight: .medium),
            .foregroundColor: secondaryColor
        ]
        let resolutionAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: options.resolutionFontSize, weight: .medium),
            .foregroundColor: secondaryColor
        ]
        let bitrateAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: options.bitrateFontSize, weight: .medium),
            .foregroundColor: secondaryColor
        ]
        let videoCodecAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: options.videoCodecFontSize, weight: .medium),
            .foregroundColor: secondaryColor
        ]
        let audioCodecAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: options.audioCodecFontSize, weight: .medium),
            .foregroundColor: secondaryColor
        ]

        let labelDuration = AppStrings.metadataLabelDuration
        let labelSize = AppStrings.metadataLabelSize
        let labelResolution = AppStrings.metadataLabelResolution
        let labelBitrate = AppStrings.metadataLabelBitrate
        let labelVideo = AppStrings.metadataLabelVideo
        let labelAudio = AppStrings.metadataLabelAudio
        let unknownValue = AppStrings.metadataUnknownValue

        var currentY = canvasSize.height - verticalPadding

        if options.metadataVisibility.showFileName {
            let lineHeight = lineHeight(for: titleAttributes)
            let titleRect = NSRect(
                x: horizontalPadding,
                y: currentY - lineHeight,
                width: canvasSize.width - horizontalPadding * 2,
                height: lineHeight
            )
            title.draw(in: titleRect, withAttributes: titleAttributes)
            currentY -= lineHeight + 6
        }

        let topLeftText = options.metadataVisibility.showDuration ? "\(labelDuration): \(durationText)" : nil
        let topRightText = options.metadataVisibility.showFileSize ? "\(labelSize): \(fileSizeText)" : nil
        let bottomLeftText = options.metadataVisibility.showResolution ? "\(labelResolution): \(resolutionText)" : nil
        let bottomRightText = options.metadataVisibility.showBitrate ? "\(labelBitrate): \(bitrateText)" : nil
        let metadataColumnGap: CGFloat = 50
        let sharedRightColumnXOffset = sharedRightColumnOffset(
            leftColumnWidth: metadataLeftColumnWidth,
            gap: metadataColumnGap
        )

        let topMetadataLine = metadataColumns(
            leftText: topLeftText,
            rightText: topRightText,
            leftAttributes: durationAttributes,
            rightAttributes: fileSizeAttributes,
            rightColumnXOffset: sharedRightColumnXOffset
        )
        if let leftLine = topMetadataLine.leftLine {
            leftLine.draw(
                in: NSRect(
                    x: horizontalPadding,
                    y: currentY - topMetadataLine.lineHeight,
                    width: metadataLeftColumnWidth,
                    height: topMetadataLine.lineHeight
                )
            )
        }
        if let rightLine = topMetadataLine.rightLine {
            rightLine.draw(
                in: NSRect(
                    x: horizontalPadding + topMetadataLine.rightColumnXOffset,
                    y: currentY - topMetadataLine.lineHeight,
                    width: canvasSize.width - horizontalPadding * 2 - topMetadataLine.rightColumnXOffset,
                    height: topMetadataLine.lineHeight
                )
            )
        }
        if topMetadataLine.hasContent {
            currentY -= topMetadataLine.lineHeight + 4
        }

        let bottomMetadataLine = metadataColumns(
            leftText: bottomLeftText,
            rightText: bottomRightText,
            leftAttributes: resolutionAttributes,
            rightAttributes: bitrateAttributes,
            rightColumnXOffset: sharedRightColumnXOffset
        )
        if let leftLine = bottomMetadataLine.leftLine {
            leftLine.draw(
                in: NSRect(
                    x: horizontalPadding,
                    y: currentY - bottomMetadataLine.lineHeight,
                    width: metadataLeftColumnWidth,
                    height: bottomMetadataLine.lineHeight
                )
            )
        }
        if let rightLine = bottomMetadataLine.rightLine {
            rightLine.draw(
                in: NSRect(
                    x: horizontalPadding + bottomMetadataLine.rightColumnXOffset,
                    y: currentY - bottomMetadataLine.lineHeight,
                    width: canvasSize.width - horizontalPadding * 2 - bottomMetadataLine.rightColumnXOffset,
                    height: bottomMetadataLine.lineHeight
                )
            )
        }
        if bottomMetadataLine.hasContent {
            currentY -= bottomMetadataLine.lineHeight + 4
        }

        if options.metadataVisibility.showVideoCodec {
            let lineHeight = lineHeight(for: videoCodecAttributes)
            let value = videoCodecText.isEmpty ? unknownValue : videoCodecText
            let line = "\(labelVideo): \(value)"
            line.draw(
                in: NSRect(x: horizontalPadding, y: currentY - lineHeight, width: canvasSize.width - horizontalPadding * 2, height: lineHeight),
                withAttributes: videoCodecAttributes
            )
            currentY -= lineHeight + 4
        }

        if options.metadataVisibility.showAudioCodec {
            let codecs = audioCodecTexts.isEmpty ? [unknownValue] : audioCodecTexts
            let lineHeight = lineHeight(for: audioCodecAttributes)
            for codec in codecs {
                let line = "\(labelAudio): \(codec)"
                line.draw(
                    in: NSRect(x: horizontalPadding, y: currentY - lineHeight, width: canvasSize.width - horizontalPadding * 2, height: lineHeight),
                    withAttributes: audioCodecAttributes
                )
                currentY -= lineHeight + 4
            }
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
                drawThumbnail(
                    thumbnails[index],
                    in: frame,
                    timestampFontSize: options.timestampFontSize,
                    showTimestamp: options.metadataVisibility.showTimestamp
                )
            }
        }

        image.unlockFocus()
        return image
    }

    @MainActor
    static func renderPlaceholder(
        title: String,
        durationText: String,
        resolutionText: String,
        fileSizeText: String,
        bitrateText: String,
        videoCodecText: String,
        audioCodecTexts: [String],
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
            bitrateText: bitrateText,
            videoCodecText: videoCodecText,
            audioCodecTexts: audioCodecTexts,
            thumbnails: placeholderThumbnails,
            options: options
        )
    }

    private static func drawThumbnail(
        _ thumbnail: ThumbnailFrame,
        in frame: NSRect,
        timestampFontSize: CGFloat,
        showTimestamp: Bool
    ) {
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
        if showTimestamp {
            drawTimestamp(timestampText(for: thumbnail.timestamp), in: frame, fontSize: timestampFontSize)
        }
        NSGraphicsContext.restoreGraphicsState()
    }

    private static func drawTimestamp(_ text: String, in frame: NSRect, fontSize: CGFloat) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedDigitSystemFont(ofSize: fontSize, weight: .semibold),
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

    private static func calculatedHeaderHeight(for options: ContactSheetRenderOptions, audioCodecLineCount: Int) -> CGFloat {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: options.fileNameFontSize, weight: .semibold)
        ]
        let durationAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: options.durationFontSize, weight: .medium)
        ]
        let fileSizeAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: options.fileSizeFontSize, weight: .medium)
        ]
        let resolutionAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: options.resolutionFontSize, weight: .medium)
        ]
        let bitrateAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: options.bitrateFontSize, weight: .medium)
        ]
        let videoCodecAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: options.videoCodecFontSize, weight: .medium)
        ]
        let audioCodecAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: options.audioCodecFontSize, weight: .medium)
        ]

        var height: CGFloat = 18
        if options.metadataVisibility.showFileName { height += lineHeight(for: titleAttributes) + 10 }
        if options.metadataVisibility.showDuration || options.metadataVisibility.showFileSize {
            height += max(lineHeight(for: durationAttributes), lineHeight(for: fileSizeAttributes)) + 6
        }
        if options.metadataVisibility.showResolution || options.metadataVisibility.showBitrate {
            height += max(lineHeight(for: resolutionAttributes), lineHeight(for: bitrateAttributes)) + 6
        }
        if options.metadataVisibility.showVideoCodec {
            height += lineHeight(for: videoCodecAttributes) + 6
        }
        if options.metadataVisibility.showAudioCodec {
            height += CGFloat(max(audioCodecLineCount, 1)) * (lineHeight(for: audioCodecAttributes) + 6)
        }
        return max(height, 18)
    }

    private static func metadataColumns(
        leftText: String?,
        rightText: String?,
        leftAttributes: [NSAttributedString.Key: Any],
        rightAttributes: [NSAttributedString.Key: Any],
        rightColumnXOffset: CGFloat
    ) -> (leftLine: NSAttributedString?, rightLine: NSAttributedString?, leftColumnWidth: CGFloat, rightColumnXOffset: CGFloat, lineHeight: CGFloat, hasContent: Bool) {
        let leftLine = leftText.map { NSAttributedString(string: $0, attributes: leftAttributes) }
        let rightLine = rightText.map { NSAttributedString(string: $0, attributes: rightAttributes) }
        let leftWidth = leftText.map { ceil(($0 as NSString).size(withAttributes: leftAttributes).width) } ?? 0
        let rightOffset = rightLine != nil ? rightColumnXOffset : 0
        let lineHeight = max(lineHeight(for: leftAttributes), lineHeight(for: rightAttributes))
        return (leftLine, rightLine, leftWidth, rightOffset, lineHeight, leftLine != nil || rightLine != nil)
    }

    private static func sharedRightColumnOffset(
        leftColumnWidth: CGFloat,
        gap: CGFloat
    ) -> CGFloat {
        leftColumnWidth + gap
    }

    private static func lineHeight(for attributes: [NSAttributedString.Key: Any]) -> CGFloat {
        ceil(("Ag" as NSString).size(withAttributes: attributes).height)
    }

    private static func preferredTextColor(for color: NSColor) -> NSColor {
        guard let rgb = color.usingColorSpace(.deviceRGB) else { return .white }
        let luminance = (0.299 * rgb.redComponent) + (0.587 * rgb.greenComponent) + (0.114 * rgb.blueComponent)
        return luminance > 0.62 ? .black : .white
    }

    @MainActor
    private static func placeholderThumbnail(index _: Int, size: CGSize) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()

        let bounds = NSRect(origin: .zero, size: size)
        if let placeholderBackgroundImage = placeholderBackgroundImageForCurrentAppearance() {
            placeholderBackgroundImage.draw(
                in: bounds,
                from: NSRect(origin: .zero, size: placeholderBackgroundImage.size),
                operation: .sourceOver,
                fraction: 1
            )
        } else {
            let fallbackGradient = NSGradient(
                colors: [
                    NSColor(calibratedWhite: 0.24, alpha: 1),
                    NSColor(calibratedWhite: 0.12, alpha: 1)
                ]
            )
            fallbackGradient?.draw(in: bounds, angle: -90)
        }

        let borderPath = NSBezierPath(roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5), xRadius: 16, yRadius: 16)
        borderPath.lineWidth = 1
        NSColor.white.withAlphaComponent(0.14).setStroke()
        borderPath.stroke()

        image.unlockFocus()
        return image
    }

    @MainActor
    private static func placeholderBackgroundImageForCurrentAppearance() -> NSImage? {
        if let bestMatch = NSApp?.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) {
            switch bestMatch {
            case .darkAqua:
                return placeholderBackgroundDarkImage
            default:
                return placeholderBackgroundLightImage
            }
        }

        return placeholderBackgroundLightImage
    }
}
