//
//  LibraryViewController.swift
//  iMusic
//
//  Created by Maxim Alekseev on 13.12.2020.
//

import UIKit
import RxSwift

class LibraryViewController: UIViewController {
    
    static let vcName = "Library"
    private let disposeBag = DisposeBag()
    private let viewModel = LibraryViewModel()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        populateTableView()
        deleteTableViewCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.cellsReload()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playButton.layer.cornerRadius = 5
    }
    
    //MARK: - Setup Table View
    
    private func setupTableView() {
        let nib = UINib(nibName: TrackCell.reuseId, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: TrackCell.reuseId)
//        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }
    
    private func populateTableView() {
        viewModel.cells.asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(cellIdentifier: TrackCell.reuseId, cellType: TrackCell.self)) { index, cellVM, cell in
                cell.set(viewModel: cellVM)
            }.disposed(by: disposeBag)
    }
    
//    private func cellSelectedSetup() {
//        tableView.rx.itemSelected.subscribe(onNext: {[weak self] indexPath in
//
//
//        }).disposed(by: disposeBag)
//    }
    
    private func deleteTableViewCell() {
        tableView.rx.itemDeleted.subscribe { [weak self] in
            self?.viewModel.deleteCellVM(at: $0.row)
        }.disposed(by: disposeBag)
    }

    
}
