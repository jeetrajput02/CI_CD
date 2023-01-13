//
//  NotificationModel.swift
//  WhosNext
//
//  Created by differenz240 on 03/01/23.
//

import Foundation

struct NotificationModel: Codable, Hashable, Equatable, Identifiable {
    var id = UUID()
    
    var success: Bool?
    var statusCode: Int?
    var message: String?
    var data: [NotificationData]?
    
    enum CodingKeys: String, CodingKey {
        case success
        case statusCode = "status_code"
        case message, data
    }
}

struct NotificationData: Codable, Hashable, Equatable, Identifiable {
    
    var id = UUID()
    
    var notificationID, senderID, receiverID: Int?
    var username: String?
    var notificationType: Int?
    var title, body, response: String?
    var deviceType, isRead: Int?
    var notificationField, notificationValue: String?
    var firstName, lastName, fullName: String?
    var introductionVideoThumb, introductionVideo,timeDisplayStr: String?
    var groupVideo, groupVideoThumb: String?
    var groupVideoUserArr: [GroupVideoUserArr]?
    var post: NotificationPost?
    
    
    enum CodingKeys: String, CodingKey {
        case notificationID = "notification_id"
        case senderID = "sender_id"
        case receiverID = "receiver_id"
        case username
        case notificationType = "notification_type"
        case title, body, response
        case deviceType = "device_type"
        case isRead = "is_read"
        case notificationField = "notification_field"
        case notificationValue = "notification_value"
        case firstName = "first_name"
        case lastName = "last_name"
        case fullName = "full_name"
        case introductionVideoThumb = "introduction_video_thumb"
        case introductionVideo = "introduction_video"
        case groupVideo = "group_video"
        case groupVideoThumb = "group_video_thumb"
        case groupVideoUserArr = "group_video_user_arr"
        case timeDisplayStr = "time_display_str"
        case post = "post_arr"
    }
}

struct GroupVideoUserArr: Codable, Hashable, Equatable, Identifiable {
    
    var id = UUID()
    var userGroupID, groupID, postID, postUserID: Int?
    var invitedUserID: Int?
    var invitedUserVideoURL, invitedUserVideoThumbnailURL: String?
    var invitationStatus: Int?
    var firstName, lastName, username, fullName: String?
    var introductionVideoThumb, introductionVideo: String?
    var groupVideoUploadStatus: Int?
    var showField: Int?
    var replaceUserPermission: Int?

    enum CodingKeys: String, CodingKey {
        case userGroupID = "user_group_id"
        case groupID = "group_id"
        case postID = "post_id"
        case postUserID = "post_user_id"
        case invitedUserID = "invited_user_id"
        case invitedUserVideoURL = "invited_user_video_url"
        case invitedUserVideoThumbnailURL = "invited_user_video_thumbnail_url"
        case invitationStatus = "invitation_status"
        case firstName = "first_name"
        case lastName = "last_name"
        case username
        case fullName = "full_name"
        case introductionVideoThumb = "introduction_video_thumb"
        case introductionVideo = "introduction_video"
        case groupVideoUploadStatus = "group_video_upload_status"
        case showField = "show_field"
        case replaceUserPermission = "replace_user_permission"
    }
}

struct NotificationPost: Codable, Hashable, Equatable, Identifiable {
    var id = UUID()
    
    var postID, userID, postCategory, postType: Int?
    var postSubType: Int?
    var postURL, postThumbnail: String?
    var postHeight, postWidth: Double?
    var postCaption, taggedSelectedPeople: String?
    var postVisibility, postViewCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case postID = "post_id"
        case userID = "user_id"
        case postCategory = "post_category"
        case postType = "post_type"
        case postSubType = "post_sub_type"
        case postURL = "post_url"
        case postThumbnail = "post_thumbnail"
        case postHeight = "post_height"
        case postWidth = "post_width"
        case postCaption = "post_caption"
        case taggedSelectedPeople = "tagged_selected_people"
        case postVisibility = "post_visibility"
        case postViewCount = "post_view_count"
    }
}


struct NotificationBadgeModel: Codable {
    var success: Bool?
    var statusCode: Int?
    var message: String?
    var data: DataClass?
    
    enum CodingKeys: String, CodingKey {
        case success
        case statusCode = "status_code"
        case message, data
    }
}

struct AcceptRejectRequestModel: Codable {
    var success: Bool?
    var statusCode: Int?
    var message: String?
    var data: [AcceptRejectRequestData]?
    
    enum CodingKeys: String, CodingKey {
        case success
        case statusCode = "status_code"
        case message, data
    }
}

struct RejectRequestModel: Codable {
    var success: Bool?
    var statusCode: Int?
    var message: String?
    var data: RejectResponseData?
    
    enum CodingKeys: String, CodingKey {
        case success
        case statusCode = "status_code"
        case message
    }
}
struct RejectResponseData: Codable {
}



