//
//  PlayerViewController.swift
//  WhosNext
//
//  Created by differenz240 on 01/12/22.
//

import SwiftUI
import AVKit

// MARK: - Player UIViewControllerRepresentable
struct PlayerViewController: UIViewControllerRepresentable {
    
    var videoURL: URL?
    var showControls: Bool = true
    @State var timeTotal: Int? = 0

    private var player: AVPlayer? {
        if self.videoURL != nil {
            return AVPlayer(url: self.videoURL!)
        } else {
            return AVPlayer()
        }
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller =  AVPlayerViewController()
        controller.modalPresentationStyle = .overFullScreen
        controller.player = self.player
        controller.player?.play()
        controller.showsPlaybackControls = self.showControls
//        Indicator.show()
        let duration = controller.player?.currentItem?.asset.duration
        
        Indicator.hide()
        return controller
    }

    
    func updateUIViewController(_ playerController: AVPlayerViewController, context: Context) {}
}
