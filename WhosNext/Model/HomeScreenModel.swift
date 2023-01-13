//
//  HomeScreenModel.swift
//  WhosNext
//
//  Created by differenz240 on 24/11/22.
//

import Foundation

struct HomeScreenModel: Codable, Hashable, Equatable, Identifiable {
    var id = UUID()
    
    var success: Bool?
    var statusCode: Int?
    var message: String?
    var totalCount: Int?
    var data: HomeScreenData?
    
    enum CodingKeys: String, CodingKey {
        case success
        case statusCode = "status_code"
        case message
        case totalCount = "total_count"
        case data
    }
}

struct HomeScreenData: Codable, Hashable, Equatable {
    var nextpage: Int?
    var post: [HomePostData]?
    var sinppet: [HomeSinppetData]?
}

struct HomePostData: Codable, Hashable, Equatable, Identifiable {
    var id = UUID()
    
    var postID, userID, postType, postSubType: Int?
    var postURL, postThumbnail, postCaption: String?
    var taggedSelectedPeople: String?
    var postVisibility, postViewCount: Int?
    var postHeight, postWidth: Double?
    var username: String?
    var firstName: String?
    var lastName: String?
    var fullName: String?
    var introductionVideoThumb: String?
    var introductionVideo: String?
    var lastModificationTime: String?
    var timeDisplayStr: String?
    var isVerified: Bool?
    var postLikeCount, postCommentCount, isOwnLike, isOwnView, isOwnPost: Int?
    var taggedSelectedPeopleArr: [AllUserListData]?
    var postComments: [PostComment]?
    var postGroup: [PostGroup]?
    var isVideoPlaying: Bool? = false
    var isNotificationFired: Bool? = false
    var callCountApiCall: Bool? = false
    var badgeCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case postID = "post_id"
        case userID = "user_id"
        case postType = "post_type"
        case postSubType = "post_sub_type"
        case postURL = "post_url"
        case postThumbnail = "post_thumbnail"
        case postCaption = "post_caption"
        case postWidth = "post_width"
        case postHeight = "post_height"
        case taggedSelectedPeople = "tagged_selected_people"
        case postVisibility = "post_visibility"
        case postViewCount = "post_view_count"
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case fullName = "full_name"
        case introductionVideoThumb = "introduction_video_thumb"
        case introductionVideo = "introduction_video"
        case lastModificationTime = "last_modification_time"
        case timeDisplayStr = "time_display_str"
        case isVerified = "is_verified"
        case postLikeCount = "post_like_count"
        case postCommentCount = "post_comment_count"
        case isOwnLike = "is_own_like"
        case isOwnView = "is_own_view"
        case isOwnPost = "is_own_post"
        case postComments = "post_comments"
        case taggedSelectedPeopleArr = "tagged_selected_people_arr"
        case isVideoPlaying = "is_video_playing"
        case isNotificationFired = "is_notification_fired"
        case callCountApiCall = "call_count_api_call"
        case postGroup = "post_group"
        case badgeCount = "badge"
    }
}

struct HomeSinppetData: Codable, Hashable, Equatable, Identifiable {
    var id = UUID()
    
    var snippetID, userID, snippetType: Int?
    var snippetFile, snippetThumb, snippetDetail: String?
    var snippetViewCount: Int?
    var firstName, lastName, username, fullName: String?
    var introductionVideoThumb, introductionVideo, lastModificationTime, timeDisplayStr: String?
    
    enum CodingKeys: String, CodingKey {
        case snippetID = "snippet_id"
        case userID = "user_id"
        case snippetType = "snippet_type"
        case snippetFile = "snippet_file"
        case snippetThumb = "snippet_thumb"
        case snippetDetail = "snippet_detail"
        case snippetViewCount = "snippet_view_count"
        case firstName = "first_name"
        case lastName = "last_name"
        case username
        case fullName = "full_name"
        case introductionVideoThumb = "introduction_video_thumb"
        case introductionVideo = "introduction_video"
        case lastModificationTime = "last_modification_time"
        case timeDisplayStr = "time_display_str"
    }
}

struct PostComment: Codable, Hashable, Equatable, Identifiable {
    var id = UUID()
    
    var commentID, userID, postID: Int?
    var postComment, firstName, lastName, username: String?
    var fullName, introductionVideoThumb, introductionVideo, lastModificationTime: String?
    var timeDisplayStr: String?
    
    enum CodingKeys: String, CodingKey {
        case commentID = "comment_id"
        case userID = "user_id"
        case postID = "post_id"
        case postComment = "post_comment"
        case firstName = "first_name"
        case lastName = "last_name"
        case username
        case fullName = "full_name"
        case introductionVideoThumb = "introduction_video_thumb"
        case introductionVideo = "introduction_video"
        case lastModificationTime = "last_modification_time"
        case timeDisplayStr = "time_display_str"
    }
}

