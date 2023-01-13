//
//  NotificationViewModel.swift
//  WhosNext
//
//  Created by differenz195 on 13/10/22.
//

import SwiftUI

/// `notification type`
enum NotificationType: Int {
    case none = 0
    case simplePostCreated = 1
    case groupVideoPostCreated = 2
    case taggedInPost = 3
    case taggedInGroupVideo = 4
    case groupVideoResponseUploadRequest = 5
    case commentOnPost = 6
    case likePost = 7
    case sendFollowingRequest = 8
    case acceptFollowingRequest = 9
    case directFollow = 10
    case chat = 11
}

enum ShowField: Int {
    case button = 1
    case pending = 2
    case uploaded = 3
    case rejected = 4
}

class NotificationViewModel: ObservableObject {
    @Published var notificationModel: NotificationModel? = nil
    @Published var notificationList: [NotificationData] = []
    
    @Published var selectedNotification: NotificationData? = nil
    @Published var selectedGroupVideo: GroupVideoUserArr? = nil

    @Published var isUploading: Bool = false
    @Published var progress: Float = 0.0

    @Published var moveToPictureDetails: Bool = false
    @Published var moveToUpdateGroupVideoView: Bool = false
    
    @Published var moveToProfile: Bool = false
    @Published var navigationLink: String? = nil
    @Published var moveToNotification: Bool = false
    
    @Published var showValidationAlert: Bool = false
    @Published var validationMsg: String = ""
    
    @Published var errorMsg: String = ""
    @Published var showError: Bool = false
    
    func onBtnNotification_Click() {
        self.moveToNotification = true
    }
}

// MARK: - API Calls
extension NotificationViewModel {
    
    /// `api call` for notification list
    func getNotificationList() -> Void {
        NotificationModel.getNotificationList(success: { response, message -> Void in
            guard let model = response else { return }
            self.notificationModel = model
            
            guard let notificationList = model.data else { return }
            self.notificationList = notificationList
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(message: error)
        })
    }
    
    /// `api call` for Accept & Reject Request
    func acceptRejectRequestApi(userID: String, followType: String, completion: @escaping () -> Void) -> Void {
        let param = ["user_id": userID,
                     "follow_status" : followType] as [String: Any]
        
        NotificationModel.acceptRejectRequest(params: param, success: {
            completion()
            Indicator.hide()
        }, failure: { error -> Void in
            
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }
    
    /// `validations` for create GroupVideo
    func validations(image: UIImage? , videoURL : URL?,description: String) -> Bool {
        if image == nil && (videoURL == nil || videoURL == URL(string: ""))  && description == ""  {
            self.validationMsg = "Please fill all    Details."
            self.showValidationAlert = true
            return false
        }
        else if image == nil && (videoURL == nil || videoURL == URL(string: ""))   {
            self.validationMsg = "Please select Video."
            self.showValidationAlert = true
            
            return false
        } else if description.isEmpty {
            self.validationMsg = "Please enter some details about Video."
            self.showValidationAlert = true
            
            return false
        } else {
            self.validationMsg = ""
            self.showValidationAlert = false
            
            return true
        }
    }
    
    
    /// `api call` for Reject Group Video Request
    func rejectGroupVideoRequestApi(postID: String, completion: @escaping () -> Void) -> Void {
        let param = ["post_id": postID] as [String: Any]
        
        NotificationModel.rejectGroupVideo(params: param) {
            completion()
            Indicator.hide()
        } failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        }
    }
    
    /// `api call` for Reject Group Video Request
    func updateGroupUserAPI(postID: String, userID:String, invitedUserID: String, userGroupID: String, completion: @escaping () -> Void) -> Void {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
            withAnimation {
                self.progress = 50.0
            }
        })

        let param = [
            "invited_user_id": invitedUserID,
            "user_group_id": userGroupID,
            "post_id": postID,
            "user_id": userID
        ] as [String: Any]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
            withAnimation {
                self.progress = 70.0
            }
        })

        NotificationModel.updatGroupVideoUser(params: param) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
                withAnimation {
                    self.progress = 100.0
                }
            })
            
            completion()
            Indicator.hide()
        } failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        }
    }
    
    /// `api call` for Update Group Video Request
    func updateGroupVideoRequestApi(postID: String, video_url: URL?, completion: @escaping () -> Void) -> Void {
        guard let videoUrl = video_url else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
            withAnimation {
                self.progress = 10.0
            }
        })

        AWSS3Manager.shared.uploadVideo(video: videoUrl, bucketname: .postVideo, withSuccess: { (fileURL, remoteName) in
            guard let videoName = remoteName.split(separator: "/").last else { return }
            
            let videoRemote = String(videoName)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
                withAnimation {
                    self.progress = 40.0
                }
            })

            guard let image = Utilities.getThumbnailImage(forUrl: videoUrl) else { return }
            
            AWSS3Manager.shared.uploadImage(image: image, bucketname: .postVideoThumb, withSuccess: {
                (fileURL, thumbnail) in
                guard let thumbnailName = thumbnail.split(separator: "/").last else { return }
                let videoThumbnailRemote = String(thumbnailName)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
                    withAnimation {
                        self.progress = 70.0
                    }
                })

                let param = [
                    "post_id": postID,
                    "invited_user_video_url": videoRemote,
                    "invited_user_video_thumbnail_url": videoThumbnailRemote
                ] as [String: Any]
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
                    withAnimation {
                        self.progress = 80.0
                    }
                })

                NotificationModel.updateGroupVideo(params: param, success: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
                        withAnimation {
                            self.progress = 100.0
                        }
                    })

                    completion()
                    Indicator.hide()
                }, failure: { error -> Void in
                    self.errorMsg = error
                    self.showError = true
                    
                    Alert.show(title: "", message: error)
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

