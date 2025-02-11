//
//  DataManager.swift
//  Watchlist
//
//  Created by Jake Murphy on 2/3/25.
//

import SwiftUI
import CryptoKit

struct UserShowData: Codable {
    var show: String
    var currentSeason: String? = nil
    var currentEpisode: String? = nil
    var posterURL: String?
    
    init(show: String, poster: String? = nil) {
        self.show = show
        self.posterURL = poster
    }
}

class ShowDataManager: ObservableObject {
    
    @Published var showsData: [UserShowData] = []
    private var url: URL?
    
    init(fileName: String) {
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            url = documentDirectory.appendingPathComponent(fileName)
            print(url!)
        }
    }
    
    func loadShows() {
        
        guard let url = url else {
            print("Failed to find the file")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let loadedFile = try decoder.decode([UserShowData].self, from: data)
            showsData = loadedFile  // Update shows array
        } catch {
            print("Failed to load or decode data: \(error)")
        }
    }
    
    func addShow(show: String, posterURL: String? = nil) {
        showsData.append(UserShowData(show: show, poster: posterURL))
        self.saveShows()
    }
    
    func saveShows() {
        guard let url = url else {
            print("No URL set for saving.")
            return
        }
        
        do {
            let encoder = JSONEncoder()
            
            encoder.outputFormatting = [.prettyPrinted]
            
            let dataToSave = try encoder.encode(showsData)
            try dataToSave.write(to: url)
        } catch {
            print(error)
        }
    }
    
    func setSeason(showDataIndex: Int, season: String?) {
        if let season = season {
            showsData[showDataIndex].currentSeason = season
            self.saveShows()
        }
    }
    
    func setEpisode(showDataIndex: Int, episode: String?) {
        if let episode = episode {
            showsData[showDataIndex].currentEpisode = episode
            self.saveShows()
        }
    }
    
    func getSeason(showDataIndex: Int) -> String? {
        return showsData[showDataIndex].currentSeason
    }
    
    func getEpisode(showDataIndex: Int) -> String? {
        return showsData[showDataIndex].currentEpisode
    }
    
    func clearCurrentSeasonAndEpisode(showDataIndex: Int) {
        showsData[showDataIndex].currentSeason = nil
        showsData[showDataIndex].currentEpisode = nil
        self.saveShows()
    }
}


#Preview {
    ContentView()
}
