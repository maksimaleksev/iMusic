//
//  UIViewController+Extension.swift
//  iMusic
//
//  Created by Maxim Alekseev on 19.12.2020.
//

import UIKit

extension UIViewController {
       
    class func loadFromStoryboard<T: UIViewController>() -> T {
            let name = String(describing: T.self)
            let storyboard = UIStoryboard(name: name, bundle: nil)
            if let viewController = storyboard.instantiateInitialViewController() as? T {
                return viewController
            } else {
                fatalError("Error: No initial view controller in \(name) storyboard!")
            }
        }
}
