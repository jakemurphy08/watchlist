//
//  StarRatingView.swift
//  Watchlist
//
//  Created by Jake Murphy on 2/12/25.
//

import SwiftUI

extension ContentView {
    
    /// Displays the star rating. Depending on the user's rating, the star will fill in to that percentage with yellow.
    ///
    /// - Parameters:
    ///   - rating: The rating given by the user on a particular show/movie.
    ///
    /// - Returns: The view of the star on the homescreen.
    func StarRatingOverlay(rating: CGFloat) -> some View {
        VStack {
            ZStack {
                
                Image(systemName: "star.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.yellow)
                    .mask(
                        GeometryReader { geo in
                            Rectangle()
                                .frame(width: geo.size.width * (rating / 10.0))
                        }
                    )
                
                Image(systemName: "star")
                    .resizable()
                    .changeAppearance(colorScheme: colorScheme)
                    .opacity(0.3)
            }
            .frame(width: 25, height: 25)
            
            Text("\(String(format: "%.1f", rating))")
                .font(.system(size: 8))
        }
        .frame(width: 35, height:35)
    }
}

#Preview {
    ContentView()
}
