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
    
    
    //MARK: - VC Methods
    
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false
        
        searchController.searchBar.rx.text
            .throttle(.milliseconds(1500), scheduler: MainScheduler.instance)
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
        tableView.rx.itemSelected.subscribe(onNext: {[unowned self] indexPath in
            
            let cellViewModel = self.viewModel.cells.value[indexPath.row]
                
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                   let trackDetailView: TrackDetailView = TrackDetailView.loadFromNib()
                   trackDetailView.set(viewModel: cellViewModel)
//                   trackDetailView.delegate = self
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
