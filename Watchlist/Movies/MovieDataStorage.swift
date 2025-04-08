//
//  MovieDataStorage.swift
//  Watchlist
//
//  Created by Jake Murphy on 2/16/25.
//

import SwiftUI
import SwiftData

@Model
class WatchedMovieDataItem {
    @Attribute(.unique) var movie: String
    var posterURL: String?
    var ratingOutOfTen: CGFloat?
    
    init(movie: String, posterURL: String? = nil) {
        self.movie = movie
        self.posterURL = posterURL
    }
}

@Model
class UnwatchedMovieDataItem {
    @Attribute(.unique) var movie: String
    
    init(movie: String) {
        self.movie = movie
    }
}
