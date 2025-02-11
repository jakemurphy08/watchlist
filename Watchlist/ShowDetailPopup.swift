//
//  ShowDetailPopup.swift
//  Watchlist
//
//  Created by Jake Murphy on 2/6/25.
//

import SwiftUI

public enum ButtonState {
    case pressed
    case notPressed
}

struct ShowDetailPopup: View {
    
    @State private var imgHeight = 375.0
    @State private var imgWidth = 250.0
    @FocusState private var isFocused: Bool
    @State private var screenHeight: CGFloat = 0
    @Environment(\.dismiss) var dismiss
    @State var currentEpisode: String = ""
    @State var currentSeason: String = ""
    @State private var opacity: Double = 0
    @EnvironmentObject var showDataManager: ShowDataManager
    @Environment(\.colorScheme) var colorScheme
    @State private var clearButtonState = ButtonState.notPressed
    @State private var saveButtonState = ButtonState.notPressed
    let show: String
    let showIndex: Int
    let posterURL: String?
    
    var body: some View {
        VStack {
            displayImage(imageURL: posterURL, imgWidth: imgWidth, imgHeight: imgHeight)
            
            HStack {
                Text("Season: ")
                    .font(.system(size: 13))
                seasonTextField(fieldText: "")
                Text("...and episode: ")
                    .font(.system(size: 13))
                episodeTextField(fieldText: "", showDataIndex: showIndex)
            }
            .padding()
            
            VStack {
                clearButton(showDataIndex: showIndex)
                saveButton(showDataIndex: showIndex)
            }
            .padding(.leading, 170)
            .padding(.trailing, -100)
        }
        .onAppear { // sets the current season and episode when opening this view
            currentSeason = showDataManager.getSeason(showDataIndex: showIndex) ?? ""
            currentEpisode = showDataManager.getEpisode(showDataIndex: showIndex) ?? ""
        }
        .padding(.bottom, screenHeight)
    }
    
    func seasonTextField(fieldText: String) -> some View {
        TextField(fieldText, text: $currentSeason)
            .padding()
            .keyboardType(.numberPad)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .focused($isFocused)
            .onChange(of: isFocused) {
                withAnimation {
                    screenHeight = isFocused ? 200 : 0
                }
            }
    }
    
    func episodeTextField(fieldText: String, showDataIndex: Int) -> some View {
        TextField(fieldText, text: $currentEpisode)
            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(.numberPad)
//            .onSubmit {
//                showDataManager.setSeason(showDataIndex: showDataIndex, season: Int(currentSeason) ?? 1)
//                showDataManager.setEpisode(showDataIndex: showDataIndex, episode: Int(currentEpisode) ?? 1)
//                dismiss()
//            }
            .focused($isFocused)
            .onChange(of: isFocused) {
                withAnimation {
                    screenHeight = isFocused ? 200 : 0
                }
            }
    }
    
    @ViewBuilder
    func clearButton(showDataIndex: Int) -> some View {
        
        Button("Clear Show Data") {
            showDataManager.setSeason(showDataIndex: showDataIndex, season: nil)
            showDataManager.setEpisode(showDataIndex: showDataIndex, episode: nil)
            dismiss()
        }
        .styleButton(buttonState: clearButtonState, colorScheme: colorScheme)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in clearButtonState = .pressed }
                .onEnded { _ in clearButtonState = .notPressed }
        )
    }
    
    @ViewBuilder
    func saveButton(showDataIndex: Int) -> some View {
        
        if currentSeason != "" && currentEpisode != "" {
            
            Button("Save") {
                showDataManager.setSeason(showDataIndex: showDataIndex, season: currentSeason)
                showDataManager.setEpisode(showDataIndex: showDataIndex, episode: currentEpisode)
                dismiss()
            }
            .styleButton(buttonState: saveButtonState, colorScheme: colorScheme)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in saveButtonState = .pressed }
                    .onEnded { _ in saveButtonState = .notPressed }
            )
            .padding(.leading, 90)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 0.5)) {
                    opacity = 1
                }
            }
        }
    }
    
    /// Displays an image
    ///
    /// - Parameters:
    ///   - imageURL: The url to the image.
    ///   - imgWidth: The width of the image.
    ///   - imgHeight: The height of the image.
    ///   - cornerRadius: How rounded the corners of the image are
    ///
    /// - Returns: None.
    func displayImage(imageURL: String?, imgWidth: CGFloat, imgHeight: CGFloat, cornerRadius: CGFloat = 10) -> some View {
        AsyncImage(url: URL(string: imageURL ?? "")) { image in
            image
                .resizable()
                .frame(width: imgWidth, height: imgHeight)
                .cornerRadius(cornerRadius)
                .shadow(radius: 10)
        } placeholder: {
            ProgressView("Loading...")
        }
    }
    
    /// Displays text using the correct font color.
    ///
    /// - Parameters:
    ///     - text: The text to be displayed.
    ///     - isBold: True if the text should be bold.
    ///
    ///  - Returns: The text view with the given text.
    func displayText(text: String, isBold: Bool = false) -> some View {
        Text(text)
            .foregroundStyle(colorScheme == .dark ? Color.white : AppColors.mainColor)
            .bold(isBold)
    }
}

#Preview {
    ContentView()
}
