//
//  MovieDataManager.swift
//  Watchlist
//
//  Created by Jake Murphy on 2/3/25.
//

import SwiftUI
import CryptoKit

class MovieDataManager: ObservableObject {
    @Published var movies: [String] = []
    private var url: URL?
    
    init(fileName: String) {
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            url = documentDirectory.appendingPathComponent(fileName)
        }
    }
    
    func loadMovies() {
        
        guard let url = url else {
            print("Failed to find the file")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let loadedFile = try decoder.decode([String].self, from: data)
            movies = loadedFile  // Update movies array
        } catch {
            print("Failed to load or decode data: \(error)")
        }
    }
    
    func addMovie(movie: String) {
        if movies.contains(movie) == false {
            movies.append(movie)
        }
    }
    
    func saveMovies() {
        guard let url = url else {
            print("No URL set for saving.")
            return
        }
        
        do {
            let encoder = JSONEncoder()
            
            encoder.outputFormatting = [.prettyPrinted]
            
            let dataToSave = try encoder.encode(movies)
            try dataToSave.write(to: url)
        } catch {
            print(error)
        }
    }
}
