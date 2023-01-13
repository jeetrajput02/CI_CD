//
//  DetailVideoPlater.swift
//  WhosNext
//
//  Created by differenz104 on 08/12/22.
//

import SwiftUI
import AVKit

struct DetailVideoViewController: UIViewControllerRepresentable {
    var videoURL: URL?
    var showControls: Bool = true
    @Binding var remainingTimeSeconds: String
    @Binding var remainingTimeMinutes: String
    @State var isPlaying: Bool = false
    
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
        controller.showsPlaybackControls = showControls
        let duration = controller.player!.currentItem!.asset.duration
        let cTime = CMTimeGetSeconds(duration)
        let intCurrentTIme = Int(cTime)
        Indicator.hide()
        
        if(controller.player?.isPlaying == true){
            getCurrentTime(videoPlayer: controller,timeTotal: intCurrentTIme)
        }
        
        return controller
    }
    
    func getCurrentTime(videoPlayer: AVPlayerViewController, timeTotal: Int) -> Void {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        videoPlayer.player?.addPeriodicTimeObserver(forInterval: time, queue: .main, using: { time in
            let cTime = CMTimeGetSeconds(time)
            let intCurrentTIme = Int(cTime)
            let remainingTimeInt = timeTotal - intCurrentTIme
            let timeTuple = secondsToHoursMinutesSeconds(remainingTimeInt)
            self.remainingTimeMinutes = convertToString(timeTuple.1)
            self.remainingTimeSeconds = convertToString(timeTuple.2)
        })
    }
    
    func convertToString(_ time: Int) -> String {
        if time > 9 {
            return String(time)
        }
        else {
            return "0\(String(time))"
        }
    }
    
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }

    
    func updateUIViewController(_ playerController: AVPlayerViewController, context: Context) {}
}
