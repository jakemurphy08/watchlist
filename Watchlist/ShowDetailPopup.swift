//
//  ShowDetailPopup.swift
//  Watchlist
//
//  Created by Jake Murphy on 2/6/25.
//

import SwiftUI

struct ShowDetailPopup: View {
    
    @State var currentEpisode: String = ""
    @State var currentSeason: String = ""
    @FocusState var isTextFieldFocused: Bool
    @EnvironmentObject var showDataManager: ShowDataManager
    let show: String
    let showIndex: Int
    
    var body: some View {
        VStack {
            Text(show)
            
            HStack {
                Text("Season: ")
                    .font(.system(size: 13))
                seasonTextField(fieldText: "")
                Text("...and episode: ")
                    .font(.system(size: 13))
                episodeTextField(fieldText: "")
            }
            .padding()
            
            saveButton()
        }
    }
    
    func seasonTextField(fieldText: String) -> some View {
        TextField(fieldText, text: $currentSeason)
            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
    
    func episodeTextField(fieldText: String) -> some View {
        TextField(fieldText, text: $currentEpisode)
            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
    
    func saveButton() -> some View {
        Button("Save") {
            showDataManager.setSeason(season: Int(currentSeason) ?? 0)
            showDataManager.setEpisode(episode: Int(currentEpisode) ?? 0)
            print(showDataManager.currentSeason ?? 0)
            print(showDataManager.currentEpisode ?? 0)
        }
    }
}

#Preview {
    ContentView()
}
