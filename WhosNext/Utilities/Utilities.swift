//
//  Utilities.swift
//  WhosNext
//
//  Created by differenz240 on 29/11/22.
//

import AVKit

class Utilities {
    /// get `thumbnail` image from video
    class func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }
        
        return nil
    }
    
    /// get `width & height` of video
    class func getWidthHeightOfVideo(with fileURL: URL) -> [Double] {
        guard let track = AVURLAsset(url: fileURL).tracks(withMediaType: .video).first else { return [0.0, 0.0] }
        let size = track.naturalSize.applying(track.preferredTransform)
        
        
        let resolution: CGSize? = CGSize(width: abs(size.width), height: abs(size.height))
        guard let width = resolution?.width, let height = resolution?.height else { return [0.0, 0.0] }
        
        return [width, height]
    }

    /// `set session player`
    class func setSessionPlayerOn() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
        } catch let error {
            print(error.localizedDescription)
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error {
            print(error.localizedDescription)
        }
        
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch let error {
            print(error.localizedDescription)
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, options: [.defaultToSpeaker,.allowBluetooth])
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    /// `download` local file
    func downloadLocalFile(withUrl url: URL, fileData: Data, completion: @escaping (_ filePath: URL) -> Void) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        var lastpath = url.lastPathComponent
        if lastpath == "sound.caf" {
            lastpath = "\(UUID().uuidString).caf"
        }

        let filePath =  documentsDirectory.appendingPathComponent(lastpath, isDirectory: false)
        
        DispatchQueue.global(qos: .background).async {
            do {
                let data = fileData
                try data.write(to: filePath, options: .atomic)
                DispatchQueue.main.async {
                    completion(filePath)
                }
            } catch {
                print("an error happened while downloading or saving the file")
            }
        }
    }
}
