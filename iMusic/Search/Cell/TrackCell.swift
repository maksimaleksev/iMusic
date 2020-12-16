//
//  TrackCell.swift
//  iMusic
//
//  Created by Maxim Alekseev on 14.12.2020.
//

import UIKit

class TrackCell: UITableViewCell {
    
    static let reuseId = String(describing: TrackCell.self)
    
    private var cellViewModel: SearchViewModel.CellViewModel?
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var coverImagView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var collectionNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.coverImagView.image = nil
    }
    
    //MARK: - Methods
    
    func set(viewModel: SearchViewModel.CellViewModel) {
        
        //        let savedTracks = UserDefaults.standard.savedTracks()
        //        let hasFavorite = savedTracks.firstIndex { $0.trackName == viewModel.trackName && $0.artistName == viewModel.artistName } != nil
        //
        //        saveTrackButton.isHidden = hasFavorite
        
        self.cellViewModel = viewModel
        self.trackNameLabel.text = viewModel.trackName
        self.artistNameLabel.text = viewModel.artistName
        self.collectionNameLabel.text = viewModel.collectionName
        self.coverImagView.webImage(viewModel.iconUrlString ?? "",
                                    placeHolder: #imageLiteral(resourceName: "albumImagePlaceHolder"))
    }
    @IBAction func saveToStorageButtonTapped(_ sender: UIButton) {
    }
    
}
