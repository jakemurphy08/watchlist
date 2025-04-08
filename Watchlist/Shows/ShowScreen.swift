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
    
    // UI States
    @State private var buttonState = ButtonState.notPressed
    @State private var deleteMode = false
    
    private var showIndex: Int?
    
    // Data Pullers
    @Query private var watchedShowDataItems: [WatchedShowDataItem]
    
    var body: some View {
        ZStack {
            VStack {
                displayShowList()
                
                Spacer()
                
                addShowButton

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    displayAppLogo
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: UpNextView()) {
                        displayText(text: "Up Next", colorScheme: colorScheme)
                    }
                }
            }
        }
    }
    
    // Displays the apps logo
    var displayAppLogo: some View {
        if colorScheme == .light {
            Image(.lightModeLogo)
                .resizable()
                .frame(width: 40, height: 40)
        } else {
            Image(.darkModeLogo)
                .resizable()
                .frame(width: 40, height: 40)
        }
    }
    
    /// Creates the button for `Add Show`
    var addShowButton: some View {
        NavigationLink(destination: SearchNewShowScreen(watchedStatus: .watched)) {
            Text("Add Show")
        }
        .styleButton(buttonState: buttonState, colorScheme: colorScheme)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in buttonState = .pressed }
                .onEnded { _ in buttonState = .notPressed })
        .padding()
        .padding(.bottom, 120)
    }
    
    /// Displays the ranked list of shows.
    ///
    /// - Returns: The view of the list.
    @ViewBuilder
    func displayShowList() -> some View {
        
        displayListHeaders(mediaType: .shows, colorScheme: colorScheme, deleteMode: $deleteMode)
        
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                
                if watchedShowDataItems.isEmpty {
                    displayText(text: "You haven't added any shows yet!", colorScheme: colorScheme)
                } else {
                    ForEach(watchedShowDataItems, id: \.self) { showInList in
                        if let showIndex = watchedShowDataItems.firstIndex(of: showInList) {
                            NavigationLink(destination: ShowDetailPopupView(showIndex: showIndex, showDataItem: showInList)) {
                                HStack {
                                    StarRatingOverlay(rating: showInList.ratingOutOfTen ?? 0.0, colorScheme: colorScheme)
                                    displayText(text: "\(showInList.show)"
                                                + " "
                                                + (getSeasonAndEpisodeStats(index: showIndex) ?? ""),
                                                colorScheme: colorScheme)
                                    
                                    Spacer()
                                    
                                    deleteOrStandardMode(currentShow: showInList)
                                }
                            }
                            .transition(.scale)
                        }
                    }
                    //                            .onMove(perform: move)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    /// Displays either the delete mode or standard mode dependent on `deleteMode`.
    ///
    /// - Parameters:
    ///   - currentShow: The show that could be deleted if the user selects the trash can icon.
    /// - Returns: The view of either delete mode or standard mode.
    @ViewBuilder
    private func deleteOrStandardMode(currentShow: WatchedShowDataItem) -> some View {
        if deleteMode {
            Button {
                deleteShow(currentShow)
            } label: {
                Image(systemName: "delete.left")
                    .changeAppearance(colorScheme: colorScheme)
            }
            .transition(.move(edge: .trailing).combined(with: .scale))
        } else { // Standard mode
            Image(systemName: "slider.horizontal.3")
                .changeAppearance(colorScheme: colorScheme)
                .transition(.move(edge: .leading).combined(with: .scale))
        }
    }
    
    /// Creates a string with the current season and episode stats for a show.
    ///
    /// - Returns: The string to be displayed with the current season and episode.
    private func getSeasonAndEpisodeStats(index: Int) -> String? {
        
        if let season = watchedShowDataItems[index].currentSeason,
           let episode = watchedShowDataItems[index].currentEpisode {
            return "S: \(season), Ep: \(episode)"
        }
        
        return nil
    }
    
    /// Removes the deleted show from the stored list of shows.
    ///
    /// - Parameters:
    ///   - show: The show to be removed.
    ///
    /// - Returns: None.
    private func deleteShow(_ show: WatchedShowDataItem) {
        withAnimation {
            context.delete(show)
            try? context.save()
        }
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

#Preview {
    ShowScreen()
}
