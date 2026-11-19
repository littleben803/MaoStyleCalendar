#if os(iOS)
import SwiftUI
import UIKit
import CalendarCore

/// Wallpaper artwork placement is shared by preview and exported pixels.
enum WallpaperSafeComposition {
    static func artworkRect(in size: CGSize) -> CGRect {
        let height = size.width * 1.5
        // Keep the previous vertical center, 3% below the middle of the canvas.
        return CGRect(x: 0, y: size.height * 0.53 - height / 2,
                      width: size.width, height: height)
    }
}

struct ArtworkWallpaperCanvas: View {
    @Environment(\.locale) private var locale
    let page: ArtworkPage
    let image: UIImage?
    var showsQuote = true
    private static let artworkEdgeFade = LinearGradient(stops: [
        .init(color: .clear, location: 0),
        .init(color: .black.opacity(0.20), location: 0.01),
        .init(color: .black.opacity(0.90), location: 0.027),
        .init(color: .black, location: 0.04),
        .init(color: .black, location: 0.94),
        .init(color: .black.opacity(0.90), location: 0.96),
        .init(color: .black.opacity(0.45), location: 0.98),
        .init(color: .clear, location: 1)
    ], startPoint: .top, endPoint: .bottom)

    var body: some View {
        GeometryReader { geometry in
            let rect = WallpaperSafeComposition.artworkRect(in: geometry.size)
            ZStack(alignment: .topLeading) {
                artworkColor(page.paperColor)
                if let paper = paperStrip {
                    Image(uiImage: paper).resizable(resizingMode: .tile)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .opacity(0.45)
                }
                ArtworkPageSurface(sample: page, showsQuote: showsQuote,
                                   imageOverride: { image }, artworkEdgeFade: Self.artworkEdgeFade)
                .frame(width: rect.width, height: rect.height)
                .position(x: rect.midX, y: rect.midY)
            }
        }
        .clipped()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(showsQuote ? page.localizedAccessibleQuote(locale: locale) : locale.calendarText("仅插画", "Artwork Only"))
    }

    private var paperStrip: UIImage? {
        guard let image = image?.cgImage,
              let strip = image.cropping(to: CGRect(x: 0, y: 0, width: image.width, height: 100)) else { return nil }
        return UIImage(cgImage: strip, scale: 3, orientation: .up)
    }
}
#endif
