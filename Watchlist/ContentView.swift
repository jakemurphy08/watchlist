//
//  ContentView.swift
//  Watchlist
//
//  Created by Jake Murphy on 1/31/25.
//

import SwiftUI

public struct AppColors {
    static let mainColor = Color(red: 17/255, green: 22/255, blue: 66/255)
    static let secondaryColor = Color(red: 49/255, green: 56/255, blue: 112/255)
}

enum MediaType {
    case movies
    case shows
}

struct ContentView: View {
    
    // Data managers
    @StateObject private var showDataManager = ShowDataManager(fileName: "shows.json")
    @StateObject private var movieDataManager = MovieDataManager(fileName: "movies.json")
    
    // Environment
    @Environment(\.colorScheme) var colorScheme
    
    // UI states
    @State private var mediaType: MediaType = .shows
    @State public var searchResultData: [TVShowAndMovieData] = []
    @State private var isPopupPresented: Bool = false
    @State private var newShow: String = ""
    @State private var buttonState = ButtonState.notPressed
    @State private var newMovie: String = ""
    @State private var isShowingTextField: Bool = false
    
    // Focus states
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
                        showList(isSearching: isSearching)
                            .offset(y: -180)
                        if isShowingTextField {
                            showRankedTextField()
                        }
                    } else {
                        movieList(isSearching: isSearching)
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    displayText(text: "Your Rankings", isBold: true)
                }
                
                if isShowingTextField == false {
                    ToolbarItem(placement: .topBarLeading) {
                        EditButton()
                            .foregroundStyle(colorScheme == .dark ? Color.white : AppColors.mainColor)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(destination: UpNextView()) {
                            displayText(text: "Up Next")
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
    
    /// Creates the button for `Cancel`
    var cancelButton: some View {
        Button("Cancel") {
            cancelAddingAShowOrMovie()
        }
        .foregroundStyle(colorScheme == .dark ? Color.white : AppColors.mainColor)
    }
    
    /// Displays text using the correct font color.
    ///
    /// - Parameters:
    ///     - text: The text to be displayed.
    ///     - isBold: True if the text should be bold.
    ///
    ///  - Returns: The text view with the given text.
    func displayText(text: String, isBold: Bool = false) -> some View {
        Text(text)
            .foregroundStyle(colorScheme == .dark ? Color.white : AppColors.mainColor)
            .bold(isBold)
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
    
//    /// Saves the selected new show into the json file which is accessed by `showDataManager`
//    ///
//    /// - Returns: None.
//    func saveShow() {
//        if newShow.isEmpty == false {
//            showDataManager.addShow(show: newShow, poster)
//            isShowingTextField = false
//            newShow = ""
//            showDataManager.saveShows()
//        }
//    }
    
    func createTextField(fieldText: String) -> some View {
        TextField(fieldText, text: $newShow)
            .styleAddNewMediaTextField(isTextFieldFocused: $isTextFieldFocused,
                       isSearching: $isSearching,
                       newShow: newShow,
                       fetchData: fetchData(query: newShow))
        .onSubmit {
            
            if let result = searchResultData.first {
                isTextFieldFocused = false
                isSearching = false
                
                handleNewMediaAdded(result: result, posterURL: result.poster)
            } else {
                isTextFieldFocused = true
                isSearching = true
            }
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
        switch (mediaType) {
        case .shows:
            showDataManager.showsData.move(fromOffsets: indices, toOffset: newOffset)
            showDataManager.saveShows()
        case .movies:
            showDataManager.showsData.move(fromOffsets: indices, toOffset: newOffset)
            showDataManager.saveShows()
        }
    }
    
    /// Displays the ranked list of shows.
    ///
    /// - Parameters:
    ///   - isSearching: True if the text field search bar is active when someone pressed `Add Show`.
    ///
    /// - Returns: The view of the list.
    @ViewBuilder
    func showList(isSearching: Bool) -> some View {
        ZStack {
            if isSearching == false {
                List {
                    Section(
                        header: Text("Shows").foregroundStyle(colorScheme == .dark ? Color.white : AppColors.mainColor)) {
                            if showDataManager.showsData.isEmpty {
                                displayText(text: "You haven't added any shows yet!")
                            }
                            ForEach(showDataManager.showsData.indices, id: \.self) { index in
                                NavigationLink(destination: ShowDetailPopup(show: showDataManager.showsData[index].show, showIndex: index, posterURL: showDataManager.showsData[index].posterURL)
                                    .environmentObject(showDataManager)
                                ) {
                                    displayText(text: "\(index + 1). \(showDataManager.showsData[index].show)" + " " + (getSeasonAndEpisodeStats(index: index) ?? ""))
                                }
                                .foregroundStyle(colorScheme == .dark ? Color.white : AppColors.mainColor)
                            }
                            .onDelete(perform: delete)
                            .onMove(perform: move)
                        }
                }
                .scrollContentBackground(.hidden)
                .onAppear {
                    showDataManager.loadShows()
                }
                .frame(maxHeight: 450)
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
    func movieList(isSearching: Bool) -> some View {
        if isSearching == false {
            List {
                Section(
                    header: Text("Movies").foregroundStyle(colorScheme == .dark ? Color.white : AppColors.mainColor)) {
                        if movieDataManager.moviesData.isEmpty {
                            Text("You haven't added any movies yet!")
                                .foregroundStyle(colorScheme == .dark ? Color.white : AppColors.mainColor)
                        }
                        ForEach(movieDataManager.moviesData.indices, id: \.self) { index in
                            Text("\(index + 1). \(movieDataManager.moviesData[index].movie)")
                                .foregroundStyle(colorScheme == .dark ? Color.white : AppColors.mainColor)
                        }
                        .onDelete(perform: delete)
                        .onMove(perform: move)
                    }
            }
            .scrollContentBackground(.hidden)
            .onAppear {
                movieDataManager.loadMovies()
            }
            .frame(maxHeight: 450)
        }
    }
    
    /// Handles tasks when adding a new show/movie.
    ///
    /// - Parameters:
    ///   - result: A tv show or movie that is returned from the search.
    ///
    /// - Returns: None.
    func handleNewMediaAdded(result: TVShowAndMovieData, posterURL: String?) {
        switch mediaType {
        case .shows:
            showDataManager.addShow(show: result.title, posterURL: posterURL)
            showDataManager.saveShows()
            searchResultData.removeAll()
            isShowingTextField = false
            newShow = ""
        case .movies:
            movieDataManager.addMovie(movie: result.title)
            searchResultData.removeAll()
            isShowingTextField = false
            movieDataManager.saveMovies()
            newMovie = ""
        }
    }
    
    /// Creates a string with the current season and episode stats for a show.
    ///
    /// - Returns: The string to be displayed with the current season and episode.
    func getSeasonAndEpisodeStats(index: Int) -> String? {
        
        if let season = showDataManager.getSeason(showDataIndex: index),
           let episode = showDataManager.getEpisode(showDataIndex: index) {
            return "S: \(season), Ep: \(episode)"
        }
        
        return nil
    }
    
    /// Displays the text field after pressing `Add Show` or `Add Movie`  with search results from the users entry.
    ///
    /// - Returns: The view of the text field and the list of search results.
    @ViewBuilder
    func showRankedTextField() -> some View {
        if mediaType == .shows {
            createTextField(fieldText: "Enter Show")
            
            List {
                ForEach(searchResultData, id: \.imdbID) { result in
                    if result.mediaType == "series" {
                        HStack {
                            displayImage(imageURL: result.poster, imgWidth: 100, imgHeight: 150)
                            
                            Spacer() // these spacers allow for the title/year to be centered
                            
                            Button("\(result.title), \(result.year)") {
                                handleNewMediaAdded(result: result, posterURL: result.poster)
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
        } else { // if showing movies
            createTextField(fieldText: "Enter Movie")
            
            List {
                ForEach(searchResultData, id: \.imdbID) { result in
                    if result.mediaType == "movie" {
                        HStack {
                            displayImage(imageURL: result.poster, imgWidth: 100, imgHeight: 150)
                            
                            Spacer() // these spacers allow for the title/year to be centered
                            
                            Button("\(result.title), \(result.year)") {
                                handleNewMediaAdded(result: result, posterURL: result.poster)
                            }
                            .font(.headline)
                            
                            Spacer() // these spacers allow for the title/year to be centered
                        }
                    }
                }
            }
        }
    }
    
    /// Displays an image
    ///
    /// - Parameters:
    ///   - imageURL: The url to the image.
    ///   - imgWidth: The width of the image.
    ///   - imgHeight: The height of the image.
    ///   - cornerRadius: How rounded the corners of the image are
    ///
    /// - Returns: None.
    func displayImage(imageURL: String?, imgWidth: CGFloat, imgHeight: CGFloat, cornerRadius: CGFloat = 10) -> some View {
        AsyncImage(url: URL(string: imageURL ?? "")) { image in
            image
                .resizable()
                .frame(width: imgWidth, height: imgHeight)
                .cornerRadius(cornerRadius)
        } placeholder: {
            ProgressView("Loading...")
        }
        .padding(10)
    }
}

#Preview {
    ContentView()
}
