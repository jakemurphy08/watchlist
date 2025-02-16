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
    @State private var isShowingTextField: Bool = false
    @State private var newShow: String = ""
    @State public var searchResultData: [TVShowAndMovieData] = []
    @State private var buttonState = ButtonState.notPressed
    
    // Data Pullers
    @Query private var watchedShowDataItems: [WatchedShowDataItem]
    
    var body: some View {
        ZStack {
            VStack {
                displayShowList(isSearching: isSearching)
                if isShowingTextField {
                    displayRankedTextField()
                }
                
                if isShowingTextField == false {
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
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    displayText(text: "Your Rankings", isBold: true, colorScheme: colorScheme)
                }
                
                if isShowingTextField == false {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(destination: UpNextView()) {
                            displayText(text: "Up Next", colorScheme: colorScheme)
                        }
                    }
                }
                
                if isShowingTextField { // only show cancel button after pressing `add show`
                    ToolbarItem(placement: .topBarTrailing) {
                        cancelButton
                    }
                }
            }
        }
    }
    
    /// Creates the button for `Cancel`
    var cancelButton: some View {
        Button("Cancel") {
            cancelAddingAShowOrMovie()
        }
        .changeAppearance(colorScheme: colorScheme)
    }
    
    /// Creates the button for `Add Show`
    var addShowButton: some View {
        Button("Add Show", action: {
            isShowingTextField = true
        })
    }
    
    /// Cancels the process of adding a show or movie.
    ///
    /// - Returns: None.
    private func cancelAddingAShowOrMovie() {
        isShowingTextField = false
        newShow = ""
        searchResultData.removeAll()
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
    
    /// Displays the text field after pressing `Add Show`  with search results from the users entry.
    ///
    /// - Returns: The view of the text field and the list of search results.
    @ViewBuilder
    func displayRankedTextField() -> some View {
        let fieldText = "Enter Show"
        let showOrMovie = "series"
        
        createSearchTextField(fieldText: fieldText)
        
        if searchResultData.isEmpty {
            displayText(text: "Try entering something (else)...", colorScheme: colorScheme)
        }
        
        List {
            ForEach(searchResultData, id: \.imdbID) { result in
                if result.type == showOrMovie {
                    HStack {
                        displayImageWithURL(imageURL: result.poster, imgWidth: 100, imgHeight: 150)
                        
                        Spacer() // these spacers allow for the title/year to be centered
                        
                        Button("\(result.title), \(result.year)") {
                            handleNewShowAdded(result: result)
                        }
                        .font(.headline) // make it more prominent
                        
                        Spacer() // these spacers allow for the title/year to be centered
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 10) // Apply border correctly
                            .stroke(Color.gray, lineWidth: 3)
                    )
                }
            }
        }
    }
    
    /// Displays a text field for searching for a show. It styles the field accordingly and handles the user pressing `return`.
    ///
    /// - Parameters:
    ///   - fieldText: The text that displays in the text field before any input.
    ///
    /// - Returns: The view of the text field.
    private func createSearchTextField(fieldText: String) -> some View {
        TextField(fieldText, text: $newShow)
            .styleAddNewMediaTextField(isTextFieldFocused: $isTextFieldFocused,
                                       isSearching: $isSearching,
                                       newMedia: newShow,
                                       fetchData: fetchData(query: newShow, searchResultData: $searchResultData))
            .onSubmit {
                
                if let result = searchResultData.first {
                    isTextFieldFocused = false
                    isSearching = false
                    
                    handleNewShowAdded(result: result)
                } else {
                    isTextFieldFocused = true
                    isSearching = true
                }
            }
    }
    
    /// Handles tasks when adding a new show.
    ///
    /// - Parameters:
    ///   - result: A tv show that is returned from the search.
    ///
    /// - Returns: None.
    private func handleNewShowAdded(result: TVShowAndMovieData) {
        addShowItem(result.title, result.poster)
        newShow = ""
        searchResultData.removeAll()
        isShowingTextField = false
    }
    
    /// Store a show into the dataset for shows.
    ///
    /// - Parameters:
    ///   - show: The show to be added.
    ///   - posterURL: The url for the poster of the show.
    ///
    /// - Returns: None.
    func addShowItem(_ show: String, _ posterURL: String) {
        let showItem: WatchedShowDataItem
        
        if posterURL.isEmpty == false {
            showItem = WatchedShowDataItem(show: show, posterURL: posterURL)
        } else {
            showItem = WatchedShowDataItem(show: show)
        }
        
        context.insert(showItem)
        try? context.save()
        print("\(show) added!")
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
