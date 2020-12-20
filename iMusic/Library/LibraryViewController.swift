//
//  LibraryViewController.swift
//  iMusic
//
//  Created by Maxim Alekseev on 13.12.2020.
//

import UIKit
import RxSwift

class LibraryViewController: UIViewController {
    
    //MARK: - Vars and constants
    static let vcName = "Library"
    private let disposeBag = DisposeBag()
    private let viewModel = LibraryViewModel()
    private var track: SearchViewModel.CellViewModel!
    
    //MARK: - Delegates
    weak var mainTabBarDelegate: MainTabBarControllerDelegate?

    //MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playButton: UIButton!
        
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        populateTableView()
        cellSelectedSetup()
        deleteTableViewCell()
        setupPlayButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.cellsReload()
        
        let keyWindow = UIApplication.shared.connectedScenes.filter({$0.activationState == .foregroundActive})
            .map { $0 as? UIWindowScene }
            .compactMap{$0}
            .first?
            .windows
            .filter{$0.isKeyWindow}
            .first
        let tabBarVC = keyWindow?.rootViewController as? MainTabBarController
        tabBarVC?.trackDetailView.trackMovingDelegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playButton.layer.cornerRadius = 5
    }
    
    //MARK: - Setup Table View
    
    private func setupTableView() {
        let nib = UINib(nibName: TrackCell.reuseId, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: TrackCell.reuseId)
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }
    
    private func populateTableView() {
        viewModel.cells.asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(cellIdentifier: TrackCell.reuseId, cellType: TrackCell.self)) { index, cellVM, cell in
                cell.set(viewModel: cellVM)
            }.disposed(by: disposeBag)
    }
    
    private func cellSelectedSetup() {
        tableView.rx.itemSelected.subscribe(onNext: {[weak self] indexPath in
            
            guard let track = self?.viewModel.cells.value[indexPath.row] else { return }
                        
            self?.track = track
            self?.mainTabBarDelegate?.maximizeTrackDetailController(viewModel: self?.track)


        }).disposed(by: disposeBag)
    }
    
    private func deleteTableViewCell() {
        tableView.rx.itemDeleted.subscribe { [weak self] in
            self?.viewModel.deleteCellVM(at: $0.row)
        }.disposed(by: disposeBag)
    }

    //MARK: - Setup play button
    
    private func setupPlayButton() {
        playButton.rx.tap.subscribe(onNext: {[weak self] in
            self?.track = self?.viewModel.cells.value.first
            self?.mainTabBarDelegate?.maximizeTrackDetailController(viewModel: self?.track)
        }).disposed(by: disposeBag)
    }
    
}


//MARK: - TrackMovingDelegate
extension LibraryViewController: TrackMovingDelegate {
    
    func moveBackForPreviousTrack() -> SearchViewModel.CellViewModel? {
        let index = viewModel.cells.value.firstIndex(of: track)
        guard let myIndex = index else { return nil }
        var nextTrack: SearchViewModel.CellViewModel
        
        if myIndex - 1 == -1 {
            nextTrack = viewModel.cells.value.last!
        } else {
            nextTrack = viewModel.cells.value[myIndex - 1]
        }
        
        self.track = nextTrack
        return nextTrack
    }
    
    func moveForwardForNextTrack() -> SearchViewModel.CellViewModel? {
        let index = viewModel.cells.value.firstIndex(of: track)
        guard let myIndex = index else { return nil }
        var nextTrack: SearchViewModel.CellViewModel
        
        if myIndex + 1 == viewModel.cells.value.count {
            nextTrack = viewModel.cells.value.first!
        } else {
            nextTrack = viewModel.cells.value[myIndex + 1]
        }
        
        self.track = nextTrack
        return nextTrack
    }
    
}

extension LibraryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Tracks added to the library will be shown here..."
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.cells.value.count > 0 ? 0 : 250
    }
}
