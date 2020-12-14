//
//  SearchResponseModel.swift
//  iMusic
//
//  Created by Maxim Alekseev on 13.12.2020.
//

import Foundation

struct ItunesSearchResponse: Decodable {
    
    var resultCount: Int
    var results: [Track]
}

struct Track: Decodable {
    
    var trackName: String?
    var collectionName: String?
    var artistName: String
    var artworkUrl100: String?
    var previewUrl: String?
}
