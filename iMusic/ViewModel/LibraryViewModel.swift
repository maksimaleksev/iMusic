//
//  LibraryViewModel.swift
//  iMusic
//
//  Created by Maxim Alekseev on 19.12.2020.
//

import Foundation
import RxSwift
import RxCocoa

class LibraryViewModel {
    
    private let storageManager = PersistantDataManager.shared
    var cells: BehaviorRelay<[SearchViewModel.CellViewModel]> = BehaviorRelay(value: [])
    
    init() {
        cells.accept(storageManager.loadCells())
    }
    
    func cellsReload() {
        self.cells.accept(storageManager.loadCells())
    }
    
    func deleteCellVM(at index: Int) {
        storageManager.deleteCell(at: index)
        cellsReload()
    }
}


