//
//  AVPlayerControllerRepresented.swift
//  WhosNext
//
//  Created by differenz240 on 01/12/22.
//

import SwiftUI
import AVKit

struct AVPlayerControllerRepresented: UIViewRepresentable {
    let player : AVPlayer?
    var url: URL?
    
    func makeUIView(context: Context) -> UIView {
        guard let player = self.player else { return UIView() }

        return PlayerUIView(player: player)
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<AVPlayerControllerRepresented>) {}
}

fileprivate class PlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()
    // private let playerViewController = AVPlayerViewController()
    
    init(player: AVPlayer) {
        super.init(frame: .zero)
        
        self.playerLayer.player = player
        self.playerLayer.videoGravity = .resize
        
        self.layer.addSublayer(self.playerLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.playerLayer.frame = self.bounds
    }
}
