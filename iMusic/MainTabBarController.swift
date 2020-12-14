//
//  MainTabBarController.swift
//  iMusic
//
//  Created by Maxim Alekseev on 12.12.2020.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    private let searchVC: SearchViewController = SearchViewController.loadFromStoryboard()
    private let libraryVC: LibraryViewController = LibraryViewController.loadFromStoryboard()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = #colorLiteral(red: 1, green: 0, blue: 0.3764705882, alpha: 1)
        
        viewControllers = [
            generateNavigationController(rootViewController: searchVC, title: SearchViewController.vcName, image: #imageLiteral(resourceName: "ios10-apple-music-search-5nav-icon")),
            generateNavigationController(rootViewController: libraryVC, title: LibraryViewController.vcName, image: #imageLiteral(resourceName: "ios10-apple-music-library-5nav-icon"))
        ]
        
    }

    
    private func generateNavigationController(rootViewController: UIViewController, title: String, image: UIImage) -> UINavigationController {
        let navigationVC = UINavigationController(rootViewController: rootViewController)
        navigationVC.tabBarItem.image = image
        rootViewController.navigationItem.title = title
        navigationVC.tabBarItem.title = title
        navigationVC.navigationBar.prefersLargeTitles = true
        return navigationVC
    }
}
