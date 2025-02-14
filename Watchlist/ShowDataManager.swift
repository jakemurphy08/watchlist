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
    var ratingOutOfTen: CGFloat?
    
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
    
    /// Loads the shows from the JSON file into an array that holds each show and it's data.
    ///
    /// - Returns: None.
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
    
    
    /// Appends a new instance of a show to the array containing all shows.
    ///
    /// - Parameters:
    ///   - show: The show to be added.
    ///   - posterURL: The URL for the poster of the show.
    ///
    /// - Returns: None.
    func addShow(show: String, posterURL: String? = nil) {
        
        if showsData.contains(where: { showData in
            showData.show == show
        }) {
            return
        }
        showsData.append(UserShowData(show: show, poster: posterURL))
        self.saveShows()
    }
    
    /// Saves the shows data array in a JSON file that is NOT encrypted (yet).
    ///
    /// - Returns: None.
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
    
    /// Sets the current season for a show.
    ///
    /// - Parameters:
    ///   - showDataIndex: The index of the show in the shows array.
    ///   - season: The season to be saved.
    ///
    /// - Returns: None.
    func setSeason(showDataIndex: Int, season: String?) {
        showsData[showDataIndex].currentSeason = season
        self.saveShows()
    }
    
    /// Sets the current episode for a show.
    ///
    /// - Parameters:
    ///   - showDataIndex: The index of the show in the shows array.
    ///   - episode: The episode to be saved.
    ///
    /// - Returns: None.
    func setEpisode(showDataIndex: Int, episode: String?) {
        showsData[showDataIndex].currentEpisode = episode
        self.saveShows()
    }
    
    /// Gets the current season for a show.
    ///
    /// - Parameters:
    ///   - showDataIndex: The index of the show in the shows array.
    ///
    /// - Returns: The currently saved season for that show.
    func getSeason(showDataIndex: Int) -> String? {
        return showsData[showDataIndex].currentSeason
    }
    
    /// Gets the current episode for a show.
    ///
    /// - Parameters:
    ///   - showDataIndex: The index of the show in the shows array.
    ///
    /// - Returns: The currently saved episode for that show.
    func getEpisode(showDataIndex: Int) -> String? {
        return showsData[showDataIndex].currentEpisode
    }
    
    /// Clears the current season and episode data.
    ///
    /// - Parameters:
    ///   - showDataIndex: The index of the show in the shows array.
    ///
    /// - Returns: None.
    func clearCurrentSeasonAndEpisode(showDataIndex: Int) {
        showsData[showDataIndex].currentSeason = nil
        showsData[showDataIndex].currentEpisode = nil
        self.saveShows()
    }
    
    /// Sets the current rating for a show.
    ///
    /// - Parameters:
    ///   - showDataIndex: The index of the show in the shows array.
    ///   - rating: The rating to be saved.
    ///
    /// - Returns: None.
    func setUserRating(showDataIndex: Int, rating: CGFloat) {
        showsData[showDataIndex].ratingOutOfTen = rating
        self.saveShows()
    }
    
    /// Gets the current rating for a show.
    ///
    /// - Parameters:
    ///   - showDataIndex: The index of the show in the shows array.
    ///
    /// - Returns: The currently saved rating for that show.
    func getUserRating(showDataIndex: Int) -> CGFloat? {
        return showsData[showDataIndex].ratingOutOfTen
    }
}


#Preview {
    ContentView()
}
