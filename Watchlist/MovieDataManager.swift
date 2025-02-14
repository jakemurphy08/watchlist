//
//  MovieDataManager.swift
//  Watchlist
//
//  Created by Jake Murphy on 2/3/25.
//

import SwiftUI
import CryptoKit

struct UserMovieData: Codable {
    var movie: String
    var posterURL: String?
    var ratingOutOfTen: CGFloat?
    
    init(movie: String, poster: String? = nil) {
        self.movie = movie
        self.posterURL = poster
    }
}

class MovieDataManager: ObservableObject {
    
    @Published var moviesData: [UserMovieData] = []
    private var url: URL?
    
    init(fileName: String) {
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            url = documentDirectory.appendingPathComponent(fileName)
            print(url!)
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
            let loadedFile = try decoder.decode([UserMovieData].self, from: data)
            moviesData = loadedFile  // Update shows array
        } catch {
            print("Failed to load or decode data: \(error)")
        }
    }
    
    func addMovie(movie: String, posterURL: String? = nil) {
        
        if moviesData.contains(where: { movieData in
            movieData.movie == movie
        }) {
            return
        }
        moviesData.append(UserMovieData(movie: movie, poster: posterURL))
        self.saveMovies()
    }
    
    func saveMovies() {
        guard let url = url else {
            print("No URL set for saving.")
            return
        }
        
        do {
            let encoder = JSONEncoder()
            
            encoder.outputFormatting = [.prettyPrinted]
            
            let dataToSave = try encoder.encode(moviesData)
            try dataToSave.write(to: url)
        } catch {
            print(error)
        }
    }
    
    func setUserRating(movieDataIndex: Int, rating: CGFloat) {
        moviesData[movieDataIndex].ratingOutOfTen = rating
        self.saveMovies()
    }
    
    func getUserRating(movieDataIndex: Int) -> CGFloat? {
        return moviesData[movieDataIndex].ratingOutOfTen
    }
}
