//
//  TrackDetailView.swift
//  iMusic
//
//  Created by Maxim Alekseev on 15.12.2020.
//

import UIKit
import RxCocoa
import RxSwift
import AVKit

class TrackDetailView: UIView {
    
    //MARK: - Vars and constants
    
    private let disposeBag = DisposeBag()
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var dragDownButton: UIButton!
    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var currentTimeSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var previousTrackButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextTrackButton: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    
    //MARK: - awakeFromNib
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let scale: CGFloat = 0.8
        trackImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        trackImageView.layer.cornerRadius = 5
        
        currentTimeSlider.setThumbImage(#imageLiteral(resourceName: "Knob"), for: .normal)
        
        setupDragDownButton()
        setupPlayPauseButton()
    }
    
    //MARK: - Setup UI Data
    
    func set(viewModel: SearchViewModel.CellViewModel) {
        
        trackTitleLabel.text = viewModel.trackName
        artistNameLabel.text = viewModel.artistName
        playTrack(previewURL: viewModel.previewUrl)
        monitorStartTime()
        guard let string600 = viewModel.iconUrlString?.replacingOccurrences(of: "100x100", with: "600x600") else { return }
        
        trackImageView.webImage(string600, placeHolder: #imageLiteral(resourceName: "albumImagePlaceholderBig"))
    }
    
    private func playTrack(previewURL: String?) {
        guard let url = URL(string: previewURL ?? "") else { return }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    private func monitorStartTime() {
        
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            self?.enlargeTrackImageView()
        }
    }
    
    //MARK: - Setup control methods
    
    private func setupDragDownButton() {
        dragDownButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.removeFromSuperview()
        }).disposed(by: disposeBag)
    }
    
    private func setupPlayPauseButton() {
        playPauseButton.rx.tap.subscribe(onNext: { [weak self] in
            
            if self?.player.timeControlStatus == .paused {
                self?.player.play()
                self?.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                self?.enlargeTrackImageView()
            } else {
                self?.player.pause()
                self?.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
                self?.reduceTrackImageView()
            }
            
        }).disposed(by: disposeBag)
    }
    
    //MARK:- Animations
    
    private func enlargeTrackImageView() {
        
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                       animations: { [weak self] in self?.trackImageView.transform = .identity },
                       completion: nil)
        
    }
    
    private func reduceTrackImageView() {
        
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                       animations: { [weak self] in
                        let scale: CGFloat = 0.8
                        self?.trackImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
                       },
                       completion: nil)
        
    }

}