// MARK: - AcceptRejectRequestData
struct AcceptRejectRequestData: Codable {
    var followID, followingID: Int?
    var fullname, username, firstName: String?
    
    enum CodingKeys: String, CodingKey {
        case followID = "follow_id"
        case followingID = "following_id"
        case fullname, username
        case firstName = "first_name"
    }
}

// MARK: - DataClass
struct DataClass: Codable {
    var badge: Int?
}

// MARK: - API Calls
extension NotificationModel {
    /// `api call` for notification list
    static func getNotificationList(success: @escaping (NotificationModel?, String) -> Void, failure: @escaping (String) -> Void) -> Void {
        Indicator.show()
        
        APIManager.makeRequest(with: Constant.ServerAPI.kNotificationList, method: .get, parameter: nil, success: { response -> Void in
            guard let json = response as? [String: Any], let data = try? JSONSerialization.data(withJSONObject: json) else { return }
            
            do {
                var notificationModel = try JSONDecoder().decode(NotificationModel.self, from: data)
                
                if notificationModel.data != nil {
                    if (notificationModel.data?.count ?? 0) > 0 {
                        for index in 0 ..< (notificationModel.data?.count ?? 0) {
                            var notification = notificationModel.data![index]
                            
                            guard let notification_intro_video = notification.introductionVideo, let notification_intro_video_thumb = notification.introductionVideoThumb,
                                  let notification_group_video = notification.groupVideo, let notification_group_video_thumb = notification.groupVideoThumb else { return }
                            
                            let notification_intro_video_path = AWSS3Manager.shared.getMediaUrl(name: notification_intro_video, bucketName: .introVideo)
                            let notification_intro_video_thumb_path = AWSS3Manager.shared.getMediaUrl(name: notification_intro_video_thumb, bucketName: .introThumbnail)
                            let notification_group_video_path = AWSS3Manager.shared.getMediaUrl(name: notification_group_video, bucketName: .postVideo)
                            let notification_group_video_thumb_path = AWSS3Manager.shared.getMediaUrl(name: notification_group_video_thumb, bucketName: .postVideoThumb)
                            
                            AWSS3Manager.shared.getSignedUrl(key: notification_intro_video_path, withSuccess: { introVideoUrl in
                                notification.introductionVideo = introVideoUrl
                                
                                AWSS3Manager.shared.getSignedUrl(key: notification_intro_video_thumb_path, withSuccess: { introVideoThumbUrl in
                                    notification.introductionVideoThumb = introVideoThumbUrl
                                    
                                    AWSS3Manager.shared.getSignedUrl(key: notification_group_video_path, withSuccess: { groupVideoUrl in
                                        notification.groupVideo = groupVideoUrl
                                        
                                        AWSS3Manager.shared.getSignedUrl(key: notification_group_video_thumb_path, withSuccess: { groupVideoThumbUrl in
                                            notification.groupVideoThumb = groupVideoThumbUrl
                                            
                                            if notification.groupVideoUserArr != nil {
                                                if (notification.groupVideoUserArr?.count ?? 0) > 0 {
                                                    for groupIndex in 0 ..< (notification.groupVideoUserArr?.count ?? 0) {
                                                        var groupNotification = notification.groupVideoUserArr![groupIndex]
                                                        
                                                        guard let invited_user_video_url = groupNotification.invitedUserVideoURL,
                                                              let invited_user_video_thumbnail_url = groupNotification.invitedUserVideoThumbnailURL,
                                                              let group_notification_intro_video = groupNotification.introductionVideo,
                                                              let group_notification_intro_video_thumb = groupNotification.introductionVideoThumb else { return }
                                                        
                                                        let invited_user_video_url_path = AWSS3Manager.shared.getMediaUrl(name: invited_user_video_url, bucketName: .postVideo)
                                                        let invited_user_video_thumbnail_url_path = AWSS3Manager.shared.getMediaUrl(name: invited_user_video_thumbnail_url, bucketName: .postVideoThumb)
                                                        let group_notification_intro_video_path = AWSS3Manager.shared.getMediaUrl(name: group_notification_intro_video, bucketName: .introVideo)
                                                        let group_notification_intro_video_thumb_path = AWSS3Manager.shared.getMediaUrl(name: group_notification_intro_video_thumb, bucketName: .introThumbnail)
                                                        
                                                        AWSS3Manager.shared.getSignedUrl(key: invited_user_video_url_path, withSuccess: { invitedUserVideoUrl in
                                                            groupNotification.invitedUserVideoURL = invitedUserVideoUrl
                                                            
                                                            AWSS3Manager.shared.getSignedUrl(key: invited_user_video_thumbnail_url_path, withSuccess: { invitedUserVideoThumbnailUrl in
                                                                groupNotification.invitedUserVideoThumbnailURL = invitedUserVideoThumbnailUrl
                                                                
                                                                AWSS3Manager.shared.getSignedUrl(key: group_notification_intro_video_path, withSuccess: { introductionVideoUrl in
                                                                    groupNotification.introductionVideo = introductionVideoUrl
                                                                    
                                                                    AWSS3Manager.shared.getSignedUrl(key: group_notification_intro_video_thumb_path, withSuccess: { introductionVideoThumbUrl in
                                                                        groupNotification.introductionVideoThumb = introductionVideoThumbUrl
                                                                        
                                                                        notification.groupVideoUserArr![groupIndex] = groupNotification
                                                                    })
                                                                })
                                                            })
                                                        })
                                                    }
                                                }
                                            }
                                            
                                            if notification.post != nil {
                                                guard var post = notification.post else { return }
                                                
                                                guard let post_url = post.postURL, let post_thumb = post.postThumbnail else { return }
                                                
                                                let post_url_path = AWSS3Manager.shared.getMediaUrl(name: post_url, bucketName: post.postType == 1 ? .postImage : .postVideo)
                                                let post_thumb_path = AWSS3Manager.shared.getMediaUrl(name: post_thumb, bucketName: post.postType == 1 ? .postImage : .postVideoThumb)
                                                
                                                AWSS3Manager.shared.getSignedUrl(key: post_url_path, withSuccess: { postUrl in
                                                    post.postURL = postUrl
                                                    
                                                    AWSS3Manager.shared.getSignedUrl(key: post_thumb_path, withSuccess: { postThumb in
                                                        post.postThumbnail = postThumb
                                                        
                                                        notification.post = post
                                                    })
                                                })
                                            }
                                            
                                            notificationModel.data![index] = notification
                                        })
                                    })
                                })
                            })
                        }
                    }
                }
                
                success(notificationModel, notificationModel.message ?? "")
                Indicator.hide()
            } catch DecodingError.keyNotFound(let key, let context) {
                print("could not find key \(key) in JSON: \(context.debugDescription)")
                
                failure(context.debugDescription)
                Indicator.hide()
            } catch DecodingError.valueNotFound(let type, let context) {
                print("could not find type \(type) in JSON: \(context.debugDescription)")
                
                failure(context.debugDescription)
                Indicator.hide()
            } catch DecodingError.typeMismatch(let type, let context) {
                print("type mismatch for type \(type) in JSON: \(context.debugDescription)")
                
                failure(context.debugDescription)
                Indicator.hide()
            } catch DecodingError.dataCorrupted(let context) {
                print("data found to be corrupted in JSON: \(context.debugDescription)")
                
                failure(context.debugDescription)
                Indicator.hide()
            } catch let error {
                print("Error in read(from:ofType:) description= \(error.localizedDescription)")
                
                failure(error.localizedDescription)
                Indicator.hide()
            }
        }, failure: { error, errorCode, isAuth -> Void  in
            Indicator.hide()
            
            failure(error)
        }, connectionFailed: { error -> Void in
            Indicator.hide()
            
            failure(error)
        })
    }
    
