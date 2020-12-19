//
//  PersistantDataManager.swift
//  iMusic
//
//  Created by Maxim Alekseev on 19.12.2020.
//

import UIKit
import CoreData

class PersistantDataManager {
    
    static let shared =  PersistantDataManager()
    
    private let appdelegate: AppDelegate
    
    private let context: NSManagedObjectContext
    
    private init() {
        self.appdelegate = UIApplication.shared.delegate as! AppDelegate
        self.context = appdelegate.persistentContainer.viewContext
    }
    
    func saveViewModel(_ viewModel: SearchViewModel.CellViewModel) {
        
        let newTrack = TrackDataModel(context: context)
        newTrack.artistName = viewModel.artistName
        newTrack.collectionName = viewModel.collectionName
        newTrack.iconUrlString = viewModel.iconUrlString
        newTrack.previewUrl = viewModel.previewUrl
        newTrack.trackName = viewModel.trackName
        
        self.save()
    }
    
    func loadCells() -> [SearchViewModel.CellViewModel] {
        
        var cells = [SearchViewModel.CellViewModel]()
        
        let request: NSFetchRequest<TrackDataModel> = TrackDataModel.fetchRequest()
        
        do {
            let trackData = try context.fetch(request)
            cells = trackData.map {
                return SearchViewModel.CellViewModel(iconUrlString: $0.iconUrlString ?? "",
                                                     trackName: $0.trackName ?? "",
                                                     collectionName: $0.collectionName ?? "",
                                                     artistName: $0.artistName ?? "",
                                                     previewUrl: $0.previewUrl ?? "")
            }
        } catch (let error as NSError) {
            print("Error loading categories \(error)")
        }
        
        return cells
    }
    
    func deleteCell(at index: Int) {
        
        let request: NSFetchRequest<TrackDataModel> = TrackDataModel.fetchRequest()
        
        do {
            let trackData = try context.fetch(request)[index]
            context.delete(trackData)
        } catch {
            print("Error saving category \(error)")
        }
        
        self.save()
    }
    
    private func save() {
        
        do {
            try context.save()
        } catch {
            print("Error saving category \(error)")
        }
        
    }
    
}
