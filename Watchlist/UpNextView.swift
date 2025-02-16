//
//  UpNextView.swift
//  Watchlist
//
//  Created by Jake Murphy on 1/31/25.
//

import SwiftUI
import SwiftData

struct UpNextView: View {
    
    // Environment
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var context
    
    @Query private var unwatchedShowDataItems: [UnwatchedShowDataItem]
    @Query private var unwatchedMovieDataItems: [UnwatchedMovieDataItem]

    // UI States
    @State public var searchResultData: [TVShowAndMovieData] = []
    @State private var mediaType: MediaType = .shows
    @State private var newShow: String = ""
    @State private var buttonState = ButtonState.notPressed
    @State private var newMovie: String = ""
    @State private var isShowingTextField: Bool = false
    @State private var showOrMoviePicker = 0
    
    // Focus States
    @FocusState private var isTextFieldFocused: Bool
    @FocusState private var isSearching: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    if isTextFieldFocused == false {
                        Picker("Select Media", selection: $mediaType) {
                            Text("Shows").tag(MediaType.shows)
                            Text("Movies").tag(MediaType.movies)
                        }
                        .styleSegmentedPicker()
                    }
                    
                    Spacer(minLength: 0)
                    
                    if mediaType == .shows {
                        displayShowList(isSearching: isSearching)
                            .offset(y: -180)
                        if isShowingTextField {
                            showRankedTextField()
                        }
                    } else {
                        displayMovieList(isSearching: isSearching)
                            .offset(y: -180)
                        if isShowingTextField {
                            showRankedTextField()
                        }
                    }
                }
                
                if isShowingTextField == false {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            if mediaType == .shows {
                                addShowButton
                                    .styleButton(buttonState: buttonState, colorScheme: colorScheme)
                                    .simultaneousGesture(
                                        DragGesture(minimumDistance: 0)
                                            .onChanged { _ in buttonState = .pressed }
                                            .onEnded { _ in buttonState = .notPressed }
                                    )
                            } else {
                                addMovieButton
                                    .styleButton(buttonState: buttonState, colorScheme: colorScheme)
                                    .simultaneousGesture(
                                        DragGesture(minimumDistance: 0)
                                            .onChanged { _ in buttonState = .pressed }
                                            .onEnded { _ in buttonState = .notPressed }
                                    )
                            }
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
                displayText(text: "Your Queue", colorScheme: colorScheme)
            }
            
            if isShowingTextField { // only show cancel button after pressing `add show`
                ToolbarItem(placement: .topBarTrailing) {
                    cancelButton
                }
            }
        }
    }
    
    /// Creates the button for `Add Show`
    var addShowButton: some View {
        Button("Add Show", action: {
            isShowingTextField = true
        })
    }
    
    /// Creates the button for `Add Movie`
    var addMovieButton: some View {
        Button("Add Movie", action: {
            isShowingTextField = true
        })
    }
    
    var cancelButton: some View {
        Button("Cancel") {
            cancelAddingAShowOrMovie()
        }
        .changeAppearance(colorScheme: colorScheme)
    }
    
    /// Store a show into the dataset for shows.
    ///
    /// - Parameters:
    ///   - show: The show to be added.
    ///   - posterURL: The url for the poster of the show.
    ///
    /// - Returns: None.
    func addShowItem(_ show: String, _ posterURL: String) {
        let showItem: UnwatchedShowDataItem
        
        if posterURL.isEmpty == false {
            showItem = UnwatchedShowDataItem(show: show, posterURL: posterURL)
        } else {
            showItem = UnwatchedShowDataItem(show: show)
        }
        
        context.insert(showItem)
        try? context.save()
        print("\(show) added!")
    }
    
    /// Store a movie into the dataset for shows.
    ///
    /// - Parameters:
    ///   - movie: The movie to be added.
    ///   - posterURL: The url for the poster of the movie.
    ///
    /// - Returns: None.
    func addMovieItem(_ movie: String, _ posterURL: String) {
        let movieItem: UnwatchedMovieDataItem
        
        if posterURL.isEmpty == false {
            movieItem = UnwatchedMovieDataItem(movie: movie, posterURL: posterURL)
        } else {
            movieItem = UnwatchedMovieDataItem(movie: movie)
        }
        
        context.insert(movieItem)
        try? context.save()
        print("\(movie) added!")
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
                    
                    displayListHeaders(mediaType: mediaType, colorScheme: colorScheme)
                    
                    List {
                        if unwatchedShowDataItems.isEmpty {
                            Text("You haven't added any shows yet!")
                                .changeAppearance(colorScheme: colorScheme)
                        } else {
                            ForEach(unwatchedShowDataItems, id: \.self) { showInList in
                                displayText(text: "\(showInList.show)", colorScheme: colorScheme)
                            }
                            .onDelete { itemsToBeDeleted in
                                for item in itemsToBeDeleted {
                                    deleteShow(unwatchedShowDataItems[item])
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
                    
                    displayListHeaders(mediaType: mediaType, colorScheme: colorScheme)
                    
                    List {
                        if unwatchedMovieDataItems.isEmpty {
                            Text("You haven't added any movies yet!")
                                .changeAppearance(colorScheme: colorScheme)
                        } else {
                            ForEach(unwatchedMovieDataItems, id: \.self) { movieInList in
                                displayText(text: "\(movieInList.movie)", colorScheme: colorScheme)
                            }
                            .onDelete { indexes in
                                for index in indexes {
                                    deleteMovie(unwatchedMovieDataItems[index])
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
    
    /// Displays the text field after pressing `Add Show` or `Add Movie`  with search results from the users entry.
    ///
    /// - Returns: The view of the text field and the list of search results.
    @ViewBuilder
    func showRankedTextField() -> some View {
        let (fieldText, showOrMovie) = mediaType == .shows ? ("Enter Show", "series") : ("Enter Movie", "movie")
        
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
                            handleNewMediaAdded(result: result)
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
    
    /// Displays a text field for searching for a show/movie. It styles the field accordingly and handles the user pressing `return`.
    ///
    /// - Parameters:
    ///   - fieldText: The text that displays in the text field before any input.
    ///
    /// - Returns: The view of the text field.
    func createSearchTextField(fieldText: String) -> some View {
        TextField(fieldText, text: $newShow)
            .styleAddNewMediaTextField(isSearching: $isSearching,
                                       newMedia: newShow,
                                       fetchData: fetchData(query: newShow, searchResultData: $searchResultData))
            .onSubmit {
                
                if let result = searchResultData.first {
                    isTextFieldFocused = false
                    isSearching = false
                    
                    handleNewMediaAdded(result: result)
                } else {
                    isTextFieldFocused = true
                    isSearching = true
                }
            }
    }
    
    /// Handles tasks when adding a new show/movie.
    ///
    /// - Parameters:
    ///   - result: A tv show or movie that is returned from the search.
    ///
    /// - Returns: None.
    func handleNewMediaAdded(result: TVShowAndMovieData) {
        switch mediaType {
        case .shows:
            addShowItem(result.title, result.poster)
            newShow = ""
        case .movies:
            addMovieItem(result.title, result.poster)
            newMovie = ""
        }
        
        searchResultData.removeAll()
        isShowingTextField = false
    }
    
    /// Cancels the process of adding a show or movie.
    ///
    /// - Returns: None.
    func cancelAddingAShowOrMovie() {
        isShowingTextField = false
        
        switch mediaType {
        case .shows:
            newShow = ""
            searchResultData.removeAll()
        case .movies:
            newMovie = ""
            searchResultData.removeAll()
        }
    }
    
    /// Removes the deleted show from the stored list of shows.
    ///
    /// - Parameters:
    ///   - showToDelete: The show to be removed.
    ///
    /// - Returns: None.
    private func deleteShow(_ showToDelete: UnwatchedShowDataItem) {
            context.delete(showToDelete)
            try? context.save()
    }
    
    /// Removes the deleted movie from the stored list of movies.
    ///
    /// - Parameters:
    ///   - movieToDelete: The show to be removed.
    ///
    /// - Returns: None.
    private func deleteMovie(_ movieToDelete: UnwatchedMovieDataItem) {
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
        var updatedShows = Array(unwatchedShowDataItems)
        
        switch (mediaType) {
        case .shows:
            updatedShows.move(fromOffsets: source, toOffset: destination)
            
            for show in updatedShows {
                context.delete(show)
                context.insert(show)
            }
            
            try? context.save()
        case .movies:
            break
//            showDataManager.showsData.move(fromOffsets: indices, toOffset: newOffset)
//            showDataManager.saveShows()
        }
    }
}

#Preview {
    UpNextView()
}

