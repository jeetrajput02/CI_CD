//
//  UserProfilePostListModel.swift
//  WhosNext
//
//  Created by differenz240 on 24/11/22.
//

import Foundation

struct UserProfilePostListModel: Codable, Equatable, Hashable, Identifiable {
    var id = UUID()

    var success: Bool?
    var statusCode: Int?
    var message: String?
    var data: [UserProfilePostListData]?
    
    enum CodingKeys: String, CodingKey {
        case success
        case statusCode = "status_code"
        case message, data
    }
}

struct UserProfilePostListData: Codable, Equatable, Hashable, Identifiable {
    var id = UUID()

    var postID, userID, postType, postSubType: Int?
    var postURL, postThumbnail, postCaption: String?
    var postHeight, postWidth: Double?
    var taggedSelectedPeople: String?
    var postVisibility, postViewCount: Int?
    var username, firstName, lastName, fullName: String?
    var introductionVideoThumb, introductionVideo: String?
    var lastModificationTime, timeDisplayStr: String?
    var isVerified: Bool?
    var postLikeCount, postCommentCount, isOwnLike, isOwnView, isOwnPost: Int?
    var taggedSelectedPeopleArr: [AllUserListData]?
    var postComments: [PostComment]?
    var postGroup: [PostGroup]?
    var isVideoPlaying: Bool? = false
    var isNotificationFired: Bool? = false
    var callCountApiCall: Bool? = false
    
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
        case taggedSelectedPeopleArr = "tagged_selected_people_arr"
        case postComments = "post_comments"
        case postGroup = "post_group"
        case isVideoPlaying = "is_video_playing"
        case isNotificationFired = "is_notification_fired"
        case callCountApiCall = "call_count_api_call"
    }
}

// MARK: - API Calls
extension UserProfilePostListModel {
    /// `api call` for post list of user
    static func getPostListForUsers(params: [String: Any], success: @escaping (UserProfilePostListModel?, String) -> Void, failure: @escaping (String) -> Void) -> Void {
        Indicator.show()
        
        APIManager.makeRequest(with: Constant.ServerAPI.kUserProfilePostList, method: .post, parameter: params, success: { response -> Void in
            guard let json = response as? [String: Any] else { return }
            guard let data = try? JSONSerialization.data(withJSONObject: json) else { return }
            
            do {
                var userProfilePostListModel = try JSONDecoder().decode(UserProfilePostListModel.self, from: data)
                
                if (userProfilePostListModel.data?.count ?? 0) > 0 {
                    for index in 0 ..< userProfilePostListModel.data!.count {
                        var post = userProfilePostListModel.data![index]
                        
                        guard let post_url = post.postURL, let post_thumb = post.postThumbnail, let intro_video = post.introductionVideo, let intro_video_thumb = post.introductionVideoThumb else { return }
                        
                        let post_url_path = AWSS3Manager.shared.getMediaUrl(name: post_url, bucketName: post.postType == 1 ? .postImage : .postVideo)
                        let post_thumb_path = AWSS3Manager.shared.getMediaUrl(name: post_thumb, bucketName: post.postType == 1 ? .postImage : .postVideoThumb)
                        let intro_video_path = AWSS3Manager.shared.getMediaUrl(name: intro_video, bucketName: .introVideo)
                        let intro_video_thumb_path = AWSS3Manager.shared.getMediaUrl(name: intro_video_thumb, bucketName: .introThumbnail)
                        
                        AWSS3Manager.shared.getSignedUrl(key: post_url_path, withSuccess: { postUrl in
                            post.postURL = postUrl
                            
                            AWSS3Manager.shared.getSignedUrl(key: post_thumb_path, withSuccess: { postThumb in
                                post.postThumbnail = postThumb
                                
                                AWSS3Manager.shared.getSignedUrl(key: intro_video_path, withSuccess: { introVideo in
                                    post.introductionVideo = introVideo
                                    
                                    AWSS3Manager.shared.getSignedUrl(key: intro_video_thumb_path, withSuccess: { introVideoThumb in
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
                                            
                                            userProfilePostListModel.data![index] = post
                                        } else {
                                            userProfilePostListModel.data![index] = post
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
                                            
                                            userProfilePostListModel.data![index] = post
                                        } else {
                                            userProfilePostListModel.data![index] = post
                                        }
                                    })
                                })
                            })
                        })
                    }
                }
                
                success(userProfilePostListModel, userProfilePostListModel.message ?? "")
                Indicator.hide()
            } catch let error {
                print(error.localizedDescription)
            }
        }, failure: { error, errorCode, isAuth -> Void  in
            Indicator.hide()
            failure(error)
        }, connectionFailed: { error -> Void in
            Indicator.hide()
            
            failure(error)
        })
    }
}

