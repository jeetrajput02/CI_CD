//
//  GroupVideoPlayer.swift
//  WhosNext
//
//  Created by differenz08 on 20/12/22.
//

import SwiftUI
import AVKit

public struct GroupVideoPlayer {
    var arrayVideoURL: [URL]
    var counter: Binding<Int>
    
    /// start the video at a specific time in seconds
    var startVideoAtSeconds: Binding<Double>
    
    /// if true the playback controler will be visible on the view
    var showsPlaybackControls: Bool = false
    
    /// if true the option to show the video in PIP mode will be available in the controls
    var allowsPictureInPicturePlayback: Bool = true
    
    /// if true the video sound will be muted
    var isMuted: Binding<Bool>
    
    /// how the video will resized to fit the view
    var videoGravity: AVLayerVideoGravity = .resizeAspectFill
    
    /// if true the video will loop itself when reaching the end of the video
    var loop: Binding<Bool> = .constant(false)
    
    /// if true the video will play itself automattically
    var isPlaying: Binding<Bool>
    
    /// allows sending back that last played seconds of the video for later playback at that location if needed
    var lastPlayInSeconds: Binding<Double>
    
    /// set how many seconds you want to rewind the video
    var backInSeconds: Binding<Double>
    
    /// set how many seconds you want to forward the video
    var forwardInSeconds: Binding<Double>
    
    public init(initArray: [URL], startVideoAtSeconds: Binding<Double> = .constant(0.0), playing: Binding<Bool> = .constant(true), muted: Binding<Bool> = .constant(false), counter: Binding<Int> = .constant(0)) {
        self.arrayVideoURL = initArray
        self.startVideoAtSeconds = startVideoAtSeconds
        self.isPlaying = playing
        self.isMuted = muted
        self.lastPlayInSeconds = .constant(0.0)
        self.backInSeconds = .constant(0.0)
        self.forwardInSeconds = .constant(0.0)
        self.counter = .constant(0)
    }
    
    /// `this determines if we need to start the video at a specific seconds point in time.  It resets that value if it's not zero`
    private func startAtSeconds() -> Double? {
        var startAtSeconds:Double? = nil
        if self.startVideoAtSeconds.wrappedValue != 0.0 {
            startAtSeconds = self.startVideoAtSeconds.wrappedValue
            DispatchQueue.main.async {
                if let startAtSeconds = startAtSeconds {
                    self.startVideoAtSeconds.wrappedValue = startAtSeconds
                }
            }
        }
        return startAtSeconds
    }
    
    /// `update for seek for forward/backward`
    private func updateForSeek(context: Context) -> Void {
        if self.backInSeconds.wrappedValue != 0.0 {
            context.coordinator.seekBackward(backInSeconds: self.backInSeconds.wrappedValue)
        }
        
        if self.forwardInSeconds.wrappedValue != 0.0 {
            context.coordinator.seekForward(forwardInSeconds: self.forwardInSeconds.wrappedValue)
        }
    }
}

// MARK: - GroupVideoPlayer (Make View)
#if os(iOS)
extension GroupVideoPlayer: UIViewControllerRepresentable {
    /// `make video controller`
    public func makeUIViewController(context: Context) -> AVPlayerViewController {
        let videoViewController = AVPlayerViewController()
        videoViewController.player = AVPlayer(url: self.arrayVideoURL[self.counter.wrappedValue])
        
        let videoCoordinator = context.coordinator
        videoCoordinator.player = videoViewController.player
        videoCoordinator.url = self.arrayVideoURL[self.counter.wrappedValue]
        
        return videoViewController
    }
    
    /// `update video controller`
    public func updateUIViewController(_ videoViewController: AVPlayerViewController, context: Context) -> Void {
        if self.arrayVideoURL[self.counter.wrappedValue] != context.coordinator.url {
            videoViewController.player = AVPlayer(url: self.arrayVideoURL[self.counter.wrappedValue])
            context.coordinator.player = videoViewController.player
            context.coordinator.url = self.arrayVideoURL[self.counter.wrappedValue]
        }
        
        videoViewController.showsPlaybackControls = self.showsPlaybackControls
        videoViewController.allowsPictureInPicturePlayback = self.allowsPictureInPicturePlayback
        videoViewController.player?.isMuted = self.isMuted.wrappedValue
        videoViewController.videoGravity = self.videoGravity
        context.coordinator.togglePlay(isPlaying: self.isPlaying.wrappedValue, startVideoAtSeconds: self.startAtSeconds())
        
        self.updateForSeek(context: context)
    }
    
