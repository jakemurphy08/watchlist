//
//  MovieDetailPopupView.swift
//  Watchlist
//
//  Created by Jake Murphy on 2/12/25.
//

import SwiftUI

struct MovieDetailPopupView: View {
    
    // Focus States
    @FocusState private var shiftScreenHeightWhileTextFieldFocused: Bool
    
    // Environment
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var context
    
    // UI States
    @State private var starRating: String = ""
    @State private var opacity: Double = 0
    @State private var imgHeight = 375.0
    @State private var imgWidth = 250.0
    @State private var screenHeight: CGFloat = 0
    @State private var clearButtonState = ButtonState.notPressed
    @State private var saveButtonState = ButtonState.notPressed
    @State private var isRatingBeingChanged: Bool = false
    
    // Local Variables
    let movieIndex: Int
    let movieDataItem: WatchedMovieDataItem
    
    init(movieIndex: Int, movieDataItem: WatchedMovieDataItem) {
        self.movieIndex = movieIndex
        self.movieDataItem = movieDataItem
    }
    
    var body: some View {
        VStack {
            displayImageWithURL(imageURL: movieDataItem.posterURL, imgWidth: imgWidth, imgHeight: imgHeight)
            
            HStack {
                Image(systemName: "star.fill")
                    .resizable()
                    .scaledToFit()
                    .changeAppearance(colorScheme: colorScheme)
                starRatingTextField
            }
            .frame(height: 30)
            .padding()
            
            VStack {
                saveButton()
            }
            .padding(.leading, 180)
        }
        .onAppear { // sets the current season and episode when opening this view
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
                    isRatingBeingChanged = true
                }
                DispatchQueue.main.async {
                    UIApplication.shared.sendAction(#selector(UIResponder.selectAll(_:)), to: nil, from: nil, for: nil)
                }
            }
        
    }
    
    /// A button to save the user's rating for a movie.
    ///
    /// - Returns: The save data button.
    @ViewBuilder
    func saveButton() -> some View {
        
        if isRatingBeingChanged == true {
            
            Button("Save") {
                setUserRating(rating: convertStringtoCGFloat(string: starRating))
                
                
                try? context.save()
                
                dismiss()
            }
            .styleButton(buttonState: saveButtonState, colorScheme: colorScheme)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in saveButtonState = .pressed }
                    .onEnded { _ in saveButtonState = .notPressed }
            )
            .padding(.leading, 105)
            .transition(.move(edge: .trailing))
        }
    }
    
    /// Sets the rating for a show.
    ///
    /// - Parameters:
    ///   - season: The rating from the user input.
    ///
    /// - Returns: None.
    private func setUserRating(rating: CGFloat) {
        movieDataItem.ratingOutOfTen = rating
    }
    
    /// Gets the rating for a show.
    ///
    /// - Returns: The rating from the stored data for a show.
    private func getUserRating() -> CGFloat? {
        return movieDataItem.ratingOutOfTen
    }
}

#Preview {
    ContentView()
}
