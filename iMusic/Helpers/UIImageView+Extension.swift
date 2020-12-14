//
//  UIImageView+Extension.swift
//  iMusic
//
//  Created by Maxim Alekseev on 14.12.2020.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    func webImage(_ URLString: String, placeHolder: UIImage?) {
        
        self.image = nil
        
        if let cachedImage = imageCache.object(forKey: NSString(string: URLString)) {
            self.image = cachedImage
            return
        }
        
        guard let url = URL(string: URLString) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            
            if error != nil {
                
                print("ERROR WHILE LOADING IMAGE FROM URL: \(error!.localizedDescription)")
                
                DispatchQueue.main.async {
                    self.image = placeHolder
                }
                
                return
            }
            
            guard let data = data, let downloadedImage = UIImage(data: data) else {
                print("Cannot decode image data")
                return
            }
            
            imageCache.setObject(downloadedImage, forKey: NSString(string: URLString))
            
            DispatchQueue.main.async {
                self.image = downloadedImage
            }
            
        }.resume()
        
    }
}
