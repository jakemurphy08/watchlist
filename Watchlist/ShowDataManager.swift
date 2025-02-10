//
//  DataManager.swift
//  Watchlist
//
//  Created by Jake Murphy on 2/3/25.
//

import SwiftUI
import CryptoKit



class ShowDataManager: ObservableObject {
    
    @Published var shows: [String] = []
    private var url: URL?
    public var currentSeason: Int? = nil
    public var currentEpisode: Int? = nil
    
    init(fileName: String) {
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            url = documentDirectory.appendingPathComponent(fileName)
            print(url!)
        }
        
        currentSeason = nil
        currentEpisode = nil
    }
    
    func loadShows() {
        
        guard let url = url else {
            print("Failed to find the file")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let loadedFile = try decoder.decode([String].self, from: data)
            shows = loadedFile  // Update shows array
        } catch {
            print("Failed to load or decode data: \(error)")
        }
    }
    
    func addShow(show: String) {
        if shows.contains(show) == false {
            shows.append(show)
        }
    }
    
    func saveShows() {
        guard let url = url else {
            print("No URL set for saving.")
            return
        }
        
        do {
            let encoder = JSONEncoder()
            
            encoder.outputFormatting = [.prettyPrinted]
            
            let dataToSave = try encoder.encode(shows)
            try dataToSave.write(to: url)
        } catch {
            print(error)
        }
    }
    
    func setSeason(season: Int) {
        currentSeason = season
    }
    
    func setEpisode(episode: Int) {
        currentEpisode = episode
    }
}
