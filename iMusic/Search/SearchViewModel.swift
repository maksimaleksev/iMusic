//
//  SearchViewModel.swift
//  iMusic
//
//  Created by Maxim Alekseev on 13.12.2020.
//

import Foundation
import RxSwift
import RxCocoa

class SearchViewModel {
    
    enum Mode {
        case displaydata
        case loading
    }
    
    class CellViewModel {
        var iconUrlString: String?
        var trackName: String
        var collectionName: String
        var artistName: String
        var previewUrl: String?
        
        init(iconUrlString: String, trackName: String,  collectionName: String, artistName: String, previewUrl: String) {
            self.iconUrlString = iconUrlString
            self.trackName = trackName
            self.collectionName = collectionName
            self.artistName = artistName
            self.previewUrl = previewUrl
        }
    }
    
    //MARK: - Costants and vars
    
    let disposeBag = DisposeBag()
    let searchNetworkSevice = ItunesSearchNetworkService()
    let searchText: BehaviorRelay<String> = BehaviorRelay(value: "")
    let cells: BehaviorRelay<[CellViewModel]> = BehaviorRelay(value: [])
    let mode: BehaviorRelay<Mode> = BehaviorRelay(value: .displaydata)
    
    //MARK: - Initializer
    init() {
        initialSetup()
    }
    
    //MARK: - Methods
    
    private func initialSetup() {
        searchText
            .filter {$0 != "" }
            .subscribe (onNext: {[unowned self] text in
                
                let resourceBuilder = ItunesResourceBuilder()
                resourceBuilder.set(searchingText: text)
                
                guard let resource = resourceBuilder.buildResource() else { return }
                
                self.mode.accept(.loading)
                
                self.searchNetworkSevice.loadSearchRequest(resource:resource)
                    .compactMap { searchResponse  in
                        
                        self.mode.accept(.displaydata)
                        return searchResponse?.results.map {[weak self] in (self?.getCell(from: $0))! }
                    }
                    .compactMap{ $0 }
                    .bind(to: self.cells)
                    .disposed(by: self.disposeBag)
                
            }).disposed(by: disposeBag)
    }
    
    private func getCell(from track: Track) -> SearchViewModel.CellViewModel{
        return SearchViewModel.CellViewModel.init(iconUrlString: track.artworkUrl100 ?? "",
                                                  trackName: track.trackName ?? "",
                                                  collectionName: track.collectionName ?? "",
                                                  artistName: track.artistName,
                                                  previewUrl: track.previewUrl ?? "")
    }
}