    /// `make coordinator for video player`
    public func makeCoordinator() -> GroupVideoCoordinator {
        return GroupVideoCoordinator(video: self,counter: self.counter.wrappedValue)
    }
}
#endif

// MARK: - Coordinator Extensions
extension GroupVideoPlayer {
    /// `video coordinator`
    public class GroupVideoCoordinator: NSObject {
        var playerContext = "playerContext"
        let video: GroupVideoPlayer
        var timeObserver: Any?
        var counter: Int
        var url: URL?
        
        var player: AVPlayer? {
            didSet {
                self.removeTimeObserver(from: oldValue)
                self.removeKVOObservers(from: oldValue)
                self.addTimeObserver(to: self.player)
                self.addKVOObservers(to: self.player)
                NotificationCenter.default.addObserver(self, selector: #selector(GroupVideoPlayer.GroupVideoCoordinator.playerItemDidReachEnd), name: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
            }
        }
        
        init(video: GroupVideoPlayer,counter: Int) {
            self.video = video
            self.counter = counter
            super.init()
        }
        
        deinit {
            self.removeTimeObserver(from: self.player)
            self.removeKVOObservers(from: self.player)
        }
        
        override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) -> Void {
            guard context == &(self.playerContext), keyPath == "muted" || keyPath == "volume" else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
                return
            }
            
            if let player = self.player {
#if os(macOS)
                self.video.isMuted.wrappedValue = player.volume == 0
#else
                DispatchQueue.main.async {
                    self.video.isMuted.wrappedValue = player.isMuted
                }
#endif
            }
        }
    }
}

// MARK: - Observers for GroupVideoCoordinator
extension GroupVideoPlayer.GroupVideoCoordinator {
    /// `add time observers`
    private func addTimeObserver(to player: AVPlayer?) -> Void {
        self.timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 4), queue: nil, using: { [weak self] (time) in
            self?.updateStatus()
        })
    }
    
    /// `remove time observers`
    private func removeTimeObserver(from player: AVPlayer?) -> Void {
        if let timeObserver = self.timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
    }
    
    /// `add player observers`
    private func removeKVOObservers(from player: AVPlayer?) -> Void {
        player?.removeObserver(self, forKeyPath: "muted")
        player?.removeObserver(self, forKeyPath: "volume")
    }
    
    /// `remove player observers`
    private func addKVOObservers(to player: AVPlayer?) -> Void {
        player?.addObserver(self, forKeyPath: "muted", options: [.new, .old], context: &self.playerContext)
        player?.addObserver(self, forKeyPath: "volume", options: [.new, .old], context: &self.playerContext)
    }
}

// MARK: - Helper Functions
extension GroupVideoPlayer.GroupVideoCoordinator {
    /// `toggle play`
    func togglePlay(isPlaying: Bool, startVideoAtSeconds:Double?) -> Void {
        if isPlaying {
            if self.player?.currentItem?.duration == self.player?.currentTime() {
                self.counter += 1
                self.player?.seek(to: .zero)
                self.player?.play()
                
                return
            }
            
            self.seekOnStartToSecondsIfNeeded(startVideoAtSeconds: startVideoAtSeconds)
            self.player?.play()
        } else {
            self.seekOnStartToSecondsIfNeeded(startVideoAtSeconds: startVideoAtSeconds)
            self.player?.pause()
        }
    }
    
    /// `seek on start to seconds if needed`
    func seekOnStartToSecondsIfNeeded(startVideoAtSeconds:Double?) -> Void {
        if let startVideoAtSeconds = startVideoAtSeconds {
            let myTime = CMTime(seconds: startVideoAtSeconds, preferredTimescale: 1000)
            self.player?.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
            DispatchQueue.main.async {
                // reset it back to zero since we just seeked
                self.video.startVideoAtSeconds.wrappedValue = 0.0
            }
        }
    }
    
