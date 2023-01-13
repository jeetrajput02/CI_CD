//
//  BCLDetailsModel.swift
//  WhosNext
//
//  Created by differenz07 on 15/12/22.
//

import Foundation

struct BCLDetailsModel: Codable, Hashable, Equatable {
    var success: Bool?
    var statusCode: Int?
    var message: String?
    var data: LegaciesDetailData?
    
    enum CodingKeys: String, CodingKey {
        case success
        case statusCode = "status_code"
        case message, data
    }
}

struct LegaciesDetailData: Codable, Hashable, Equatable{
    var postID, userID, postCategory, postType: Int?
    var postSubType: Int?
    var postURL, postThumbnail: String?
    var postHeight, postWidth: Double?
    var postCaption, taggedSelectedPeople: String?
    var postVisibility, postViewCount: Int?
    var legaciesName, legaciesDescription: String?
    var carnation: Int?
    var dateOfBirth, dateOfPassing, username, firstName: String?
    var lastName, fullName, introductionVideoThumb, introductionVideo: String?
    var lastModificationTime, timeDisplayStr: String?
    var isVerified: Bool?
    var postLikeCount, postCommentCount, isOwnLike, isOwnView: Int?
    var isOwnPost: Int?
    var postComments: [PostComment]?
    var isNotificationFired: Bool? = false
    var callCountApiCall: Bool? = false
    
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
        case legaciesName = "legacies_name"
        case legaciesDescription = "legacies_description"
        case carnation
        case dateOfBirth = "date_of_birth"
        case dateOfPassing = "date_of_passing"
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
        case isNotificationFired = "is_notification_fired"
        case callCountApiCall = "call_count_api_call"
    }
    
}

// MARK: - API Calls
extension BCLDetailsModel {
    /// `api call` for legacy detail
    static func BCLDetails(params: [String: Any], success: @escaping (BCLDetailsModel?, String) -> Void, failure: @escaping (String) -> Void) -> Void {
        Indicator.show()
        
        APIManager.makeRequest(with: Constant.ServerAPI.kLegaciesDetail, method: .post, parameter: params, success: { response -> Void in
            guard let json = response as? [String: Any] else { return }
            guard let data = try? JSONSerialization.data(withJSONObject: json) else { return }
            
            do {
                var BCLDetailsModel = try JSONDecoder().decode(BCLDetailsModel.self, from: data)
                
                if var post = BCLDetailsModel.data {
                    guard let post_url = post.postURL, let post_thumb = post.postThumbnail, let intro_video = post.introductionVideo, let intro_video_thumb = post.introductionVideoThumb else { return }
                    
                    let post_url_path = AWSS3Manager.shared.getMediaUrl(name: post_url, bucketName: .bclImage)
                    let post_thumb_path = AWSS3Manager.shared.getMediaUrl(name: post_thumb, bucketName: .bclImage)
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
                                        
                                        BCLDetailsModel.data = post
                                        
                                        success(BCLDetailsModel, BCLDetailsModel.message ?? "")
                                    } else {
                                        BCLDetailsModel.data = post
                                        
                                        success(BCLDetailsModel, BCLDetailsModel.message ?? "")
                                    }
                                })
                            })
                        })
                    })
                } else {
                    success(BCLDetailsModel, BCLDetailsModel.message ?? "")
                }
            } catch let error {
                print(error.localizedDescription)
                
                failure(error.localizedDescription)
            }
            
            Indicator.hide()
        }, failure: { error, errorCode, isAuth -> Void in
            Indicator.hide()
            
            failure(error)
        }, connectionFailed: { error -> Void in
            Indicator.hide()
            
            failure(error)
        })
    }
    
}


