//
//  UpNextView.swift
//  Watchlist
//
//  Created by Jake Murphy on 1/31/25.
//

import SwiftUI

struct UpNextView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var showDataManager = ShowDataManager(fileName: "UpNextShows.json")
    @StateObject private var movieDataManager = MovieDataManager(fileName: "UpNextMovies.json")
    @State public var searchResultData: [TVShowAndMovieData] = []
    @State private var mediaType: MediaType = .shows
    @State private var newShow: String = ""
    @State private var isButtonPressed: Bool = false
    @State private var newMovie: String = ""
    @State private var isShowingTextField: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    @State private var showOrMoviePicker = 0
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
                                    .styleButton(isButtonPressed: isButtonPressed, colorScheme: colorScheme)
                                    .simultaneousGesture(
                                        DragGesture(minimumDistance: 0)
                                            .onChanged { _ in isButtonPressed = true }
                                            .onEnded { _ in isButtonPressed = false }
                                    )
                            } else {
                                addMovieButton
                                    .styleButton(isButtonPressed: isButtonPressed, colorScheme: colorScheme)
                                    .simultaneousGesture(
                                        DragGesture(minimumDistance: 0)
                                            .onChanged { _ in isButtonPressed = true }
                                            .onEnded { _ in isButtonPressed = false }
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
                ToolbarItem(placement: .topBarLeading) {
                    HStack {
                        backButton()
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    displayText(text: "Your Queue")
                }
                
                if isShowingTextField == false {
                    ToolbarItem(placement: .topBarLeading) {
                        EditButton()
                            .foregroundStyle(colorScheme == .dark ? Color.white : AppColors.mainColor)
                    }
                }
                
                if isShowingTextField { // only show cancel button after pressing `add show`
                    ToolbarItem(placement: .topBarTrailing) {
                        cancelButton
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
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
                            if showDataManager.shows.isEmpty {
                                Text("You haven't added any shows yet!")
                                    .foregroundStyle(colorScheme == .dark ? Color.white : AppColors.mainColor)
                            }
                            ForEach(showDataManager.shows.indices, id: \.self) { index in
                                displayText(text: "\(index  + 1). \(showDataManager.shows[index])")
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
                        if movieDataManager.movies.isEmpty {
                            Text("You haven't added any movies yet!")
                                .foregroundStyle(colorScheme == .dark ? Color.white : AppColors.mainColor)
                        }
                        ForEach(movieDataManager.movies.indices, id: \.self) { index in
                            displayText(text: "\(index  + 1). \(movieDataManager.movies[index])")
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
        } else { // if showing movies
            createTextField(fieldText: "Enter Movie")
            
            List {
                ForEach(searchResultData, id: \.imdbID) { result in
                    if result.mediaType == "movie" {
                        HStack {
                            displayImage(imageURL: result.poster, imgWidth: 100, imgHeight: 150)
                            
                            Spacer() // these spacers allow for the title/year to be centered
                            
                            Button("\(result.title), \(result.year)") {
                                handleNewMediaAdded(result: result)
                            }
                            .font(.headline)
                            
                            Spacer() // these spacers allow for the title/year to be centered
                        }
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
    
    func createTextField(fieldText: String) -> some View {
        TextField(fieldText, text: $newShow)
            .styleTextField(isTextFieldFocused: $isTextFieldFocused,
                       isSearching: $isSearching,
                       newShow: newShow,
                       fetchData: fetchData(query: newShow))
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
            image.resizable().scaledToFit()
        } placeholder: {
            ProgressView("Loading...")
        }
        .frame(width: imgWidth, height: imgHeight)
        .cornerRadius(cornerRadius)
        .padding(10)
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
            showDataManager.addShow(show: result.title)
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
    
    /// Creates the button for `Add Movie`
    var addMovieButton: some View {
        Button("Add Movie", action: {
            isShowingTextField = true
        })
    }
    
    func backButton() -> some View {
        Button(action: {
            dismiss()
        }) {
            Label("Back", systemImage: "arrowshape.left")
                .foregroundStyle(AppColors.mainColor)
                .padding()
        }
        .contentShape(Rectangle())
    }
    
    /// Creates the button for `Cancel`
    var cancelButton: some View {
        Button("Cancel") {
            cancelAddingAShowOrMovie()
        }
        .foregroundStyle(colorScheme == .dark ? Color.white : AppColors.mainColor)
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
    
    func delete(indexSet: IndexSet) {
        if mediaType == .shows {
            showDataManager.shows.remove(atOffsets: indexSet)
            showDataManager.saveShows()
        } else {
            movieDataManager.movies.remove(atOffsets: indexSet)
            movieDataManager.saveMovies()
        }
    }
    
    func move(indices: IndexSet, newOffset: Int) {
        if mediaType == .shows {
            showDataManager.shows.move(fromOffsets: indices, toOffset: newOffset)
            showDataManager.saveShows()
        } else {
            movieDataManager.movies.move(fromOffsets: indices, toOffset: newOffset)
            movieDataManager.saveMovies()
        }
    }
}

#Preview {
    ContentView()
}

