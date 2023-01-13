//
//  AudioPlayerView.swift
//  WhosNext
//
//  Created by differenz104 on 08/12/22.
//

import SwiftUI
import AVKit
import SDWebImageSwiftUI

struct AudioPlayerView: View {
    @State var videoPlayer: AVPlayer?
    @State var audioPlayer1: AVPlayer?
    @State var snippetData: HomeSinppetData
    @State var navigate: Bool = false
    @Binding var navigateToRoot: Bool
    
    @State var remainingTimeSeconds: String = "00"
    @State var remainingTimeMinutes: String = "00"
    
    var body: some View {
        ZStack {
            NavigationLink("", isActive: $navigate) {
                AllSnippetsDetailView(currentData: self.snippetData, navigateToRoot: self.$navigateToRoot)
            }
            VStack {
                HStack{
                    Spacer()
                    Text("\(self.remainingTimeMinutes):\(self.remainingTimeSeconds)")
                        .foregroundColor(Color.myDarkCustomColor)
                        .background(Color.myCustomColor)
                        .padding(.all)
                        .padding(.trailing,-16)
                        .frame(alignment: .center)
                    Spacer()
                    Button {
                        self.audioPlayer1?.pause()
                        self.navigate = true
                    } label: {
                        Image(IdentifiableKeys.ImageName.kClose)
                            .resizable()
                    }
                    .frame(width: 22,height: 22,alignment: .trailing)
                    .padding(.trailing , 10)
                }
                Spacer()
                if(self.snippetData.snippetType == 3){
                    WebImage(url: URL(string: snippetData.snippetThumb!))
                        .placeholder(Image(systemName: "person.fill").resizable())
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.6 , alignment: .center)
                }
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            let stringURL = self.snippetData.snippetFile
            let AVPlayerItem = AVPlayerItem(url: NSURL(string: stringURL!)! as URL)
            DispatchQueue.main.async {
                self.audioPlayer1 = try? AVPlayer(playerItem: AVPlayerItem)
                self.audioPlayer1?.play()
                getCurrentTime(audioPlayer: self.audioPlayer1!)
            }
        }
    }
}
extension AudioPlayerView {
    func getCurrentTime(audioPlayer: AVPlayer){
        let asset = AVAsset(url: URL(string: self.snippetData.snippetFile!)!)
        let duration = asset.duration
        let timeTotal = Int(CMTimeGetSeconds(duration))
        Indicator.hide()
        print(timeTotal)
        
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        
        audioPlayer.addPeriodicTimeObserver(forInterval: time, queue: .main, using: { time in
            let cTime = CMTimeGetSeconds(time)
            let intCurrentTIme = Int(cTime)
            print(intCurrentTIme)
            let remainingTimeInt = timeTotal - intCurrentTIme
            let timeTuple = secondsToHoursMinutesSeconds(remainingTimeInt)
            self.remainingTimeMinutes = convertToString(timeTuple.1)
            self.remainingTimeSeconds = convertToString(timeTuple.2)
        })
    }
    
    func convertToString(_ time: Int) -> String{
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
    
}




