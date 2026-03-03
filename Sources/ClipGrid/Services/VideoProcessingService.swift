import AVFoundation
import AppKit
import Foundation

struct VideoMetadata {
    let fileSize: Int64
}

struct VideoRenderMetadata {
    let duration: TimeInterval
    let resolution: CGSize
}

struct ThumbnailFrame {
    let image: NSImage
    let timestamp: TimeInterval
}

enum VideoProcessingError: LocalizedError {
    case unreadableVideo
    case noFramesGenerated

    var errorDescription: String? {
        switch self {
        case .unreadableVideo:
            return AppStrings.unreadableVideo
        case .noFramesGenerated:
            return AppStrings.noThumbnails
        }
    }
}

enum VideoProcessingService {
    static func loadMetadata(for url: URL) async throws -> VideoMetadata {
        let values = try url.resourceValues(forKeys: [.fileSizeKey])
        let bytes = Int64(values.fileSize ?? 0)
        return VideoMetadata(
            fileSize: bytes
        )
    }

    static func loadRenderMetadata(for url: URL) async throws -> VideoRenderMetadata {
        let asset = AVAsset(url: url)
        let duration = try await asset.load(.duration)
        let tracks = try await asset.loadTracks(withMediaType: .video)
        let resolution = try await resolvedVideoSize(from: tracks.first)
        return VideoRenderMetadata(
            duration: duration.seconds.isFinite ? duration.seconds : 0,
            resolution: resolution
        )
    }

    static func generateThumbnails(
        for url: URL,
        count: Int,
        maxSize: CGSize
    ) async throws -> [ThumbnailFrame] {
        let asset = AVAsset(url: url)
        let duration = try await asset.load(.duration)
        let seconds = max(duration.seconds, 0.1)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.maximumSize = maxSize
        generator.appliesPreferredTrackTransform = true
        let toleranceSeconds = min(max(seconds / Double(max(count, 1)) / 3, 0.1), 2.0)
        let tolerance = CMTime(seconds: toleranceSeconds, preferredTimescale: 600)
        generator.requestedTimeToleranceBefore = tolerance
        generator.requestedTimeToleranceAfter = tolerance

        let timestamps = frameTimes(duration: seconds, count: count)
        var thumbnails: [ThumbnailFrame] = []
        thumbnails.reserveCapacity(timestamps.count)

        for second in timestamps {
            let time = CMTime(seconds: second, preferredTimescale: 600)
            do {
                let image = try generator.copyCGImage(at: time, actualTime: nil)
                thumbnails.append(
                    ThumbnailFrame(
                        image: NSImage(cgImage: image, size: .zero),
                        timestamp: second
                    )
                )
            } catch {
                continue
            }
        }

        guard !thumbnails.isEmpty else {
            throw VideoProcessingError.noFramesGenerated
        }

        return thumbnails
    }

    private static func frameTimes(duration: TimeInterval, count: Int) -> [TimeInterval] {
        guard count > 0 else { return [] }
        if count == 1 {
            return [duration / 2]
        }

        let usableDuration = max(duration, 0.1)
        let start = usableDuration * 0.05
        let end = usableDuration * 0.95
        let step = (end - start) / Double(count - 1)
        return (0..<count).map { start + Double($0) * step }
    }

    private static func resolvedVideoSize(from track: AVAssetTrack?) async throws -> CGSize {
        guard let track else { return .zero }
        let naturalSize = try await track.load(.naturalSize)
        let transform = try await track.load(.preferredTransform)
        return naturalSize.applying(transform).absoluteSize
    }
}

private extension CGSize {
    var absoluteSize: CGSize {
        CGSize(width: abs(width), height: abs(height))
    }
}
