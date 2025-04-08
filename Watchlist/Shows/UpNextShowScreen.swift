//
//  ShowScreen.swift
//  Watchlist
//
//  Created by Jake Murphy on 2/16/25.
//

import SwiftUI
import SwiftData

struct UpNextShowScreen: View {
    
    // Environment
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var context
    
    // UI States
    @State private var buttonState = ButtonState.notPressed
    @State private var deleteMode = false
    
    // Data Pullers
    @Query private var unwatchedShowDataItems: [UnwatchedShowDataItem]
    
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
                    displayText(text: "Your Queue", isBold: true, colorScheme: colorScheme)
                }
            }
        }
    }
    
    /// Creates the button for `Add Show`
    var addShowButton: some View {
        NavigationLink("Add Show", destination: SearchNewShowScreen(watchedStatus: .notWatched))
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
    private func displayShowList() -> some View {
        displayListHeaders(mediaType: .shows, colorScheme: colorScheme, deleteMode: $deleteMode)
        
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                
                if unwatchedShowDataItems.isEmpty {
                    displayText(text: "You haven't added any movies yet!", colorScheme: colorScheme)
                } else {
                    ForEach(unwatchedShowDataItems, id: \.self) { showInList in
                        HStack {
                            displayText(text: "\(showInList.show)", colorScheme: colorScheme)
                            
                            Spacer()
                            
                            deleteOrStandardMode(show: showInList)
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
    
    /// Displays either the delete mode or standard mode dependent on `deleteMode`.
    ///
    /// - Parameters:
    ///   - currentShow: The show that could be deleted if the user selects the trash can icon.
    /// - Returns: The view of either delete mode or standard mode.
    @ViewBuilder
    private func deleteOrStandardMode(show: UnwatchedShowDataItem) -> some View {
        if deleteMode {
            Button {
                deleteShow(show)
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
    
    /// Removes the deleted show from the stored list of shows.
    ///
    /// - Parameters:
    ///   - showToDelete: The show to be removed.
    ///
    /// - Returns: None.
    private func deleteShow(_ showToDelete: UnwatchedShowDataItem) {
        withAnimation {
            context.delete(showToDelete)
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
        var updatedShows = Array(unwatchedShowDataItems)
        
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
