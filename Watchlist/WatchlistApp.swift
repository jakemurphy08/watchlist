//
//  WatchlistApp.swift
//  Watchlist
//
//  Created by Jake Murphy on 1/31/25.
//

import SwiftUI
import SwiftData

@main
struct WatchlistApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }
        .modelContainer(for: [WatchedShowDataItem.self, UnwatchedShowDataItem.self, WatchedMovieDataItem.self, UnwatchedMovieDataItem.self])
    }
}
