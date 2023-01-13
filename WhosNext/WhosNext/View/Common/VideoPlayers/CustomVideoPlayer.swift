//
//  CustomVideoPlayer.swift
//  WhosNext
//
//  Created by differenz240 on 01/12/22.
//

import SwiftUI
import AVKit

// MARK: - CustomVideoPlayer
struct CustomVideoPlayer: UIViewControllerRepresentable {
    var videoURL: URL
    // var videoThumbnailUrl: URL
    var isAutoPlay: Bool
    
    private var player: AVPlayer {
        return AVPlayer(url: self.videoURL)
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = CustomPlayerController()
        controller.isAutoPlay = self.isAutoPlay
        // controller.videoThumbnailUrl = self.videoThumbnailUrl
        
        controller.player = self.player
        controller.requiresLinearPlayback = true
        controller.showsPlaybackControls = false
        controller.entersFullScreenWhenPlaybackBegins = false
        controller.videoGravity = .resize
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}

// MARK: - CustomPlayerController
private class CustomPlayerController: AVPlayerViewController {
    private let loader = UIActivityIndicatorView(style: .large)
    // private var thumbnailImage = UIImageView()
    
    var isAutoPlay: Bool = false
    // var videoThumbnailUrl: URL? = nil
    
    /// `viewDidAppear`
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /* self.setupThumbnailImage()
        self.setupLoader() */
        
        if self.player != nil {
            self.addObservers()
            self.player?.play()
        }
    }
    
    /// `viewWillDisappear`
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.player != nil {
            self.removeObservers()
            
            self.player?.pause()
            self.player = nil

            if self.view.subviews.count > 0 {
                self.view.subviews.forEach({ $0.removeFromSuperview() })
            }
        }
    }
    
    /// `obvserver for player`
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayer.status), let change = change, let newValue = change[.newKey] as? Int, let oldValue = change[.oldKey] as? Int {
            
            let oldStatus = AVPlayer.Status(rawValue: oldValue)
            let newStatus = AVPlayer.Status(rawValue: newValue)
            
            if newStatus != oldStatus {
                DispatchQueue.main.async { [weak self] in
                    if newStatus == .readyToPlay {
                        // self?.loader.stopAnimating()
                        
                        if let subviews = self?.view.subviews {
                            if subviews.count > 0 {
                                self?.view.subviews.forEach({
                                    if $0 is UIActivityIndicatorView || $0 is UIImageView {
                                        $0.removeFromSuperview()
                                    }
                                })
                            }
                        }
                        
                        if self?.view.subviews.count == 1 {
                            self?.player?.play()
                        }
                        
                        print("subviews: \(self?.view.subviews ?? [])")
                    } else {
                        // self?.loader.startAnimating()
                    }
                }
            } else {
                // self.loader.startAnimating()
            }
        }
    }
}

// MARK: - Observer Functions
extension CustomPlayerController {
    /// `add observers`
    func addObservers() -> Void {
        self.player?.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: [.old, .new], context: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playVideo(notification:)), name: .playVideo, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.pauseVideo(notification:)), name: .pauseVideo, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.mutePlayer(notificaton:)), name: .mutePlayer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.unMutePlayer(notificaton:)), name: .unMutePlayer, object: nil)
        
        if self.isAutoPlay {
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(notificaton:)), name: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
        }
    }
    
    /// `remove observers`
    func removeObservers() -> Void {
        
        self.player?.removeObserver(self, forKeyPath: #keyPath(AVPlayer.status), context: nil)
    
        NotificationCenter.default.removeObserver(self, name: .playVideo, object: nil)
        NotificationCenter.default.removeObserver(self, name: .pauseVideo, object: nil)
        NotificationCenter.default.removeObserver(self, name: .mutePlayer, object: nil)
        NotificationCenter.default.removeObserver(self, name: .unMutePlayer, object: nil)
        
        if self.isAutoPlay {
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        }
    }
}

// MARK: - Selector Functions
extension CustomPlayerController {
    /// `replay the video`
    @objc func playerDidFinishPlaying(notificaton: Notification) -> Void {
        self.player?.seek(to: .zero)
        self.player?.play()
    }
    
    /// `play video`
    @objc func playVideo(notification: Notification) -> Void {
        self.player?.play()
    }
    
    /// `pause video`
    @objc func pauseVideo(notification: Notification) -> Void {
        self.player?.pause()
    }
    
    /// `mute player`
    @objc func mutePlayer(notificaton: Notification) -> Void {
        self.player?.isMuted = true
    }
    
    /// `unmute player`
    @objc func unMutePlayer(notificaton: Notification) -> Void {
        self.player?.isMuted = false
    }
}

// MARK: - UI Helpers
/* extension CustomPlayerController {
    /// `setup thumbnail image`
    func setupThumbnailImage() -> Void {
        if self.videoThumbnailUrl != nil {
            self.thumbnailImage.sd_setImage(with: self.videoThumbnailUrl, placeholderImage: UIImage(named: "video_thumb_placeholder"), context: nil)
            self.thumbnailImage.center = self.view.center
            self.thumbnailImage.frame = self.view.bounds

            self.view.addSubview(self.thumbnailImage)
        }
    }
 
    /// `setup loader`
    func setupLoader() -> Void {
        self.loader.frame = self.view.bounds
        self.loader.translatesAutoresizingMaskIntoConstraints = true
        self.loader.startAnimating()
        self.loader.hidesWhenStopped = true
        self.loader.backgroundColor = .black
        self.loader.color = .gray
        self.view.addSubview(self.loader)
        self.loader.center = self.view.center
    }
} */
