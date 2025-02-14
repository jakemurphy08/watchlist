//
//  UpNextView.swift
//  Watchlist
//
//  Created by Jake Murphy on 1/31/25.
//

import SwiftUI

struct UpNextView: View {
    
    // Environment
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.editMode) private var editMode
    
    
    @StateObject private var showDataManager = ShowDataManager(fileName: "UpNextShows.json")
    @StateObject private var movieDataManager = MovieDataManager(fileName: "UpNextMovies.json")
    
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
    
    var backButton: some View {
        Button {
            dismiss()
        } label: {
                Image(systemName: "arrowshape.backward")
                .padding()
                .changeAppearance(colorScheme: colorScheme)
        }
    }
    
    var cancelButton: some View {
        Button("Cancel") {
            cancelAddingAShowOrMovie()
        }
        .changeAppearance(colorScheme: colorScheme)
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
                        if showDataManager.showsData.isEmpty {
                            Text("You haven't added any shows yet!")
                                .changeAppearance(colorScheme: colorScheme)
                        } else {
                            ForEach(showDataManager.showsData.indices, id: \.self) { index in
                                displayText(text: "\(index  + 1). \(showDataManager.showsData[index].show)", colorScheme: colorScheme)
                            }
                            .onDelete(perform: delete)
                            .onMove(perform: move)
                        }
                    }
                    .styleList()
                    .onAppear {
                        showDataManager.loadShows()
                    }
                    
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
                        if movieDataManager.moviesData.isEmpty {
                            Text("You haven't added any movies yet!")
                                .changeAppearance(colorScheme: colorScheme)
                        } else {
                            ForEach(movieDataManager.moviesData.indices, id: \.self) { index in
                                displayText(text: "\(index  + 1). \(movieDataManager.moviesData[index].movie)", colorScheme: colorScheme)
                            }
                            .onDelete(perform: delete)
                            .onMove(perform: move)
                        }
                    }
                    .styleList()
                    .onAppear {
                        movieDataManager.loadMovies()
                    }
                    
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
            .styleAddNewMediaTextField(isTextFieldFocused: $isTextFieldFocused,
                       isSearching: $isSearching,
                       newShow: newShow,
                       fetchData: fetchData(query: newShow))
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
            showDataManager.addShow(show: result.title, posterURL: result.poster)
            showDataManager.saveShows()
            newShow = ""
        case .movies:
            movieDataManager.addMovie(movie: result.title, posterURL: result.poster)
            movieDataManager.saveMovies()
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
    
    /// Removes the deleted show or movie from the array that displays the users ranked lists
    /// and from the json file which is accessed by `showDataManager` or `movieDataManager`.
    ///
    /// - Parameters:
    ///   - indexSet: The index of the show/movie to remove.
    ///
    /// - Returns: None.
    func delete(indexSet: IndexSet) {
        if mediaType == .shows {
            showDataManager.showsData.remove(atOffsets: indexSet)
            showDataManager.saveShows()
        } else {
            movieDataManager.moviesData.remove(atOffsets: indexSet)
            movieDataManager.saveMovies()
        }
    }
    
    /// Moves the selected show/movie within the ranked lists.
    ///
    /// - Parameters:
    ///   - indices: The original index of the show/movie to be moved.
    ///   - newOffset: The new index of the show/movie to be moved.
    ///
    /// - Returns: None.
    func move(indices: IndexSet, newOffset: Int) {
        if mediaType == .shows {
            showDataManager.showsData.move(fromOffsets: indices, toOffset: newOffset)
            showDataManager.saveShows()
        } else {
            movieDataManager.moviesData.move(fromOffsets: indices, toOffset: newOffset)
            movieDataManager.saveMovies()
        }
    }
}

#Preview {
    UpNextView()
}

