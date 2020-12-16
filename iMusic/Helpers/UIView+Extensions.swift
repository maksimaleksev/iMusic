//
//  UIView+Extensions.swift
//  iMusic
//
//  Created by Maxim Alekseev on 16.12.2020.
//

import UIKit

extension UIView {
    
    class func loadFromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)?.first as! TrackDetailView as! T
    }
    
}
