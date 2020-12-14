//
//  SearchNetworkService.swift
//  iMusic
//
//  Created by Maxim Alekseev on 13.12.2020.
//

import Foundation
import RxSwift
import RxCocoa

class ItunesSearchNetworkService: NetworkServiceProtocol  {
          
    func loadSearchRequest(resource: Resource<ItunesSearchResponse>) -> Observable<ItunesSearchResponse?> {
        return Observable.from([resource.url])
            .flatMap { (url) -> Observable<Data> in
                let request = URLRequest(url: url)
                return URLSession.shared.rx.data(request: request)
            }.map { data -> ItunesSearchResponse? in
                guard let decodedData =  try? JSONDecoder().decode(ItunesSearchResponse.self, from: data) else { return nil }
                return decodedData
            }.asObservable()
    }
}
