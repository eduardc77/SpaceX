//
//  AsyncImageView.swift
//  SpaceXSharedUI
//
//  Created by User on 6/24/25.
//

import SwiftUI
import Kingfisher
import SpaceXUtilities

public struct AsyncImageView: View {
    let url: URL?
    let size: CGSize
    let cornerRadius: CGFloat
    let showPlaceholder: Bool
    let placeholderIcon: String
    let contentMode: SwiftUI.ContentMode
    let context: String // For logging
    
    public init(
        url: URL?,
        size: CGSize,
        cornerRadius: CGFloat = 8,
        showPlaceholder: Bool = true,
        placeholderIcon: String = "photo",
        contentMode: SwiftUI.ContentMode = .fit,
        context: String = "Unknown"
    ) {
        self.url = url
        self.size = size
        self.cornerRadius = cornerRadius
        self.showPlaceholder = showPlaceholder
        self.placeholderIcon = placeholderIcon
        self.contentMode = contentMode
        self.context = context
    }
    
    public var body: some View {
        KFImage(url)
            .placeholder {
                if url != nil {
                    // Show loading indicator when image URL exists
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.gray.opacity(0.1))
                        .overlay(
                            ProgressView()
                                .scaleEffect(0.8)
                        )
                } else if showPlaceholder {
                    // Show placeholder when no image URL
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: placeholderIcon)
                                .foregroundColor(.gray)
                                .font(.system(size: min(size.width, size.height) * 0.3))
                        )
                } else {
                    Color.clear
                }
            }
            .onFailure { error in
                if url != nil {
                    // Handle different types of errors
                    let isTimeoutError = (error as NSError).code == -1001
                    let isNetworkError = (error as NSError).domain == NSURLErrorDomain
                    
                    if isTimeoutError {
                        SpaceXLogger.error("⏱️ Image timeout for \(context): \(url?.absoluteString ?? "unknown")")
                    } else if isNetworkError {
                        SpaceXLogger.error("🌐 Network error for \(context): \(error.localizedDescription)")
                    } else if case .processorError = error {
                        // Clear this specific image from cache if processing failed
                        if let url = url {
                            ImageCache.default.removeImage(forKey: url.absoluteString)
                        }
                        SpaceXLogger.error("🖼️ Image processing failed for \(context): \(error.localizedDescription)")
                    } else {
                        SpaceXLogger.error("❌ Image loading failed for \(context): \(error.localizedDescription)")
                    }
                }
            }
            .retry(maxCount: 2, interval: .seconds(1.0))
            .scaleFactor(UIScreen.main.scale)
            .setProcessor(DownsamplingImageProcessor(size: size))
            .resizable()
            .aspectRatio(contentMode: contentMode)
            .frame(width: size.width, height: size.height)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

#Preview {
    AsyncImageView(
        url: URL(string: "https://images2.imgbox.com/eb/0f/Vev7xkUX_o.png"),
        size: CGSize(width: 50, height: 50),
        placeholderIcon: "airplane.departure",
        context: "Test Mission"
    )
}
