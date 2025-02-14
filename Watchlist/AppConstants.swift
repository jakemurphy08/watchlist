//
//  Utilities.swift
//  Watchlist
//
//  Created by Jake Murphy on 2/13/25.
//

import SwiftUI


/// # Structs and Enums
public struct AppColors {
    static let mainColor = Color(red: 17/255, green: 22/255, blue: 66/255)
    static let secondaryColor = Color(red: 49/255, green: 56/255, blue: 112/255)
}

public enum MediaType {
    case movies
    case shows
}

public enum ButtonState {
    case pressed
    case notPressed
}

/// # Functions

/// Displays text using the correct font color.
///
/// - Parameters:
///     - text: The text to be displayed.
///     - isBold: True if the text should be bold.
///     - colorScheme: The appearance mode of the phone. Either `light` or `dark`.
///
///  - Returns: The text view with the given text.
public func displayText(text: String, isBold: Bool = false, colorScheme: ColorScheme) -> some View {
    Text(text)
        .changeAppearance(colorScheme: colorScheme)
        .bold(isBold)
}

/// Displays an image
///
/// - Parameters:
///   - imageURL: The url to the image.
///   - imgWidth: The width of the image.
///   - imgHeight: The height of the image.
///   - cornerRadius: How rounded the corners of the image are
///
/// - Returns: The view for the image.
public func displayImageWithURL(imageURL: String?, imgWidth: CGFloat, imgHeight: CGFloat, cornerRadius: CGFloat = 10) -> some View {
    AsyncImage(url: URL(string: imageURL ?? "")) { image in
        image
            .resizable()
            .frame(width: imgWidth, height: imgHeight)
            .cornerRadius(cornerRadius)
    } placeholder: {
        ProgressView("Loading...")
    }
    .padding(10)
}

/// Displays the headers for the show/movie lists on the homepage of the app.
///
/// - Parameters:
///   - mediaType: Either `show` or `movie`.
///   - colorScheme: The appearance mode of the phone. Either `light` or `dark`.
///
/// - Returns: An HStack containing the headers.
public func displayListHeaders(mediaType: MediaType, colorScheme: ColorScheme) -> some View {
    HStack {
        Text(mediaType == .shows ? "SHOWS" : "MOVIES")
            .styleListHeaderText(colorScheme, position: .leading)
        Spacer()
        EditButton()
            .styleListHeaderText(colorScheme, position: .trailing)
            .textCase(.uppercase)
    }
}

/// Convert a string to a CGFloat.
///
/// - Parameters:
///   - string: The string to convert to a CGFloat.
///
/// - Returns: The converted CGFloat.
public func convertStringtoCGFloat(string: String) -> CGFloat {
    if let doubleValue = Double(string) {
        return CGFloat(doubleValue)
    } else {
        return 0.0
    }
}
