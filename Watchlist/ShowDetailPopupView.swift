//
//  DetailPopupView.swift
//  Watchlist
//
//  Created by Jake Murphy on 2/6/25.
//

import SwiftUI

struct ShowDetailPopupView: View {
    
    
    // Focus States
    @FocusState private var shiftScreenHeightWhileTextFieldFocused: Bool
    
    // UI States
    @State private var imgHeight = 375.0
    @State private var imgWidth = 250.0
    @State private var screenHeight: CGFloat = 0
    @State private var starRating: String = ""
    @State var currentSeason: String = ""
    @State var currentEpisode: String = ""
    @State private var opacity: Double = 0
    @State private var clearButtonState = ButtonState.notPressed
    @State private var saveButtonState = ButtonState.notPressed
    
    // Environment
    @EnvironmentObject var showDataManager: ShowDataManager
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    // Struct Variables
    let show: String
    let showIndex: Int
    let posterURL: String?
    
    var body: some View {
        VStack {
            displayImageWithURL(imageURL: posterURL, imgWidth: imgWidth, imgHeight: imgHeight)
            
            HStack {
                Image(systemName: "star.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.yellow)
                starRatingTextField
            }
            .frame(height: 30)
            
            HStack {
                seasonTextField(fieldText: "Season: ")
                episodeTextField(fieldText: "...and episode: ", showDataIndex: showIndex)
            }
            .padding()
            
            VStack {
                clearButton()
                saveButton()
            }
            .padding(.leading, 160)
            .padding(.trailing, -100)
        }
        .onAppear { // sets the current season and episode when opening this view
            currentSeason = showDataManager.getSeason(showDataIndex: showIndex) ?? ""
            currentEpisode = showDataManager.getEpisode(showDataIndex: showIndex) ?? ""
            starRating = String(format: "%.1f", showDataManager.getUserRating(showDataIndex: showIndex) ?? "")
        }
        .padding(.bottom, screenHeight)
    }
    
    /// Creates the text field for the user to input their rating of a particular show out of ten.
    ///
    /// - Returns: The view of the text field to enter a rating into.
    var starRatingTextField: some View {
        TextField("Star Rating", text: $starRating)
            .keyboardType(.decimalPad)
            .padding()
            .frame(width: 135, height: 30)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .focused($shiftScreenHeightWhileTextFieldFocused)
            .onChange(of: shiftScreenHeightWhileTextFieldFocused) {
                withAnimation {
                    screenHeight = shiftScreenHeightWhileTextFieldFocused ? 300 : 0
                }
                DispatchQueue.main.async {
                    UIApplication.shared.sendAction(#selector(UIResponder.selectAll(_:)), to: nil, from: nil, for: nil)
                }
            }
        
    }
    
    /// Unused function, but don't want to remove in case I want to come back to it.
    var backButton: some View {
        Button {
            dismiss()
        } label: {
                Image(systemName: "arrowshape.backward")
                .padding()
                .changeAppearance(colorScheme: colorScheme)
        }
    }
    
    /// The text field for the user to enter their current season.
    ///
    /// - Parameters:
    ///   - fieldText: The user's current season input.
    ///
    /// - Returns: The view of the text field.
    func seasonTextField(fieldText: String) -> some View {
        TextField(fieldText, text: $currentSeason)
            .padding()
            .keyboardType(.numberPad)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .focused($shiftScreenHeightWhileTextFieldFocused)
            .onChange(of: shiftScreenHeightWhileTextFieldFocused) {
                withAnimation {
                    screenHeight = shiftScreenHeightWhileTextFieldFocused ? 300 : 0
                }
                DispatchQueue.main.async {
                    UIApplication.shared.sendAction(#selector(UIResponder.selectAll(_:)), to: nil, from: nil, for: nil)
                }
            }

    }
    
    /// The text field for the user to enter their current episode.
    ///
    /// - Parameters:
    ///   - fieldText: The user's current episode input.
    ///
    /// - Returns: The view of the text field.
    func episodeTextField(fieldText: String, showDataIndex: Int) -> some View {
        TextField(fieldText, text: $currentEpisode)
            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(.numberPad)
            .focused($shiftScreenHeightWhileTextFieldFocused)
            .onChange(of: shiftScreenHeightWhileTextFieldFocused) {
                withAnimation {
                    screenHeight = shiftScreenHeightWhileTextFieldFocused ? 300 : 0
                }
                DispatchQueue.main.async {
                    UIApplication.shared.sendAction(#selector(UIResponder.selectAll(_:)), to: nil, from: nil, for: nil)
                }
            }
    }
    
    /// A button to clear the user's current season and episode data.
    /// TODO!: Create a popup for the user to confirm they want to remove their stat data.
    ///
    /// - Returns: The clear data button.
    @ViewBuilder
    func clearButton() -> some View {
        
        Button("Clear Current Spot") {
            showDataManager.setSeason(showDataIndex: showIndex, season: nil)
            showDataManager.setEpisode(showDataIndex: showIndex, episode: nil)
            dismiss()
        }
        .styleButton(buttonState: clearButtonState, colorScheme: colorScheme)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in clearButtonState = .pressed }
                .onEnded { _ in clearButtonState = .notPressed }
        )
    }
    
    /// A button to save the user's current season and episode data.
    ///
    /// - Returns: The save data button.
    @ViewBuilder
    func saveButton() -> some View {
        
        if currentSeason != "" && currentEpisode != "" || starRating != "" { // can save seasons/episode data separate from starRating
            
            Button("Save") {
                if currentSeason != "" && currentEpisode != "" {
                    showDataManager.setSeason(showDataIndex: showIndex, season: currentSeason)
                    showDataManager.setEpisode(showDataIndex: showIndex, episode: currentEpisode)
                }
                
                if starRating != "" {
                    showDataManager.setUserRating(showDataIndex: showIndex, rating: convertStringtoCGFloat(string: starRating))
                }
                
                dismiss()
            }
            .styleButton(buttonState: saveButtonState, colorScheme: colorScheme)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in saveButtonState = .pressed }
                    .onEnded { _ in saveButtonState = .notPressed }
            )
            .padding(.leading, 105)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 0.5)) {
                    opacity = 1
                }
            }
        }
    }
    
    
    /// Convert a string to a CGFloat.
    ///
    /// - Parameters:
    ///   - string: The string to convert to a CGFloat.
    ///
    /// - Returns: The converted CGFloat.
    func convertStringtoCGFloat(string: String) -> CGFloat {
        if let doubleValue = Double(string) {
            return CGFloat(doubleValue)
        } else {
            return 0.0
        }
    }
}

#Preview {
    ContentView()
}
