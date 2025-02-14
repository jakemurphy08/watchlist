//
//  DataManager.swift
//  Watchlist
//
//  Created by Jake Murphy on 2/5/25.
//
// Manages the data taken from online.


import SwiftUI

struct OMDbResponse: Codable {
    let Search: [TVShowAndMovieData]
    let totalResults: String
    let Response: String
}

public struct TVShowAndMovieData: Codable {
    let title: String
    let year: String
    let imdbID: String
    let type: String
    let poster: String?
    
    // allows for the variables to have different names than the keys in the data
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case imdbID = "imdbID"
        case type = "Type"
        case poster = "Poster"
    }
}

public func fetchData(query: String, searchResultData: Binding<[TVShowAndMovieData]>) {
    // convert query from the input string into a realistic query
    var realisticQuery = query.lowercased()
    realisticQuery = realisticQuery.split(separator: " ").joined(separator: "+")
    
    let apiKey = "a8b8c187" // my key
    let url = URL(string: "https://www.omdbapi.com/?s=\(realisticQuery)&apikey=\(apiKey)")!
    
    let task = URLSession.shared.dataTask(with: url) { data, _, error in
        if let error = error {
            print("Error while fetching data:", error)
            return
        }
        
        guard let data = data else {
            print("Error while fetching data: No data returned")
            return
        }
        
        do {
            let decodedData = try JSONDecoder().decode(OMDbResponse.self, from: data)
            searchResultData.wrappedValue = decodedData.Search
        } catch {
            print("Failed to decode json", error)
        }
    }
    
    task.resume()
}
