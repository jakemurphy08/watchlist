//
//  SearchNewMediaScreen.swift
//  Watchlist
//
//  Created by Jake Murphy on 2/16/25.
//

import SwiftUI
import SwiftData

struct SearchNewShowScreen: View {
    
    // Environment
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    
    // UI States
    @State private var newShow: String = ""
    @State public var searchResultData: [TVShowAndMovieData] = []
    
    // Focus States
    @FocusState private var isSearching: Bool
    
    var watchedStatus: WatchedStatus
    
    var body: some View {
        ZStack {
            VStack {
                createSearchTextField(fieldText: "Enter Show")
                
                displayRankedTextField()
                
                Spacer()
            }
        }
    }
    
    /// Displays the text field after pressing `Add Show`  with search results from the users entry.
    ///
    /// - Returns: The view of the text field and the list of search results.
    @ViewBuilder
    private func displayRankedTextField() -> some View {
        
        if searchResultData.isEmpty {
            displayText(text: "Try entering something...", colorScheme: colorScheme)
        } else if searchResultData.isEmpty && newShow.isEmpty == false {
            displayText(text: "Try entering something else, we don't seem to have that yet", colorScheme: colorScheme)
        } else {
            
            List {
                ForEach(searchResultData, id: \.imdbID) { result in
                    if result.type == "series" {
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
    }
    
    /// Displays a text field for searching for a show. It styles the field accordingly and handles the user pressing `return`.
    ///
    /// - Parameters:
    ///   - fieldText: The text that displays in the text field before any input.
    ///
    /// - Returns: The view of the text field.
    private func createSearchTextField(fieldText: String) -> some View {
        TextField(fieldText, text: $newShow)
            .styleAddNewMediaTextField(isSearching: $isSearching,
                                       newMedia: newShow,
                                       fetchData: fetchData(query: newShow, searchResultData: $searchResultData))
            .onSubmit {
                
                if let result = searchResultData.first {
                    isSearching = false
                    
                    handleNewShowAdded(result: result)
                } else {
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
        dismiss()
    }
    
    /// Store a show into the dataset for shows. This uses the `watchedStatus` enum to decide which dataset to store the new show into.
    ///
    /// - Parameters:
    ///   - show: The show to be added.
    ///   - posterURL: The url for the poster of the show.
    ///
    /// - Returns: None.
    private func addShowItem(_ show: String, _ posterURL: String) {
        let showItem: any PersistentModel
        
        switch watchedStatus {
        case .watched:
            if posterURL.isEmpty == false {
                showItem = WatchedShowDataItem(show: show, posterURL: posterURL)
            } else {
                showItem = WatchedShowDataItem(show: show)
            }
        case .notWatched:
            showItem = UnwatchedShowDataItem(show: show)
        }
        
        context.insert(showItem)
        try? context.save()
        print("\(show) added!")
    }
}

#Preview {
    SearchNewShowScreen(watchedStatus: .watched)
}
