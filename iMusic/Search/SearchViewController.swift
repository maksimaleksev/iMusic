//
//  SearchViewController.swift
//  iMusic
//
//  Created by Maxim Alekseev on 13.12.2020.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewController: UIViewController {
    
    //MARK: - Constants and vars
    
    static let vcName = "Search"
    
    private let disposeBag = DisposeBag()
    
    private var viewModel = SearchViewModel()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let footerView = FooterView()
    
    //MARK: - IBOtlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupTableView()
        populateTableView()
        cellSelectedSetup()
    }
    
    deinit {
        print("SearchViewController deinit")
    }
    
    //MARK: - VC Methods
    
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false
        
        searchController.searchBar.rx.text
            .debounce(.milliseconds(1000), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .compactMap { $0 }
            .filter{ $0 != "" }
            .bind(to: viewModel.searchText).disposed(by: disposeBag)
        
    }
    
    private func setupTableView() {
        let nib = UINib(nibName: TrackCell.reuseId, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: TrackCell.reuseId)
        tableView.delegate = self
        tableView.tableFooterView = footerView
        viewModel.mode.asDriver().drive(onNext: {[weak self] mode in
            
            switch mode {
            
            case .displaydata:
                self?.footerView.hideLoader()
            case .loading:
                self?.footerView.showLoader()
            }
            
        }).disposed(by: disposeBag)
    }
    
    private func populateTableView() {
        viewModel.cells.asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(cellIdentifier: TrackCell.reuseId, cellType: TrackCell.self)) { index, cellVM, cell in
                cell.set(viewModel: cellVM)
            }.disposed(by: disposeBag)
    }
    
    private func cellSelectedSetup() {
        tableView.rx.itemSelected.subscribe(onNext: {[weak self] indexPath in
            
            guard let cellViewModel = self?.viewModel.cells.value[indexPath.row] else { return }
            
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            let trackDetailView: TrackDetailView = TrackDetailView.loadFromNib()
            trackDetailView.set(viewModel: cellViewModel)
            trackDetailView.trackMovingDelegate = self
            window?.addSubview(trackDetailView)
            
        }).disposed(by: disposeBag)
    }
    
}

//MARK: - TableViewDelegate

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Please enter search request above..."
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.cells.value.count > 0 ? 0 : 250
    }
}

//MARK: - Track

extension SearchViewController: TrackMovingDelegate {
    
    func moveBackForPreviousTrack() -> SearchViewModel.CellViewModel? {
        return getTrack(isForwardTrack: false)
    }
    
    func moveForwardForNextTrack() -> SearchViewModel.CellViewModel? {
        return getTrack(isForwardTrack: true)
    }
    
    private func getTrack(isForwardTrack: Bool) -> SearchViewModel.CellViewModel? {
        
        guard let indexPath = tableView.indexPathForSelectedRow  else { return nil }
        tableView.deselectRow(at: indexPath, animated: true)
        var nextIndexPath: IndexPath!
        
        if isForwardTrack {
            nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
            if nextIndexPath.row == viewModel.cells.value.count {
                nextIndexPath.row = 0
            }
        } else {
            nextIndexPath = IndexPath(row: indexPath.row - 1, section: 0)
            if nextIndexPath.row == -1 {
                nextIndexPath.row = viewModel.cells.value.count - 1
            }
        }
        
        tableView.selectRow(at: nextIndexPath, animated: true, scrollPosition: .none)
        let cellViewModel = viewModel.cells.value[nextIndexPath.row]
        return cellViewModel
    }
    
    
}
