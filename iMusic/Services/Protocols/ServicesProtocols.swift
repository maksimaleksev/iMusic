//
//  ServicesProtocols.swift
//  iMusic
//
//  Created by Maxim Alekseev on 13.12.2020.
//

import Foundation
import RxSwift

protocol ResourceBuilderProtocol:class {
    associatedtype ResourceType: Decodable
    func set(searchingText: String)
    func set(desiredTrackQuantity: String)
    func set(mediaType: String)
    func buildResource() -> Resource<ResourceType>?
}

protocol NetworkServiceProtocol {
    associatedtype ResourceType: Decodable
    func loadSearchRequest(resource: Resource<ResourceType>) -> Observable<ResourceType?>
}
