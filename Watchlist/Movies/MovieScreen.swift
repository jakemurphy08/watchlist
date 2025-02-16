//
//  MovieScreen.swift
//  Watchlist
//
//  Created by Jake Murphy on 2/16/25.
//

import SwiftUI
import SwiftData

struct MovieScreen: View {
    
    // Data Pullers
    @Query private var watchedMovieDataItems: [WatchedMovieDataItem]
    
    // Environment
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var context
    
    // Focus states
    @FocusState private var isTextFieldFocused: Bool
    @FocusState private var isSearching: Bool
    
    // UI States
    @State private var newMovie: String = ""
    @State public var searchResultData: [TVShowAndMovieData] = []
    @State private var isShowingTextField: Bool = false
    @State private var buttonState = ButtonState.notPressed
    
    var body: some View {
        ZStack {
            VStack {
                displayMovieList(isSearching: isSearching)
            
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        addMovieButton
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
        
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: UpNextView()) {
                    displayText(text: "Up Next", colorScheme: colorScheme)
                }
            }
        }
    }
    
    /// Displays the ranked list of movies.
    ///
    /// - Parameters:
    ///   - isSearching: True if the text field search bar is active when someone pressed `Add Movie`.
    ///
    /// - Returns: The view of the list.
    @ViewBuilder
    func displayMovieList(isSearching: Bool) -> some View {
        ZStack {
            if isSearching == false {
                VStack(spacing: 0) {
                    
                    displayListHeaders(mediaType: .movies, colorScheme: colorScheme)
                    
                    List {
                        if watchedMovieDataItems.isEmpty {
                            displayText(text: "You haven't added any movies yet!", colorScheme: colorScheme)
                        } else {
                            ForEach(watchedMovieDataItems, id: \.self) { movieInList in
                                if let movieIndex = watchedMovieDataItems.firstIndex(of: movieInList) {
                                    NavigationLink(destination: MovieDetailPopupView(movieIndex: movieIndex, movieDataItem: movieInList)) {
                                        HStack {
                                            StarRatingOverlay(rating: movieInList.ratingOutOfTen ?? 0.0, colorScheme: colorScheme)
                                            displayText(text: "\(movieInList.movie)", colorScheme: colorScheme)
                                        }
                                    }
                                }
                            }
                            .onDelete { indexes in
                                for index in indexes {
                                    deleteMovie(watchedMovieDataItems[index])
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
    
    /// Creates the button for `Add Movie`
    var addMovieButton: some View {
        NavigationLink("Add Movie", destination: SearchNewMovieScreen())
    }
    
    /// Removes the deleted movie from the stored list of movies.
    ///
    /// - Parameters:
    ///   - movieToDelete: The show to be removed.
    ///
    /// - Returns: None.
    private func deleteMovie(_ movieToDelete: WatchedMovieDataItem) {
            context.delete(movieToDelete)
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
        var updatedMovies = Array(watchedMovieDataItems)
        
        updatedMovies.move(fromOffsets: source, toOffset: destination)
            for movie in updatedMovies {
                print(movie.movie)
            }
            
//            for show in updatedMovies {
//                context.delete(movie)
//                context.insert(movie)
//            }
            
            try? context.save()
    }
}
