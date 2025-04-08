//
//  MovieScreen.swift
//  Watchlist
//
//  Created by Jake Murphy on 2/16/25.
//

import SwiftUI
import SwiftData

struct UpNextMovieScreen: View {
    
    // Data Pullers
    @Query private var unwatchedMovieDataItems: [UnwatchedMovieDataItem]
    
    // Environment
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var context
    
    // UI States
    @State private var buttonState = ButtonState.notPressed
    @State private var deleteMode = false
    
    var body: some View {
        ZStack {
            VStack {
                displayMovieList()
            
                Spacer()
                    
                addMovieButton
                
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                displayText(text: "Your Queue", isBold: true, colorScheme: colorScheme)
            }
        }
    }
    
    /// Displays the ranked list of movies.
    ///
    /// - Returns: The view of the list.
    @ViewBuilder
    private func displayMovieList() -> some View {
        
        displayListHeaders(mediaType: .movies, colorScheme: colorScheme, deleteMode: $deleteMode)
        
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                
                if unwatchedMovieDataItems.isEmpty {
                    displayText(text: "You haven't added any movies yet!", colorScheme: colorScheme)
                } else {
                    ForEach(unwatchedMovieDataItems, id: \.self) { movieInList in
                        HStack {
                            displayText(text: "\(movieInList.movie)", colorScheme: colorScheme)
                            
                            Spacer()
                            
                            deleteOrStandardMode(movie: movieInList)
                        }
                        .transition(.scale)
                    }
                    .padding(.vertical, 5)
    //                            .onMove(perform: move)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    /// Creates the button for `Add Movie`
    var addMovieButton: some View {
        NavigationLink("Add Movie", destination: SearchNewMovieScreen(watchedStatus: .notWatched))
            .styleButton(buttonState: buttonState, colorScheme: colorScheme)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in buttonState = .pressed }
                    .onEnded { _ in buttonState = .notPressed })
            .padding()
            .padding(.bottom, 120)
    }
    
    /// Removes the deleted movie from the stored list of movies.
    ///
    /// - Parameters:
    ///   - movieToDelete: The show to be removed.
    ///
    /// - Returns: None.
    private func deleteMovie(_ movieToDelete: UnwatchedMovieDataItem) {
        withAnimation {
            context.delete(movieToDelete)
            try? context.save()
        }
    }
    
    /// Displays either the delete mode or standard mode dependent on `deleteMode`.
    ///
    /// - Parameters:
    ///   - currentShow: The show that could be deleted if the user selects the trash can icon.
    /// - Returns: The view of either delete mode or standard mode.
    @ViewBuilder
    private func deleteOrStandardMode(movie: UnwatchedMovieDataItem) -> some View {
        if deleteMode {
            Button {
                deleteMovie(movie)
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
    
    /// Moves the selected show within the ranked lists.
    ///
    /// - Parameters:
    ///   - source: The original index of the show/movie to be moved.
    ///   - destination: The new index of the show/movie to be moved.
    ///
    /// - Returns: None.
    private func move(from source: IndexSet, to destination: Int) {
        var updatedMovies = Array(unwatchedMovieDataItems)
        
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
