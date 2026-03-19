import AppKit
import Foundation

@MainActor
final class VideoItem: ObservableObject, Identifiable {
    enum Status: Equatable {
        case idle
        case generating
        case ready
        case exporting
        case exported(URL)
        case failed(String)

        var label: String {
            switch self {
            case .idle: AppStrings.statusReady
            case .generating: AppStrings.statusGenerating
            case .ready: AppStrings.statusReadyDone
            case .exporting: AppStrings.statusExporting
            case .exported: AppStrings.statusExported
            case .failed(let message): message
            }
        }
    }

    let id = UUID()
    let url: URL
    let fileName: String
    var duration: TimeInterval
    let fileSize: Int64
    var resolution: CGSize
    var bitrateBitsPerSecond: Int64
    var videoCodec: String
    var audioCodecs: [String]

    @Published var previewImage: NSImage?
    @Published var status: Status = .idle

    init(
        url: URL,
        duration: TimeInterval,
        fileSize: Int64,
        resolution: CGSize = .zero,
        bitrateBitsPerSecond: Int64 = 0,
        videoCodec: String = "",
        audioCodecs: [String] = []
    ) {
        self.url = url
        self.fileName = url.lastPathComponent
        self.duration = duration
        self.fileSize = fileSize
        self.resolution = resolution
        self.bitrateBitsPerSecond = bitrateBitsPerSecond
        self.videoCodec = videoCodec
        self.audioCodecs = audioCodecs
    }
}
