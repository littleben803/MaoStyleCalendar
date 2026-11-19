#if os(iOS)
import CalendarCore
import Foundation
import ImageIO
import UIKit

@MainActor
enum ArtworkPageImages {
    private static let cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.totalCostLimit = 32 * 1024 * 1024
        return cache
    }()
    private static let previewDecoder = PreviewDecoder()

    static func image(_ page: ArtworkPage) -> UIImage? {
        guard let url = DailyArtworkCatalog.directory?.appendingPathComponent(page.filename) else { return nil }
        let key = url.path as NSString
        if let cached = cache.object(forKey: key) { return cached }
        guard let cgImage = decode(url, immediately: false) else { return nil }
        return cacheImage(cgImage, for: key)
    }

    static func previewImage(_ page: ArtworkPage) async -> UIImage? {
        guard !Task.isCancelled,
              let url = DailyArtworkCatalog.directory?.appendingPathComponent(page.filename) else { return nil }
        guard let cgImage = await previewDecoder.decode(url), !Task.isCancelled else { return nil }
        return UIImage(cgImage: cgImage)
    }

    private static func cacheImage(_ cgImage: CGImage, for key: NSString) -> UIImage {
        let image = UIImage(cgImage: cgImage)
        cache.setObject(image, forKey: key, cost: cgImage.bytesPerRow * cgImage.height)
        return image
    }

    private nonisolated static func decode(_ url: URL, immediately: Bool) -> CGImage? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        return CGImageSourceCreateThumbnailAtIndex(source, 0, [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: 1536,
            kCGImageSourceShouldCacheImmediately: immediately
        ] as CFDictionary)
    }

    // Preview cache contains eagerly decoded pixels only. The shared synchronous cache may
    // contain lazy images from other screens and must not feed the scrolling preview.
    private actor PreviewDecoder {
        private let cache: NSCache<NSURL, CGImage> = {
            let cache = NSCache<NSURL, CGImage>()
            cache.totalCostLimit = 32 * 1024 * 1024
            return cache
        }()

        func decode(_ url: URL) -> CGImage? {
            guard !Task.isCancelled else { return nil }
            if let image = cache.object(forKey: url as NSURL) { return image }
            assert(!Thread.isMainThread)
            guard let image = ArtworkPageImages.decode(url, immediately: true),
                  !Task.isCancelled else { return nil }
            cache.setObject(image, forKey: url as NSURL, cost: image.bytesPerRow * image.height)
            return image
        }
    }
}
#endif
