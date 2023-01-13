//
//  SnippetViewModel.swift
//  WhosNext
//
//  Created by differenz240 on 15/11/22.
//

import SwiftUI
import AVKit

enum SnippetMediaPickerType {
    case main, image, video, audio
}

class SnippetViewModel: ObservableObject {
    // MARK: - Variables
    @Published var createSnippetModel: CreateSnippetModel? = nil
    @Published var getSnippetListModel: GetSnippetListModel? = nil
    @Published var snippetRequestList: [SnippetRequestData] = []

    @Published var currentpage: Int = 1
    
    @Published var mediaPickerType: SnippetMediaPickerType = .main

    @Published var isSideBarOpened: Bool = false
    @Published var shouldOpenMediaPicker: Bool = false

    @Published var image: UIImage? = nil
    @Published var audioThumbnailImage: UIImage? = nil
    @Published var videoURL: URL? = nil
    @Published var audioURL: URL? = nil
    
    @Published var snippetMediaType: Int = 1
    @Published var snippetDetails: String = ""
    
    @Published var errorMsg: String = ""
    @Published var showError: Bool = false
    
    @Published var showValidationAlert: Bool = false
    @Published var validationMsg: String = ""
    
    @Published var audioRemote: String = ""
    @Published var videoRemote: String = ""
    @Published var videoThumbnailRemote: String = ""
    @Published var snippetImageRemote: String = ""
    @Published var snippetImageThumbRemote: String = ""
    
    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    var param: [String : Any] = [ : ]
}

