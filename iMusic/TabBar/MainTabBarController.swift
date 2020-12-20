//
//  MainTabBarController.swift
//  iMusic
//
//  Created by Maxim Alekseev on 12.12.2020.
//

import UIKit
import RxSwift
import RxCocoa

protocol MainTabBarControllerDelegate: class {
    func minimizeTrackDetailController()
    func maximizeTrackDetailController(viewModel: SearchViewModel.CellViewModel?)
}


class MainTabBarController: UITabBarController {
    
    //MARK: - Vars and constants
    private let disposeBag = DisposeBag()
    private let searchVC: SearchViewController = SearchViewController.loadFromStoryboard()
    private let libraryVC: LibraryViewController = LibraryViewController.loadFromStoryboard()
    let trackDetailView: TrackDetailView = TrackDetailView.loadFromNib()

    
    private var minimizedTopAnchorConstraint: NSLayoutConstraint!
    private var maximizedTopAnchorConstraint: NSLayoutConstraint!
    private var bottomAnchorConstraint: NSLayoutConstraint!

//MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = #colorLiteral(red: 1, green: 0, blue: 0.3764705882, alpha: 1)
        searchVC.mainTabBarDelegate = self
        libraryVC.mainTabBarDelegate = self
        viewControllers = [
            generateNavigationController(rootViewController: searchVC, title: SearchViewController.vcName, image: #imageLiteral(resourceName: "ios10-apple-music-search-5nav-icon")),
            generateNavigationController(rootViewController: libraryVC, title: LibraryViewController.vcName, image: #imageLiteral(resourceName: "ios10-apple-music-library-5nav-icon"))
        ]
        
        setupTrackDetailView()
    }

//MARK: - Setup
    private func generateNavigationController(rootViewController: UIViewController, title: String, image: UIImage) -> UINavigationController {
        let navigationVC = UINavigationController(rootViewController: rootViewController)
        navigationVC.tabBarItem.image = image
        rootViewController.navigationItem.title = title
        navigationVC.tabBarItem.title = title
        navigationVC.navigationBar.prefersLargeTitles = true
        return navigationVC
    }
    
    private func setupTrackDetailView() {
                
        trackDetailView.tabBarDelegate = self
        trackDetailView.trackMovingDelegate = searchVC

        
        //use AutoLayout
        
        trackDetailView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(trackDetailView, belowSubview: tabBar)
        
        maximizedTopAnchorConstraint = trackDetailView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        minimizedTopAnchorConstraint = trackDetailView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
        bottomAnchorConstraint = trackDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
        
        bottomAnchorConstraint.isActive = true
        maximizedTopAnchorConstraint.isActive = true

        trackDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        trackDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    }
}

//MARK: - Work with TrackDetailView

extension MainTabBarController: MainTabBarControllerDelegate {
    
    func maximizeTrackDetailController(viewModel: SearchViewModel.CellViewModel?) {
        
        minimizedTopAnchorConstraint.isActive = false
        maximizedTopAnchorConstraint.isActive = true
        maximizedTopAnchorConstraint.constant = 0
        bottomAnchorConstraint.constant = 0
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                       animations: {[weak self] in
                        self?.view.layoutIfNeeded()
                        self?.tabBar.alpha = 0
                        self?.trackDetailView.miniTrackView.alpha = 0
                        self?.trackDetailView.maximizedStackView.alpha = 1
        },
                       completion: nil)
        
        guard let viewModel = viewModel else { return }
        self.trackDetailView.set(viewModel: viewModel)
    }
    
    func minimizeTrackDetailController() {
        maximizedTopAnchorConstraint.isActive = false
        bottomAnchorConstraint.constant = view.frame.height
        minimizedTopAnchorConstraint.isActive = true
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                       animations: {[weak self] in
                        self?.view.layoutIfNeeded()
                        self?.tabBar.alpha = 1
                        self?.trackDetailView.miniTrackView.alpha = 1
                        self?.trackDetailView.maximizedStackView.alpha = 0
        },
                       completion: nil)
    }
    
}
