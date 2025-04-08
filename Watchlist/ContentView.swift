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
    @State private var isAnimated: Bool = false
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    HStack {
                        Spacer()
                        Picker("Select Media", selection: $mediaType) {
                            Text("Shows").tag(MediaType.shows)
                            Text("Movies").tag(MediaType.movies)
                        }
                        .styleSegmentedPicker()
                        
                        Spacer()
                    }
                    
                    ZStack {
                        if mediaType == .shows {
                            ShowScreen()
                                .transition(.move(edge: .leading))
                        } else {
                            MovieScreen()
                                .transition(.move(edge: .trailing))
                        }
                    }
                    .animation(.default, value: mediaType)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