struct PostGroup: Codable, Equatable, Hashable, Identifiable {
    var id = UUID()
    
    var userGroupID, groupID, postID, postUserID: Int?
    var invitedUserID: Int?
    var invitedUserVideoURL, username, invitedUserVideoThumbnailURL: String?
    
    enum CodingKeys: String, CodingKey {
        case userGroupID = "user_group_id"
        case groupID = "group_id"
        case postID = "post_id"
        case postUserID = "post_user_id"
        case invitedUserID = "invited_user_id"
        case invitedUserVideoURL = "invited_user_video_url"
        case invitedUserVideoThumbnailURL = "invited_user_video_thumbnail_url"
        case username
    }
}

// MARK: - API Calls
extension HomeScreenModel {
    /// `api call` for home screen data
    static func getHomeScreenData(params: [String: Any], showLoader: Bool, success: @escaping (HomeScreenModel?, String) -> Void, failure: @escaping (String) -> Void) -> Void {
        if showLoader {
            Indicator.show()
        }
        
        APIManager.makeRequest(with: Constant.ServerAPI.kHomeScreen, method: .post, parameter: params, success: { response -> Void in
            guard let json = response as? [String: Any] else { return }
            guard let data = try? JSONSerialization.data(withJSONObject: json) else { return }
            
            do {
                var homeScreenModel = try JSONDecoder().decode(HomeScreenModel.self, from: data)
                
                if homeScreenModel.data != nil {
                    if (homeScreenModel.data!.post?.count ?? 0) > 0 {
                        for index in 0 ..< homeScreenModel.data!.post!.count {
                            var post = homeScreenModel.data!.post![index]

                            guard let post_url = post.postURL, let post_thumb = post.postThumbnail, let post_intro_video = post.introductionVideo, let post_intro_video_thumb = post.introductionVideoThumb else { return }
                            
                            let post_url_path = AWSS3Manager.shared.getMediaUrl(name: post_url, bucketName: post.postType == 1 ? .postImage : .postVideo)
                            let post_thumb_path = AWSS3Manager.shared.getMediaUrl(name: post_thumb, bucketName: post.postType == 1 ? .postImage : .postVideoThumb)
                            let post_intro_video_path = AWSS3Manager.shared.getMediaUrl(name: post_intro_video, bucketName: .introVideo)
                            let post_intro_video_thumb_path = AWSS3Manager.shared.getMediaUrl(name: post_intro_video_thumb, bucketName: .introThumbnail)
                            
                            AWSS3Manager.shared.getSignedUrl(key: post_url_path, withSuccess: { postUrl in
                                post.postURL = postUrl
                                
                                AWSS3Manager.shared.getSignedUrl(key: post_thumb_path, withSuccess: { postThumb in
                                    post.postThumbnail = postThumb
                                    
                                    AWSS3Manager.shared.getSignedUrl(key: post_intro_video_path, withSuccess: { introVideo in
                                        post.introductionVideo = introVideo
                                        
                                        AWSS3Manager.shared.getSignedUrl(key: post_intro_video_thumb_path, withSuccess: { introVideoThumb in
                                            post.introductionVideoThumb = introVideoThumb
                                            
                                            if post.postGroup!.count > 0 {
                                                for index in 0 ..< post.postGroup!.count {
                                                    var groupPost = post.postGroup![index]
                                                    
                                                    if let group_video = groupPost.invitedUserVideoURL, let group_video_thumb = groupPost.invitedUserVideoThumbnailURL {
                                                        var group_video = AWSS3Manager.shared.getMediaUrl(name: group_video, bucketName: .postVideo)
                                                        var group_video_thumb = AWSS3Manager.shared.getMediaUrl(name: group_video_thumb, bucketName: .postVideoThumb)
                                                        
                                                        group_video = "https://d234fq55kjo26g.cloudfront.net/\(group_video)"
                                                        group_video_thumb = "https://d234fq55kjo26g.cloudfront.net/\(group_video_thumb)"
                                                        
                                                        groupPost.invitedUserVideoURL = group_video
                                                        groupPost.invitedUserVideoThumbnailURL = group_video_thumb
                                                        
                                                        post.postGroup![index] = groupPost
                                                    }
                                                }
                                                
                                                homeScreenModel.data!.post![index] = post
                                            } else {
                                                homeScreenModel.data!.post![index] = post
                                            }
                                            
                                            
                                            if post.postComments!.count > 0 {
                                                for index in 0 ..< post.postComments!.count {
                                                    var comment = post.postComments![index]
                                                    
                                                    if let comment_intro_video = comment.introductionVideo, let comment_intro_video_thumb = comment.introductionVideoThumb {
                                                        let comment_intro_video_path = AWSS3Manager.shared.getMediaUrl(name: comment_intro_video, bucketName: .introVideo)
                                                        let comment_intro_video_thumb_path = AWSS3Manager.shared.getMediaUrl(name: comment_intro_video_thumb, bucketName: .introThumbnail)
                                                        
                                                        AWSS3Manager.shared.getSignedUrl(key: comment_intro_video_path, withSuccess: { commentIntroVideo in
                                                            comment.introductionVideo = commentIntroVideo
                                                            
                                                            AWSS3Manager.shared.getSignedUrl(key: comment_intro_video_thumb_path, withSuccess: { commentIntroVideoThumb in
                                                                comment.introductionVideoThumb = commentIntroVideoThumb
                                                                
                                                                post.postComments![index] = comment
                                                            })
                                                        })
                                                    }
                                                }
                                                
                                                homeScreenModel.data!.post![index] = post
                                            } else {
                                                homeScreenModel.data!.post![index] = post
                                            }
                                        })
                                    })
                                })
                            })
                        }
                    }
                    
                    if (homeScreenModel.data!.sinppet?.count ?? 0) > 0 {
                        for index in 0 ..< homeScreenModel.data!.sinppet!.count {
                            var snippet = homeScreenModel.data!.sinppet![index]
                            var snippet_file_bucket: AWSBucket
                            var snippet_file_path = ""
                            
                            guard let snippet_file = snippet.snippetFile, let snippet_thumb = snippet.snippetThumb, let snippet_intro_video = snippet.introductionVideo, let snippet_intro_video_thumb = snippet.introductionVideoThumb else { return }
                            
                            if snippet.snippetType == 1 {
                                snippet_file_bucket = .snippetImage
                                snippet_file_path =  AWSS3Manager.shared.getMediaUrl(name: snippet_file, bucketName: snippet_file_bucket)
                            } else if snippet.snippetType == 2 {
                                snippet_file_bucket = .snippetVideo
                                snippet_file_path =  AWSS3Manager.shared.getMediaUrl(name: snippet_file, bucketName: snippet_file_bucket)
                            } else if snippet.snippetType == 3 {
                                snippet_file_bucket = .snippetAudio
                                snippet_file_path =  AWSS3Manager.shared.getMediaUrl(name: snippet_file, bucketName: snippet_file_bucket)
                            }
                            
                            let snippet_thumb_path = AWSS3Manager.shared.getMediaUrl(name: snippet_thumb, bucketName: .snippetThumb)
                            let snippet_intro_video_path = AWSS3Manager.shared.getMediaUrl(name: snippet_intro_video, bucketName: .introVideo)
                            let snippet_intro_video_thumb_path = AWSS3Manager.shared.getMediaUrl(name: snippet_intro_video_thumb, bucketName: .introThumbnail)
                            
                            AWSS3Manager.shared.getSignedUrl(key: snippet_file_path, withSuccess: { snippetFile in
                                snippet.snippetFile = snippetFile
                                
                                AWSS3Manager.shared.getSignedUrl(key: snippet_thumb_path, withSuccess: { snippetThumb in
                                    snippet.snippetThumb = snippetThumb
                                    
                                    AWSS3Manager.shared.getSignedUrl(key: snippet_intro_video_path, withSuccess: { introVideo in
                                        snippet.introductionVideo = introVideo
                                        
                                        AWSS3Manager.shared.getSignedUrl(key: snippet_intro_video_thumb_path, withSuccess: { introVideoThumb in
                                            snippet.introductionVideoThumb = introVideoThumb
                                            
                                            homeScreenModel.data!.sinppet![index] = snippet
                                        })
                                    })
                                })
                            })
                        }
                    }
                }
                
                success(homeScreenModel, homeScreenModel.message ?? "")
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
    
    /// `api call` for Notification Badge Count
    static func notificationBadgeCount(success: @escaping (NotificationBadgeModel?, String) -> Void, failure: @escaping (String) -> Void) -> Void {
        
        APIManager.makeRequest(with: Constant.ServerAPI.kNotificationBadgeCount, method: .get, parameter: nil, success: { response -> Void in
            
            guard let json = response as? [String: Any] else { return }
            guard let data = try? JSONSerialization.data(withJSONObject: json) else { return }
            
            do {
                let notificationBadgeModel = try JSONDecoder().decode(NotificationBadgeModel.self, from: data)
                success(notificationBadgeModel, notificationBadgeModel.message ?? "")
            } catch let error {
                print(error.localizedDescription)
            }
        
            
        }, failure: { error, errorCode, isAuth -> Void in
            Indicator.hide()
            
            failure(error)
        }, connectionFailed: { error -> Void in
            Indicator.hide()
            
            failure(error)
        })
    }
}