    /// `api call` for accept & reject request
    static func acceptRejectRequest(params: [String: Any], success: @escaping () -> (), failure: @escaping (String) -> Void) {
        APIManager.makeRequest(with: Constant.ServerAPI.kAcceptRejectRequest, method: .post, parameter: params, success: { response -> Void in
            success()
        }, failure: { error, errorCode, isAuth -> Void in
            Indicator.hide()
            
            failure(error)
        }, connectionFailed: { error -> Void in
            Indicator.hide()
            
            failure(error)
        })
    }
    
    /// `api call` for reject group video
    static func rejectGroupVideo(params: [String : Any] , success: @escaping () -> () , failure: @escaping (String) -> Void) {
        APIManager.makeRequest(with: Constant.ServerAPI.kRejectGroupVideo, method: .post, parameter: params, success: { response -> Void in
            success()
        }, failure: { error , errorCode , isAuth -> Void in
            Indicator.hide()
        }, connectionFailed: { error -> Void in
            Indicator.hide()

            failure(error)
        })
    }
    
    /// `api call` for update group video user
    static func updatGroupVideoUser(params: [String: Any] , success: @escaping () -> () , failure: @escaping (String) -> Void) {
        APIManager.makeRequest(with: Constant.ServerAPI.kUpdateGroupVideoUser, method: .post, parameter: params, success: { response -> Void in
            success()
        }, failure: { error , errorCode , isAuth -> Void in
            Indicator.hide()
            
        }, connectionFailed: { error -> Void in
            Indicator.hide()
            
            failure(error)
        })
    }
    
    /// `api call` for update group video
    static func updateGroupVideo(params: [String: Any] , success: @escaping () -> () , failure: @escaping (String) -> Void) {
        APIManager.makeRequest(with: Constant.ServerAPI.kUpdateGroupVideo, method: .post, parameter: params, success: { response -> Void in
            success()
        }, failure: { error , errorCode , isAuth -> Void in
            Indicator.hide()
            
        }, connectionFailed: { error -> Void in
            Indicator.hide()
            
            failure(error)
        })
    }
}