    /// `seek forward`
    func seekForward(forwardInSeconds: Double) -> Void {
        guard let player = self.player, let duration  = player.currentItem?.duration else {
            return
        }
        
        let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = playerCurrentTime + forwardInSeconds
        if newTime < (CMTimeGetSeconds(duration) - forwardInSeconds) {
            let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
            player.seek(to: time2, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        }
        
        DispatchQueue.main.async {
            // resets the value to be tapped again.
            self.video.forwardInSeconds.wrappedValue = 0.0
        }
    }
    
    /// `seek backward`
    func seekBackward(backInSeconds: Double) -> Void {
        guard let player = self.player, backInSeconds != .zero else { return }
        let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
        var newTime = playerCurrentTime - backInSeconds
        
        if newTime < 0 {
            newTime = 0
        }
        
        let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        player.seek(to: time2, toleranceBefore: .zero, toleranceAfter: .zero)
        
        DispatchQueue.main.async {
            // resets the value to be tapped again.
            self.video.backInSeconds.wrappedValue = 0.0
        }
    }
}

// MARK: - Selector Functions
extension GroupVideoPlayer.GroupVideoCoordinator {
    /// `checks that player item did reached end`
    @objc public func playerItemDidReachEnd(notification: NSNotification) -> Void {
        if self.video.loop.wrappedValue {
            self.player?.seek(to: .zero)
            
            if self.video.counter.wrappedValue == self.video.arrayVideoURL.count - 1 {
                self.video.counter.wrappedValue = 0
            } else {
                self.video.counter.wrappedValue += 1
            }
            
            self.video.isPlaying.wrappedValue = true
            self.player?.play()
        } else {
            self.video.startVideoAtSeconds.wrappedValue = 0.0
            
            if self.video.counter.wrappedValue == self.video.arrayVideoURL.count - 1 {
                self.video.counter.wrappedValue = 0
            } else {
                self.video.counter.wrappedValue += 1
            }
            
            self.video.isPlaying.wrappedValue = true
        }
    }
    
    /// `update the status for player`
    @objc public func updateStatus() -> Void {
        if let player = self.player {
            self.video.isPlaying.wrappedValue = player.rate > 0
            
            let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
            self.video.lastPlayInSeconds.wrappedValue = playerCurrentTime
        } else {
            self.video.isPlaying.wrappedValue = false
        }
    }
}

// MARK: - GroupVideo Modifiers
extension GroupVideoPlayer {
    /// `picture in picture playback`
    public func pictureInPicturePlayback(_ value:Bool) -> GroupVideoPlayer {
        var new = self
        new.allowsPictureInPicturePlayback = value
        
        return new
    }
    
    /// `shows playback controls`
    public func playbackControls(_ value: Bool) -> GroupVideoPlayer {
        var new = self
        new.showsPlaybackControls = value
        
        return new
    }
    
    /// `mute/unmute the player without binding`
    public func isMuted(_ value: Bool) -> GroupVideoPlayer {
        return isMuted(.constant(value))
    }
    
    /// `mute/unmute the player with binding`
    public func isMuted(_ value: Binding<Bool>) -> GroupVideoPlayer {
        var new = self
        new.isMuted = value

        return new
    }
    
    /// `play/pause video without binding`
    public func isPlaying(_ value: Bool) -> GroupVideoPlayer {
        let new = self
        new.isPlaying.wrappedValue = value
        
        return new
    }
    
    /// `play/pause video with binding`
    public func isPlaying(_ value: Binding<Bool>) -> GroupVideoPlayer {
        var new = self
        new.isPlaying = value
        
        return new
    }
    
    /// `last play in seconds`
    public func lastPlayInSeconds(_ value: Binding<Double>) -> GroupVideoPlayer {
        var new = self
        new.lastPlayInSeconds = value
        
        return new
    }
    
    /// `backward in seconds`
    public func backInSeconds(_ value: Binding<Double>) -> GroupVideoPlayer {
        var new = self
        new.backInSeconds = value
        
        return new
    }
    
    /// `forward in seconds`
    public func forwardInSeconds(_ value: Binding<Double>) -> GroupVideoPlayer {
        var new = self
        new.forwardInSeconds = value
        
        return new
    }
    
    /// `set the video gravity`
    public func videoGravity(_ value: AVLayerVideoGravity) -> GroupVideoPlayer {
        var new = self
        new.videoGravity = value
        
        return new
    }
    
    /// `loop for multiple videos without binding`
    public func loop(_ value: Bool) -> GroupVideoPlayer {
        self.loop.wrappedValue = value
        return self
    }
    
    /// `loop for multiple videos with binding`
    public func loop(_ value: Binding<Bool>) -> GroupVideoPlayer {
        var new = self
        new.loop = value
        
        return new
    }
    
    /// `increment counter without binding`
    public func incrementCounter(_ value: Int) -> GroupVideoPlayer {
        let new = self
        new.counter.wrappedValue = value
        
        return new
    }
    
    /// `increment counter with binding`
    public func incrementCounter(_ value: Binding<Int>) -> GroupVideoPlayer {
        var new = self
        new.counter = value
        
        return new
    }
}
