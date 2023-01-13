//
//  VoiceViewModel.swift
//  CO-Voice
//
//  Created by Mohammad Yasir on 13/02/21.
//

import Foundation
import AVFoundation
import UIKit

struct Recording: Equatable {
    let fileURL: URL
    let createdAt: Date
    var isPlaying: Bool
}

class RecordAudioViewModel : NSObject, ObservableObject , AVAudioPlayerDelegate {
    // MARK: - Variables
    @Published var mediaPickerType: SnippetMediaPickerType = .image
    @Published var shouldOpenMediaPicker: Bool = false
    @Published var image: UIImage? = nil
    @Published var audioThumbnailImage: UIImage? = nil
    @Published var snippetMediaType: Int = -1
    @Published var errorMsg: String = ""
    @Published var showError: Bool = false
    @Published var showValidationAlert: Bool = false
    @Published var validationMsg: String = ""
    @Published var audioURL: URL? = nil
    @Published var snippetDetails: String = ""
    @Published var isRecording : Bool = false
    @Published var recordingsList = [Recording]()
    @Published var countSec = 0
    @Published var timerCount : Timer?
    @Published var blinkingCount : Timer?
    @Published var timer : String = "0:00"
    @Published var toggleColor : Bool = false
    @Published var videoURL: URL? = nil
    @Published var audioRemote: String = ""
    @Published var audioThumbnail: String = ""
    
    var audioRecorder : AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var indexOfPlayer = 0
    var audioFileUrl: String?
    var playingURL : URL?
    
    override init() {
        super.init()
        
        self.fetchAllRecording()
    }
}

// MARK: - Functions
extension RecordAudioViewModel {
    /// `checks that audio player did finished playing`
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        for i in 0 ..< self.recordingsList.count {
            if self.recordingsList[i].fileURL == self.playingURL {
                self.recordingsList[i].isPlaying = false
            }
        }
    }
    
    /// `audio recorder manager`
    func audioRecoderManager() {
        /// `getting URL path for audio`
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docDir = dirPath[0]
        let soundFilePath = (docDir as NSString).appendingPathComponent("sound.caf")
        let soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        
        print(soundFilePath)
        
        self.audioFileUrl = soundFilePath
        
        /// `setting for recorder`
        let recordSettings = [
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
            AVEncoderBitRateKey: 16,
            AVNumberOfChannelsKey : 2,
            AVSampleRateKey: 44100.0
        ] as [String : Any]
        
        Utilities.setSessionPlayerOn()
        
        var error: NSError?
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
            self.audioRecorder = try AVAudioRecorder(url: soundFileURL as URL, settings: recordSettings as [String : AnyObject])
        } catch _ {
            print("Error")
        }
        
        if let err = error {
            print("audioSession error: \(err.localizedDescription)")
        } else {
            self.audioRecorder?.prepareToRecord()
        }
    }
    
    /// `starts recording`
    func startRecording() -> Void {
        let recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Cannot setup the Recording")
        }
        
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        //        let fileName = path.appendingPathComponent("WhosNext : \(Date().toString(dateFormat: "dd-MM-YY 'at' HH:mm:ss")).mp3")
        let fileName = path.appendingPathComponent("CO-Voice : \(Date().toString(dateFormat: "dd-MM-YY 'at' HH:mm:ss")).m4a")
        print("PATH--FILE--NAME == \(path)")
        self.audioURL = fileName
        print("AUDIO--NAME ==== \(self.audioURL?.absoluteString ?? "")")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            self.audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
            self.audioRecorder.prepareToRecord()
            self.audioRecorder.record()
            self.isRecording = true
            
            self.timerCount = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (value) in
                self.countSec += 1
                self.timer = self.covertSecToMinAndHour(seconds: self.countSec)
            })
            
            self.blinkColor()
        } catch {
            print("Failed to Setup the Recording")
        }
    }
    
    /// `stops recording`
    func stopRecording() -> Void {
        self.audioRecorder.stop()
        self.isRecording = false
        self.countSec = 0
        
        self.timerCount?.invalidate()
        self.blinkingCount?.invalidate()
    }
    
    /// `fetch all recording from local file storage`
    func fetchAllRecording() {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryContents = try! FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
        
        for i in directoryContents {
            self.recordingsList.append(Recording(fileURL: i, createdAt: self.getFileDate(for: i), isPlaying: false))
        }
        
        self.recordingsList.sort(by: { $0.createdAt.compare($1.createdAt) == .orderedDescending })
        
        
        if self.recordingsList.count > 0 {
            self.audioURL = recordingsList.last?.fileURL
            print(audioURL! as URL)
        }
    }
    
    /// `starts playing audio`
    func startPlaying(url: URL) -> Void {
        self.playingURL = url
        
        let playSession = AVAudioSession.sharedInstance()
        
        do {
            try playSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            print("Playing failed in Device")
        }
        
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: url)
            self.audioPlayer.delegate = self
            self.audioPlayer.prepareToPlay()
            self.audioPlayer.play()
            
            for i in 0 ..< self.recordingsList.count {
                if self.recordingsList[i].fileURL == url {
                    self.recordingsList[i].isPlaying = true
                }
            }
        } catch {
            print("Playing Failed")
        }
    }
    
    /// `stops playing audio`
    func stopPlaying(url: URL) -> Void {
        self.audioPlayer.stop()
        
        for i in 0 ..< self.recordingsList.count {
            if self.recordingsList[i].fileURL == url {
                self.recordingsList[i].isPlaying = false
            }
        }
    }
    
    /// `delete recording from local`
    func deleteRecording(url: URL) -> Void {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Can't delete")
        }
        
        for i in 0 ..< self.recordingsList.count {
            if self.recordingsList[i].fileURL == url {
                if self.recordingsList[i].isPlaying == true{
                    self.stopPlaying(url: self.recordingsList[i].fileURL)
                }
                
                self.recordingsList.remove(at: i)
                break
            }
        }
    }
    
    /// `blink time value`
    func blinkColor() -> Void {
        self.blinkingCount = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (value) in
            self.toggleColor.toggle()
        })
    }
    
    /// `get file date from url`
    func getFileDate(for file: URL) -> Date {
        if let attributes = try? FileManager.default.attributesOfItem(atPath: file.path) as [FileAttributeKey: Any],
           let creationDate = attributes[FileAttributeKey.creationDate] as? Date {
            return creationDate
        } else {
            return Date()
        }
    }
    
    /// `reset media picket type`
    func resetMediaPickerType() -> Void {
        DispatchQueue.main.async {
            if self.mediaPickerType == .image {
                self.audioURL = nil
            } else if self.mediaPickerType == .video {
                self.image = nil
                self.audioURL = nil
            } else if self.mediaPickerType == .audio {
                self.image = nil
            }
        }
    }
    
    /// `converts seconds into mins and hours`
    func covertSecToMinAndHour(seconds: Int) -> String {
        let (_, m, s) = (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
        let sec : String = s < 10 ? "0\(s)" : "\(s)"
        return "\(m):\(sec)"
        
    }
    
    /// `validations`
    func validations() -> Bool {
        if self.image == nil && self.audioURL == nil {
            self.validationMsg = "Please select media."
            self.showValidationAlert = true
            
            return false
        } else if self.snippetDetails.isEmpty {
            self.validationMsg = "Please enter some details about snippet."
            self.showValidationAlert = true
            
            return false
        } else {
            self.validationMsg = ""
            self.showValidationAlert = false
            
            return true
        }
    }
}

