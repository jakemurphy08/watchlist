//
//  ContentView.swift
//  Watchlist
//
//  Created by Jake Murphy on 1/31/25.
//

import SwiftUI
import SwiftData

struct UpNextView: View {
    
    // Environment
    @Environment(\.colorScheme) var colorScheme

    // UI states
    @State private var mediaType: MediaType = .shows
    @State private var isAnimated: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                Picker("Select Media", selection: $mediaType) {
                    Text("Shows").tag(MediaType.shows)
                    Text("Movies").tag(MediaType.movies)
                }
                .styleSegmentedPicker()
                
                ZStack {
                    if mediaType == .shows {
                        UpNextShowScreen()
                            .transition(.move(edge: .leading))
                    } else {
                        UpNextMovieScreen()
                            .transition(.move(edge: .trailing))
                    }
                }
                .animation(.default, value: mediaType)

            }
        }
    }
}

#Preview {
    UpNextView()
}
