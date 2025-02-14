//
//  MovieDetailPopupView.swift
//  Watchlist
//
//  Created by Jake Murphy on 2/12/25.
//

import SwiftUI

struct MovieDetailPopupView: View {
    
    // Focus States
    @FocusState private var isRatingTextFieldFocused: Bool
    
    // Environment
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var movieDataManager: MovieDataManager
    @Environment(\.colorScheme) var colorScheme
    
    // UI States
    @State private var starRating: String = ""
    @State private var opacity: Double = 0
    @State private var imgHeight = 375.0
    @State private var imgWidth = 250.0
    @State private var screenHeight: CGFloat = 0
    @State private var clearButtonState = ButtonState.notPressed
    @State private var saveButtonState = ButtonState.notPressed
    
    let movie: String
    let movieIndex: Int
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
            .padding()
            
            VStack {
                saveButton()
            }
            .padding(.leading, 160)
            .padding(.trailing, -100)
        }
        .onAppear { // sets the current season and episode when opening this view
            starRating = String(format: "%.1f", movieDataManager.getUserRating(movieDataIndex: movieIndex) ?? "")
        }
        .padding(.bottom, screenHeight)
    }
    
    var starRatingTextField: some View {
        TextField("Star Rating", text: $starRating)
            .keyboardType(.decimalPad)
            .padding()
            .frame(width: 135, height: 30)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .focused($isRatingTextFieldFocused)
            .onChange(of: isRatingTextFieldFocused) {
                withAnimation {
                    screenHeight = isRatingTextFieldFocused ? 300 : 0
                }
                DispatchQueue.main.async {
                    UIApplication.shared.sendAction(#selector(UIResponder.selectAll(_:)), to: nil, from: nil, for: nil)
                }
            }
        
    }
    
    @ViewBuilder
    func saveButton() -> some View {
        
        if starRating != "" {
            
            Button("Save") {
                if starRating != "" {
                    movieDataManager.setUserRating(movieDataIndex: movieIndex, rating: convertStringtoCGFloat(string: starRating))
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