// MARK: - API Calls
extension RecordAudioViewModel {
    /// `create snippet with audio`
    func createSnippetWithAudio(completion: @escaping () -> Void) {
        if self.validations() {
            guard let audioUrl = self.audioURL else { return }

            Indicator.show()

            AWSS3Manager.shared.uploadAudio(audio: audioUrl, bucketname: .snippetAudio, withSuccess: { fileURL, audioName -> Void in
                guard let audioName = audioName.split(separator: "/").last else { return }
                self.audioRemote = String(audioName)
                
                guard let image = self.image else { return }

                AWSS3Manager.shared.uploadImage(image: image, bucketname: .snippetThumb, withSuccess: { fileUrl, audioThumbName -> Void in
                    guard let thumbnailName = audioThumbName.split(separator: "/").last else { return }
                    
                    self.audioThumbnail = String(thumbnailName)
                    
                    let param = [
                        SnippetModelKeys.snippet_id.rawValue : nil,
                        SnippetModelKeys.snippet_type.rawValue : self.snippetMediaType,
                        SnippetModelKeys.snippet_file.rawValue : self.audioRemote,
                        SnippetModelKeys.snippet_thumbnail_file.rawValue : self.audioThumbnail,
                        SnippetModelKeys.snippet_detail.rawValue : self.snippetDetails
                    ] as [ String : Any?]
                    
                    CreateSnippetModel.createSnippetApiCall(params: param as [String: Any], success: { response, message -> Void in
                        print(response!)
                        print(message)
                        completion()
                        Indicator.hide()
                    }, failure: { error -> Void in
                        self.errorMsg = error
                        self.showError = true
                        Indicator.hide()
                    })
                }, failure: { error -> Void in }, connectionFail: { error -> Void in })
            }, failure: { error -> Void in }, connectionFail: { error -> Void in })
        }
    }
}
