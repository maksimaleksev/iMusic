//
//  ItunesResourceBuilder.swift
//  iMusic
//
//  Created by Maxim Alekseev on 13.12.2020.
//

import Foundation

class ItunesResourceBuilder: ResourceBuilderProtocol {
    
    //MARK: - Constants for resource
    private let scheme = "https"
    private let host = "itunes.apple.com"
    private let path = "/search"

    //MARK: - Variables for API
    private var searchingText: String? = nil
    private var desiredTrackQuantity: String = "10"
    private var mediaType: String = "music"
    
    //MARK: - Methods
    
    func set(searchingText: String) {
        self.searchingText = searchingText
    }
        
    func set(desiredTrackQuantity: String) {
        self.desiredTrackQuantity = desiredTrackQuantity
    }
    
    func set(mediaType: String) {
        self.mediaType = mediaType
    }
    
    func buildResource() -> Resource<ItunesSearchResponse>? {
        
        guard let searchingText = self.searchingText  else { return nil }
        
        var urlComponents = URLComponents()
        urlComponents.scheme = self.scheme
        urlComponents.host = self.host
        urlComponents.path = self.path
        let termItem = URLQueryItem(name: "term", value: searchingText)
        let limitItem = URLQueryItem(name: "limit", value: self.desiredTrackQuantity)
        let mediaItem = URLQueryItem(name: "media", value: self.mediaType)
        urlComponents.queryItems = [termItem, limitItem, mediaItem]
        
        guard let resultURL = urlComponents.url else {
            print("Can't build URL")
            return nil
        }
        reset()
        return Resource.init(url: resultURL)
        
    }
  
    private func reset() {
        self.searchingText = nil
        self.desiredTrackQuantity = "10"
        self.mediaType = "music"
    }
   
}
