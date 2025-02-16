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
                if isShowingTextField {
                    displayRankedTextField()
                }
                
                if isShowingTextField == false {
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
    
    /// Creates the button for `Cancel`
    var cancelButton: some View {
        Button("Cancel") {
            cancelAddingAShowOrMovie()
        }
        .changeAppearance(colorScheme: colorScheme)
    }
    
    /// Creates the button for `Add Movie`
    var addMovieButton: some View {
        Button("Add Movie", action: {
            isShowingTextField = true
        })
    }
    
    /// Cancels the process of adding a show or movie.
    ///
    /// - Returns: None.
    private func cancelAddingAShowOrMovie() {
        isShowingTextField = false
        newMovie = ""
        searchResultData.removeAll()
    }
    
    /// Displays the text field after pressing `Add Movie`  with search results from the users entry.
    ///
    /// - Returns: The view of the text field and the list of search results.
    @ViewBuilder
    func displayRankedTextField() -> some View {
        let fieldText = "Enter Movie"
        let showOrMovie = "movie"
        
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
                            handleNewMovieAdded(result: result)
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
    
    /// Displays a text field for searching for a movie. It styles the field accordingly and handles the user pressing `return`.
    ///
    /// - Parameters:
    ///   - fieldText: The text that displays in the text field before any input.
    ///
    /// - Returns: The view of the text field.
    private func createSearchTextField(fieldText: String) -> some View {
        TextField(fieldText, text: $newMovie)
            .styleAddNewMediaTextField(isTextFieldFocused: $isTextFieldFocused,
                                       isSearching: $isSearching,
                                       newMedia: newMovie,
                                       fetchData: fetchData(query: newMovie, searchResultData: $searchResultData))
            .onSubmit {
                
                if let result = searchResultData.first {
                    isTextFieldFocused = false
                    isSearching = false
                    
                    handleNewMovieAdded(result: result)
                } else {
                    isTextFieldFocused = true
                    isSearching = true
                }
            }
    }
    
    /// Handles tasks when adding a new movie.
    ///
    /// - Parameters:
    ///   - result: A tv movie that is returned from the search.
    ///
    /// - Returns: None.
    private func handleNewMovieAdded(result: TVShowAndMovieData) {
        addMovieItem(result.title, result.poster)
        newMovie = ""
        searchResultData.removeAll()
        isShowingTextField = false
    }
    
    /// Store a movie into the dataset for shows.
    ///
    /// - Parameters:
    ///   - movie: The movie to be added.
    ///   - posterURL: The url for the poster of the movie.
    ///
    /// - Returns: None.
    func addMovieItem(_ movie: String, _ posterURL: String) {
        let movieItem: WatchedMovieDataItem
        
        if posterURL.isEmpty == false {
            movieItem = WatchedMovieDataItem(movie: movie, posterURL: posterURL)
        } else {
            movieItem = WatchedMovieDataItem(movie: movie)
        }
        
        context.insert(movieItem)
        try? context.save()
        print("\(movie) added!")
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
