//
//  ContentView.swift
//  Watchlist
//
//  Created by Jake Murphy on 1/31/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    // Environment
    @Environment(\.colorScheme) var colorScheme

    // UI states
    @State private var mediaType: MediaType = .shows
    
    
    var body: some View {
        ZStack {
            VStack {
                Picker("Select Media", selection: $mediaType) {
                    Text("Shows").tag(MediaType.shows)
                    Text("Movies").tag(MediaType.movies)
                }
                .styleSegmentedPicker()
                
                if mediaType == .shows {
                    ShowScreen()
                } else {
                    MovieScreen()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
