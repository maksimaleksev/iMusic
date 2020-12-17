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

protocol TrackMovingDelegate: class {
    func moveBackForPreviousTrack() -> SearchViewModel.CellViewModel?
    func moveForwardForNextTrack() -> SearchViewModel.CellViewModel?
}

class TrackDetailView: UIView {
    
    //MARK: - Vars and constants
    
    private let disposeBag = DisposeBag()
    private let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    //MARK: - Delegates
    weak var trackMovingDelegate: TrackMovingDelegate?
    
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
        handleCurrentTimeSlider()
        handleVolumeSlider()
        goToNextTrack()
        goToPreviousTrack()
    }
    
    deinit {
        print("Deinit TrackDetailView")
    }
    
    //MARK: - Setup UI Data
    
    func set(viewModel: SearchViewModel.CellViewModel) {
        
        trackTitleLabel.text = viewModel.trackName
        artistNameLabel.text = viewModel.artistName
        playTrack(previewURL: viewModel.previewUrl)
        monitorStartTime()
        observePlayerCurrentTime()
        guard let string600 = viewModel.iconUrlString?.replacingOccurrences(of: "100x100", with: "600x600") else { return }
        
        trackImageView.webImage(string600, placeHolder: #imageLiteral(resourceName: "albumImagePlaceholderBig"))
    }
    
    private func playTrack(previewURL: String?) {
        guard let url = URL(string: previewURL ?? "") else { return }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    //MARK: - IBAction
    
    @IBAction func handleCurrentTimeSlider(_ sender: UISlider) {
        
        let percentage = Float64(currentTimeSlider.value)
        guard let duration = self.player.currentItem?.duration else { return }
        let duratioInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = percentage * duratioInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)
        self.player.seek(to: seekTime)
    }
    
    //MARK: - Setup control methods
    
    //Setup action for dragDownButton
    private func setupDragDownButton() {
        dragDownButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.removeFromSuperview()
        }).disposed(by: disposeBag)
    }
    
    //Setup action for playPauseButton
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
    
    //Setup action for currentTimeSlider
    private func handleCurrentTimeSlider() {
        currentTimeSlider.rx.value.asObservable().subscribe(onNext: { [weak self] value in
            let percentage = Float64(value)
            guard let duration = self?.player.currentItem?.duration else { return }
            let duratioInSeconds = CMTimeGetSeconds(duration)
            let seekTimeInSeconds = percentage * duratioInSeconds
            let seekTime: CMTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1000)
            self?.player.seek(to: seekTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        }).disposed(by: disposeBag)
    }
    
    //Setup action for volumeSlider
    private func handleVolumeSlider() {
        volumeSlider.rx.value.asObservable().subscribe(onNext: { [weak self] value in
            self?.player.volume = value
        }).disposed(by: disposeBag)
    }
    
    //Setup action for previousTrackButton
    private func goToPreviousTrack() {
        previousTrackButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let cellViewModel = self?.trackMovingDelegate?.moveBackForPreviousTrack() else { return }
            self?.set(viewModel: cellViewModel)
        }).disposed(by: disposeBag)
    }
    
    //Setup action for nextTrackButton
    private func goToNextTrack() {
        nextTrackButton.rx.tap.subscribe(onNext: { [weak self] in
            
            guard let cellViewModel = self?.trackMovingDelegate?.moveForwardForNextTrack() else { return }
            self?.set(viewModel: cellViewModel)
            
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
    
    //MARK: - Playback time setup
    
    private func monitorStartTime() {
        
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            self?.enlargeTrackImageView()
        }
    }
    
    private func observePlayerCurrentTime() {
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTimeLabel.text = time.toDisplayString()
            
            let durationTime = self?.player.currentItem?.duration
            let currentDurationText = ((durationTime ?? CMTimeMake(value: 1, timescale: 1)) - time).toDisplayString()
            self?.durationLabel.text = "-\(currentDurationText)"
            self?.updateCurrentTimeSlider()
        }
    }
    
    private func updateCurrentTimeSlider() {
        
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        let percentage = Float(currentTimeSeconds / durationSeconds)
        self.currentTimeSlider.value = percentage
    }
}

