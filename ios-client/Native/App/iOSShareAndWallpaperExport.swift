#if os(iOS)
import CalendarCore
import SwiftUI
import UIKit

struct ShareRequest: Identifiable {
    let id = UUID()
    let activityItems: [Any]
}

struct ActivityShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let onSaveToPhotos: () -> Void

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        controller.completionWithItemsHandler = { activity, completed, _, error in
            guard activity == .saveToCameraRoll, completed, error == nil else { return }
            onSaveToPhotos()
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

enum WallpaperExportError: LocalizedError {
    case renderingFailed
    case pngEncodingFailed
    case jpegEncodingFailed

    var errorDescription: String? { message(locale: .current) }

    func message(locale: Locale) -> String {
        switch self {
        case .renderingFailed:
            locale.calendarText("无法渲染高清壁纸", "Unable to render the wallpaper.")
        case .pngEncodingFailed:
            locale.calendarText("无法生成 PNG 文件", "Unable to create the PNG file.")
        case .jpegEncodingFailed:
            locale.calendarText("无法生成 JPG 文件", "Unable to create the JPG file.")
        }
    }
}

@MainActor
enum WallpaperExporter {
    static func export(content: DailyContentPack, layout: WallpaperLayout, locale: Locale = .current) throws -> URL {
        if DailyArtworkCatalog.page(contentID: content.id) != nil {
            return try exportArtwork(content: content, layout: layout, locale: locale)
        }
        let pixelSize = portraitPixelSize
        let canvas = WallpaperCompositionCanvas(content: content, layout: layout)
            .environment(\.locale, locale)
            .frame(width: pixelSize.width, height: pixelSize.height)
        let renderer = ImageRenderer(content: canvas)
        renderer.proposedSize = ProposedViewSize(pixelSize)
        renderer.scale = 1
        renderer.isOpaque = true

        guard let image = renderer.uiImage else {
            throw WallpaperExportError.renderingFailed
        }
        guard let data = image.pngData() else {
            throw WallpaperExportError.pngEncodingFailed
        }

        let safeLayout = layout.rawValue.lowercased()
        let filename = "maostyle-MOCK-\(content.id)-\(safeLayout)-\(Int(pixelSize.width))x\(Int(pixelSize.height)).png"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename, isDirectory: false)
        try data.write(to: url, options: .atomic)
        return url
    }

    static var outputPixelSize: CGSize {
        let native = portraitPixelSize
        let scale = min(1, 1440 / native.width, 3200 / native.height)
        return CGSize(width: floor(native.width * scale), height: floor(native.height * scale))
    }

    private static func exportArtwork(content: DailyContentPack, layout: WallpaperLayout, locale: Locale = .current) throws -> URL {
        let size = outputPixelSize
        let canvas = WallpaperCompositionCanvas(content: content, layout: layout)
            .environment(\.locale, locale)
            .frame(width: size.width, height: size.height)
        let renderer = ImageRenderer(content: canvas)
        renderer.proposedSize = ProposedViewSize(size)
        renderer.scale = 1
        renderer.isOpaque = true
        guard let image = renderer.uiImage else { throw WallpaperExportError.renderingFailed }
        guard let data = image.jpegData(compressionQuality: 0.85) else { throw WallpaperExportError.jpegEncodingFailed }
        let name = "maostyle-\(content.id)-\(layout.rawValue)-\(Int(size.width))x\(Int(size.height)).jpg"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        try data.write(to: url, options: .atomic)
        return url
    }

    static var portraitPixelSize: CGSize {
        let native = UIScreen.main.nativeBounds.size
        return CGSize(width: min(native.width, native.height), height: max(native.width, native.height))
    }
}

#endif
