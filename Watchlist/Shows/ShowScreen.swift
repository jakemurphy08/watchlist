//
//  ShowScreen.swift
//  Watchlist
//
//  Created by Jake Murphy on 2/16/25.
//

import SwiftUI
import SwiftData

struct ShowScreen: View {
    
    // Environment
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var context
    
    // Focus states
    @FocusState private var isTextFieldFocused: Bool
    @FocusState private var isSearching: Bool
    
    // UI States
    @State private var buttonState = ButtonState.notPressed
    
    // Data Pullers
    @Query private var watchedShowDataItems: [WatchedShowDataItem]
    
    var body: some View {
        ZStack {
            VStack {
                displayShowList(isSearching: isSearching)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        addShowButton
                            .styleButton(buttonState: buttonState, colorScheme: colorScheme)
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { _ in buttonState = .pressed }
                                    .onEnded { _ in buttonState = .notPressed })
                    }
                    .padding()
                    .padding(.trailing, -45)
                    .padding(.bottom, 70)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    displayText(text: "Your Rankings", isBold: true, colorScheme: colorScheme)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: UpNextView()) {
                        displayText(text: "Up Next", colorScheme: colorScheme)
                    }
                }
            }
        }
    }
    
    /// Creates the button for `Add Show`
    var addShowButton: some View {
        NavigationLink("Add Show", destination: SearchNewShowScreen())
    }
    
    /// Displays the ranked list of shows.
    ///
    /// - Parameters:
    ///   - isSearching: True if the text field search bar is active when someone pressed `Add Show`.
    ///
    /// - Returns: The view of the list.
    @ViewBuilder
    func displayShowList(isSearching: Bool) -> some View {
        ZStack {
            if isSearching == false {
                VStack(spacing: 0) {
                    
                    displayListHeaders(mediaType: .shows, colorScheme: colorScheme)
                    
                    List {
                        if watchedShowDataItems.isEmpty {
                            displayText(text: "You haven't added any shows yet!", colorScheme: colorScheme)
                        } else {
                            ForEach(watchedShowDataItems, id: \.self) { showInList in
                                if let showIndex = watchedShowDataItems.firstIndex(of: showInList) {
                                    NavigationLink(destination: ShowDetailPopupView(showIndex: showIndex, showDataItem: showInList)) {
                                        HStack {
                                            StarRatingOverlay(rating: showInList.ratingOutOfTen ?? 0.0, colorScheme: colorScheme)
                                            displayText(text: "\(showInList.show)" + " " + (getSeasonAndEpisodeStats(index: showIndex) ?? ""), colorScheme: colorScheme)
                                        }
                                    }
                                }
                            }
                            .onDelete { indexes in
                                for index in indexes {
                                    deleteShow(watchedShowDataItems[index])
                                }
                            }
//                            .onMove(perform: move)
                        }
                    }
                    .styleList()
                }
            }
        }
    }
    
    /// Creates a string with the current season and episode stats for a show.
    ///
    /// - Returns: The string to be displayed with the current season and episode.
    func getSeasonAndEpisodeStats(index: Int) -> String? {
        
        if let season = watchedShowDataItems[index].currentSeason,
           let episode = watchedShowDataItems[index].currentEpisode {
            return "S: \(season), Ep: \(episode)"
        }
        
        return nil
    }
    
    /// Removes the deleted show from the stored list of shows.
    ///
    /// - Parameters:
    ///   - showToDelete: The show to be removed.
    ///
    /// - Returns: None.
    private func deleteShow(_ showToDelete: WatchedShowDataItem) {
            context.delete(showToDelete)
            try? context.save()
    }
    
    /// Moves the selected show within the ranked lists.
    ///
    /// - Parameters:
    ///   - source: The original index of the show/movie to be moved.
    ///   - destination: The new index of the show/movie to be moved.
    ///
    /// - Returns: None.
    private func move(from source: IndexSet, to destination: Int) {
        var updatedShows = Array(watchedShowDataItems)
        
        updatedShows.move(fromOffsets: source, toOffset: destination)
        for show in updatedShows {
            print(show.show)
        }
            
//            for show in updatedShows {
//                context.delete(show)
//                context.insert(show)
//            }
        
        try? context.save()
    }
    
}
