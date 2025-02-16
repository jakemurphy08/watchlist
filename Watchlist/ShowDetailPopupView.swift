//
//  DetailPopupView.swift
//  Watchlist
//
//  Created by Jake Murphy on 2/6/25.
//

import SwiftUI
import SwiftData

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
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    // Struct Variables
    let showIndex: Int
    let showDataItem: WatchedShowDataItem
    
    init(showIndex: Int, showDataItem: WatchedShowDataItem) {
        self.showIndex = showIndex
        self.showDataItem = showDataItem
    }
    
    var body: some View {
        VStack {
            displayImageWithURL(imageURL: showDataItem.posterURL, imgWidth: imgWidth, imgHeight: imgHeight)
            
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
            currentSeason = getSeason() ?? ""
            currentEpisode = getEpisode() ?? ""
            starRating = String(format: "%.1f", getUserRating() ?? "")
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
            setSeason(season: nil)
            setEpisode(episode: nil)
            dismiss()
        }
        .styleButton(buttonState: clearButtonState, colorScheme: colorScheme)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in clearButtonState = .pressed }
                .onEnded { _ in clearButtonState = .notPressed }
        )
    }
    
    /// A button to save the user's current season, episode, and rating data.
    ///
    /// - Returns: The save data button.
    @ViewBuilder
    func saveButton() -> some View {
        
        if currentSeason != "" && currentEpisode != "" || starRating != "" { // can save seasons/episode data separate from starRating
            
            Button("Save") {
                if currentSeason != "" && currentEpisode != "" {
                    setSeason(season: currentSeason)
                    setEpisode(episode: currentEpisode)
                }
                
                if starRating != "" {
                    setUserRating(rating: convertStringtoCGFloat(string: starRating))
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
    
    /// Sets the season for a show.
    ///
    /// - Parameters:
    ///   - season: The season from the user input.
    ///
    /// - Returns: None.
    private func setSeason(season: String?) {
        showDataItem.currentSeason = season
    }
    
    /// Sets the episode for a show.
    ///
    /// - Parameters:
    ///   - season: The episode from the user input.
    ///
    /// - Returns: None.
    private func setEpisode(episode: String?) {
        showDataItem.currentEpisode = episode
    }
    
    /// Sets the rating for a show.
    ///
    /// - Parameters:
    ///   - season: The rating from the user input.
    ///
    /// - Returns: None.
    private func setUserRating(rating: CGFloat) {
        showDataItem.ratingOutOfTen = rating
    }
    
    /// Gets the season for a show.
    ///
    /// - Returns: The season from the stored data for a show.
    private func getSeason() -> String? {
        return showDataItem.currentSeason
    }
    
    /// Gets the episode for a show.
    ///
    /// - Returns: The episode from the stored data for a show.
    private func getEpisode() -> String? {
        return showDataItem.currentEpisode
    }
    
    /// Gets the rating for a show.
    ///
    /// - Returns: The rating from the stored data for a show.
    private func getUserRating() -> CGFloat? {
        return showDataItem.ratingOutOfTen
    }
}

#Preview {
    ContentView()
}
