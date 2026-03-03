import AppKit
import Foundation
import SwiftUI

enum ExportFormat: String, CaseIterable, Identifiable {
    case jpg
    case png

    var id: String { rawValue }

    var fileExtension: String { rawValue }

    var displayName: String {
        switch self {
        case .jpg: AppStrings.exportJPEG
        case .png: AppStrings.exportPNG
        }
    }
}

@MainActor
final class AppSettings: ObservableObject {
    @Published var columns: Int { didSet { defaults.set(columns, forKey: Keys.columns) } }
    @Published var rows: Int { didSet { defaults.set(rows, forKey: Keys.rows) } }
    @Published var thumbnailSpacing: Double { didSet { defaults.set(thumbnailSpacing, forKey: Keys.thumbnailSpacing) } }
    @Published var thumbnailWidth: Double { didSet { defaults.set(thumbnailWidth, forKey: Keys.thumbnailWidth) } }
    @Published var thumbnailHeight: Double { didSet { defaults.set(thumbnailHeight, forKey: Keys.thumbnailHeight) } }
    @Published var backgroundRed: Double { didSet { defaults.set(backgroundRed, forKey: Keys.backgroundRed) } }
    @Published var backgroundGreen: Double { didSet { defaults.set(backgroundGreen, forKey: Keys.backgroundGreen) } }
    @Published var backgroundBlue: Double { didSet { defaults.set(backgroundBlue, forKey: Keys.backgroundBlue) } }
    @Published var exportFormat: ExportFormat { didSet { defaults.set(exportFormat.rawValue, forKey: Keys.exportFormat) } }
    @Published var showFileName: Bool { didSet { defaults.set(showFileName, forKey: Keys.showFileName) } }
    @Published var showDuration: Bool { didSet { defaults.set(showDuration, forKey: Keys.showDuration) } }
    @Published var showFileSize: Bool { didSet { defaults.set(showFileSize, forKey: Keys.showFileSize) } }
    @Published var showResolution: Bool { didSet { defaults.set(showResolution, forKey: Keys.showResolution) } }

    private let defaults: UserDefaults

    private enum Keys {
        static let columns = "settings.columns"
        static let rows = "settings.rows"
        static let thumbnailSpacing = "settings.thumbnailSpacing"
        static let thumbnailWidth = "settings.thumbnailWidth"
        static let thumbnailHeight = "settings.thumbnailHeight"
        static let backgroundRed = "settings.backgroundRed"
        static let backgroundGreen = "settings.backgroundGreen"
        static let backgroundBlue = "settings.backgroundBlue"
        static let exportFormat = "settings.exportFormat"
        static let showFileName = "settings.showFileName"
        static let showDuration = "settings.showDuration"
        static let showFileSize = "settings.showFileSize"
        static let showResolution = "settings.showResolution"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.columns = defaults.object(forKey: Keys.columns) as? Int ?? 4
        self.rows = defaults.object(forKey: Keys.rows) as? Int ?? 4
        self.thumbnailSpacing = defaults.object(forKey: Keys.thumbnailSpacing) as? Double ?? 16
        self.thumbnailWidth = defaults.object(forKey: Keys.thumbnailWidth) as? Double ?? 320
        self.thumbnailHeight = defaults.object(forKey: Keys.thumbnailHeight) as? Double ?? 180
        self.backgroundRed = defaults.object(forKey: Keys.backgroundRed) as? Double ?? 0.12
        self.backgroundGreen = defaults.object(forKey: Keys.backgroundGreen) as? Double ?? 0.13
        self.backgroundBlue = defaults.object(forKey: Keys.backgroundBlue) as? Double ?? 0.15
        self.exportFormat = ExportFormat(rawValue: defaults.string(forKey: Keys.exportFormat) ?? "") ?? .jpg
        self.showFileName = defaults.object(forKey: Keys.showFileName) as? Bool ?? true
        self.showDuration = defaults.object(forKey: Keys.showDuration) as? Bool ?? true
        self.showFileSize = defaults.object(forKey: Keys.showFileSize) as? Bool ?? true
        self.showResolution = defaults.object(forKey: Keys.showResolution) as? Bool ?? true
    }

    var backgroundColor: Color {
        Color(nsColor: backgroundNSColor)
    }

    var backgroundNSColor: NSColor {
        NSColor(
            calibratedRed: backgroundRed,
            green: backgroundGreen,
            blue: backgroundBlue,
            alpha: 1
        )
    }

    var renderKey: String {
        [
            columns,
            rows,
            Int(thumbnailSpacing),
            Int(thumbnailWidth),
            Int(thumbnailHeight),
            Int(backgroundRed * 1000),
            Int(backgroundGreen * 1000),
            Int(backgroundBlue * 1000),
            exportFormat.rawValue.hashValue,
            showFileName ? 1 : 0,
            showDuration ? 1 : 0,
            showFileSize ? 1 : 0,
            showResolution ? 1 : 0
        ].map(String.init).joined(separator: "-")
    }

    func updateBackgroundColor(_ color: NSColor) {
        guard let rgbColor = color.usingColorSpace(.deviceRGB) else { return }
        backgroundRed = Double(rgbColor.redComponent)
        backgroundGreen = Double(rgbColor.greenComponent)
        backgroundBlue = Double(rgbColor.blueComponent)
    }
}
