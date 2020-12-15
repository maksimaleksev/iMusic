//
//  FooterView.swift
//  iMusic
//
//  Created by Maxim Alekseev on 15.12.2020.
//

import UIKit

class FooterView: UIView {
    
    private var myLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = #colorLiteral(red: 0.631372549, green: 0.6470588235, blue: 0.662745098, alpha: 1)
        return label
    }()
    
    private var loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView()
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.hidesWhenStopped = true
        return loader
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupElements()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupElements() {
        [myLabel, loader].forEach { addSubview($0) }
        
        NSLayoutConstraint.activate([
            loader.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            loader.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            loader.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            myLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            myLabel.topAnchor.constraint(equalTo: loader.bottomAnchor, constant: 8)
        ])
    }
    
    func showLoader() {
        loader.startAnimating()
        myLabel.text = "LOADING..."
    }
    
    func hideLoader() {
        loader.stopAnimating()
        myLabel.text = ""
    }
    
}