// MARK: - Functions
extension SnippetViewModel {
    /// get `thumbnail` image from video
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }
        
        return nil
    }
    
    /// `clears` the state in the view model
    func clearState() -> Void {
        self.mediaPickerType = .main
        self.shouldOpenMediaPicker = false
        self.image = nil
        self.audioThumbnailImage = nil
        self.videoURL = nil
        self.audioURL = nil
        self.snippetMediaType = -1
        self.snippetDetails = ""
        self.errorMsg = ""
        self.showError = false
        self.showValidationAlert = false
        self.validationMsg = ""
        self.audioRemote = ""
    }
    
    /// `reset` the media picker type
    func resetMediaPickerType() -> Void {
        DispatchQueue.main.async {
            if self.mediaPickerType == .image {
                self.videoURL = nil
                self.audioURL = nil
            } else if self.mediaPickerType == .video {
                self.image = nil
                self.audioURL = nil
            } else if self.mediaPickerType == .audio {
                self.image = nil
                self.videoURL = nil
            }
        }
    }
    
    /// `validations` for create a snippet
    func validations() -> Bool {
        if self.image == nil && self.videoURL == nil && self.audioURL == nil {
            self.validationMsg = "Please select atleast one media."
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
extension SnippetViewModel {
    /// `api call` for create snippet with `image`
    func createSnippetWithImage(completion: @escaping () -> Void) {
        if self.validations() {
            guard self.image != nil else { return }
            
            Indicator.show()
            
            AWSS3Manager.shared.uploadImage(image: image!, bucketname: .snippetImage, withSuccess: { (fileURL, imageSnippet) in
                guard let snippetImageRemote = imageSnippet.split(separator: "/").last else { return }
                self.snippetImageRemote = String(snippetImageRemote)
                
                AWSS3Manager.shared.uploadImage(image: self.image!, bucketname: .snippetThumb, withSuccess: { (fileURL, snippetThumbnail) in
                    guard let snippetThumbRemote = snippetThumbnail.split(separator: "/").last else { return }
                    self.snippetImageThumbRemote = String(snippetThumbRemote)
                    
                    let param = [
                        SnippetModelKeys.snippet_id.rawValue : nil,
                        SnippetModelKeys.snippet_type.rawValue : self.snippetMediaType,
                        SnippetModelKeys.snippet_file.rawValue : self.snippetImageRemote,
                        SnippetModelKeys.snippet_thumbnail_file.rawValue : self.snippetImageThumbRemote,
                        SnippetModelKeys.snippet_detail.rawValue : self.snippetDetails
                    ] as [String: Any?]
                    
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
                }, failure: { (error) in
                    Indicator.hide()
                }, connectionFail: {(error) in
                    Indicator.hide()
                })
            }, failure: { (error) in
                Indicator.hide()
            }, connectionFail: {(error) in
                Indicator.hide()
            })
        }
    }
    
    /// `api call` for create snippet with `video`
    func createSnippetWithVideo(completion: @escaping () -> Void) {
        if self.validations() {
            guard let videoUrl = self.videoURL else { return }
            
            Indicator.show()
            
            AWSS3Manager.shared.uploadVideo(video: videoUrl, bucketname: .snippetVideo, withSuccess: { (fileURL, remoteName) in
                guard let videoName = remoteName.split(separator: "/").last else { return }
                
                self.videoRemote = String(videoName)
                
                guard let image =  self.getThumbnailImage(forUrl: videoUrl) else { return }
                
                AWSS3Manager.shared.uploadImage(image: image, bucketname: .snippetThumb, withSuccess: {
                    (fileURL, thumbnail) in
                    guard let thumbnailName = thumbnail.split(separator: "/").last else { return }
                    self.videoThumbnailRemote = String(thumbnailName)
                    
                    let param = [
                        SnippetModelKeys.snippet_id.rawValue : nil,
                        SnippetModelKeys.snippet_type.rawValue : self.snippetMediaType,
                        SnippetModelKeys.snippet_file.rawValue : self.videoRemote,
                        SnippetModelKeys.snippet_thumbnail_file.rawValue : self.videoThumbnailRemote,
                        SnippetModelKeys.snippet_detail.rawValue : self.snippetDetails
                    ] as [String: Any?]
                    
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
                }, failure: { (error) in
                    Indicator.hide()
                }, connectionFail: {(error) in
                    Indicator.hide()
                })
            }, failure: { (error) in
                Indicator.hide()
            }, connectionFail: {(error) in
                Indicator.hide()
            })
        }
    }
    
    /// `api call` get snippet list data
    func getSnippetListData() -> Void{
        let params = ["page": self.currentpage] as [String: Any]
        
        GetSnippetListModel.getSnippetListData(params: params) { response, message -> Void in
            guard let model = response else { return }
            if self.currentpage == 1{
                self.getSnippetListModel = model
            } else {
                self.getSnippetListModel?.data?.append(contentsOf: model.data ?? [])
            }
        } failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        }
    }
    
    /// `api call` for pagination in snippet list
    func loadMoreSnippetListData(currentSnippet snippet: HomeSinppetData){
        guard let snippets = self.getSnippetListModel?.data, snippets.count >= (self.currentpage * 10) else { return }
        
        if (self.getSnippetListModel?.totalCount ?? 0) > snippets.count {
            if self.getSnippetListModel?.data?.last?.snippetID == snippet.snippetID {
                self.currentpage += 1
                self.getSnippetListData()
            }
        }
    }
    
    /// `api call` delete snippet
    func deleteSnippet(selectedSnippetID: Int) -> Void {
        let param = ["snippet_id" : "\(selectedSnippetID)"] as [String: Any]
        
        GetSnippetListModel.deleteSnippet(params: param, success: {
            DispatchQueue.main.async {
                self.getSnippetListData()
            }
            
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }

    /// `api call` for accept & reject request
    func snippetSendRequest(completion: @escaping () -> Void) {
        SnippetRequestModel.snippetSendRequest(success: {
            completion()
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }

    /// `api call` for getting the list of snippet request
    func getSnippetRequestList() -> Void {
        SnippetRequestModel.getSnippetRequestList(success: { response, message -> Void in
            guard let snippetReqList = response?.data else { return }
            
            self.snippetRequestList = snippetReqList
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }
    
    /// `api call` for accept reject snippet request
    func acceptRejectSnippetRequest(userId: Int, status: Int, completion: @escaping () -> Void) -> Void {
        let params = [
            "user_id": "\(userId)",
            "status": "\(status)"
        ] as [String: Any]

        SnippetRequestModel.acceptRejectSnippetRequest(params: params, success: {
            completion()
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }
}
