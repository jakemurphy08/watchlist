//
//  ShowDataStorage.swift
//  Watchlist
//
//  Created by Jake Murphy on 2/14/25.
//

import SwiftUI
import SwiftData

@Model
class WatchedShowDataItem {
    @Attribute(.unique) var show: String
    var currentSeason: String? = nil
    var currentEpisode: String? = nil
    var posterURL: String?
    var ratingOutOfTen: CGFloat?
    
    init(show: String, posterURL: String? = nil) {
        self.show = show
        self.posterURL = posterURL
    }
}

@Model
class UnwatchedShowDataItem {
    @Attribute(.unique) var show: String
    
    init(show: String, posterURL: String? = nil) {
        self.show = show
    }
}
