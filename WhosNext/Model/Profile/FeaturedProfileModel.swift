//
//  FeaturedProfileModel.swift
//  WhosNext
//
//  Created by differenz240 on 07/12/22.
//

import Foundation

// MARK: - Parameters for Featured Profile
enum FeaturedProfileParams: String {
    case page
}

struct FeaturedProfileModel: Codable, Equatable, Hashable, Identifiable {
    var id = UUID()
    
    var success: Bool?
    var statusCode: Int?
    var message: String?
    var totalCount: Int?
    var data: [FeaturedProfileData]?
    
    enum CodingKeys: String, CodingKey {
        case success
        case statusCode = "status_code"
        case message
        case totalCount = "total_count"
        case data
    }
}

struct FeaturedProfileData: Codable, Equatable, Hashable, Identifiable {
    var id = UUID()
    
    var postID, userID, postCategory, postType, postSubType: Int?
    var postURL, postThumbnail, postCaption: String?
    var postHeight, postWidth: Double?
    var legaciesDescription, legaciesName: String?
    var taggedSelectedPeople: String?
    var postVisibility, postViewCount, legaciesViewCount: Int?
    var isCarnationDuringUpload, birthdate, passdate: String?
    var username, firstName, lastName, fullName: String?
    var introductionVideoThumb, introductionVideo, lastModificationTime, timeDisplayStr: String?
    var isVerified: Bool?
    var postLikeCount, postCommentCount, isOwnLike, isOwnView, isOwnPost: Int?
    var postGroup: [PostGroup]?
    var postComments: [PostComment]?
    var taggedSelectedPeopleArr: [AllUserListData]?
    var isVideoPlaying: Bool? = false
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
        case postCaption = "post_caption"
        case postWidth = "post_width"
        case postHeight = "post_height"
        case legaciesDescription = "legacies_description"
        case legaciesName = "legacies_name"
        case taggedSelectedPeople = "tagged_selected_people"
        case postVisibility = "post_visibility"
        case postViewCount = "post_view_count"
        case legaciesViewCount = "legacies_view_count"
        case isCarnationDuringUpload = "is_carnation_during_upload"
        case birthdate, passdate, username
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
        case postGroup = "post_group"
        case taggedSelectedPeopleArr = "tagged_selected_people_arr"
        case isVideoPlaying = "is_video_playing"
        case isNotificationFired = "is_notification_fired"
        case callCountApiCall = "call_count_api_call"
    }
    
}

// MARK: - API Calls
extension FeaturedProfileModel {
    /// `api call` for get featured profile
    static func getFeaturedProfile(params: [String: Any], success: @escaping (FeaturedProfileModel?, String) -> Void, failure: @escaping (String) -> Void) -> Void {
        Indicator.show()
        
        APIManager.makeRequest(with: Constant.ServerAPI.kFeaturedProfile, method: .post, parameter: params, success: { response -> Void in
            guard let json = response as? [String: Any] else { return }
            guard let data = try? JSONSerialization.data(withJSONObject: json) else { return }
            
            do {
                var featuredProfileModel = try JSONDecoder().decode(FeaturedProfileModel.self, from: data)
                
                if let featuredProfileData = featuredProfileModel.data {
                    if featuredProfileData.count > 0 {
                        for index in 0 ..< featuredProfileData.count {
                            var featuredProfile = featuredProfileData[index]
                            
                            guard let post_url = featuredProfile.postURL, let post_thumb = featuredProfile.postThumbnail, let post_intro_video = featuredProfile.introductionVideo, let post_intro_video_thumb = featuredProfile.introductionVideoThumb else { return }
                            
                            let post_url_path = AWSS3Manager.shared.getMediaUrl(name: post_url, bucketName: featuredProfile.postType == 1 ? .postImage : .postVideo)
                            let post_thumb_path = AWSS3Manager.shared.getMediaUrl(name: post_thumb, bucketName: featuredProfile.postType == 1 ? .postImage : .postVideoThumb)
                            let post_intro_video_path = AWSS3Manager.shared.getMediaUrl(name: post_intro_video, bucketName: .introVideo)
                            let post_intro_video_thumb_path = AWSS3Manager.shared.getMediaUrl(name: post_intro_video_thumb, bucketName: .introThumbnail)
                            
                            AWSS3Manager.shared.getSignedUrl(key: post_url_path, withSuccess: { postUrl in
                                featuredProfile.postURL = postUrl
                                
                                AWSS3Manager.shared.getSignedUrl(key: post_thumb_path, withSuccess: { postThumb in
                                    featuredProfile.postThumbnail = postThumb
                                    
                                    AWSS3Manager.shared.getSignedUrl(key: post_intro_video_path, withSuccess: { introVideo in
                                        featuredProfile.introductionVideo = introVideo
                                        
                                        AWSS3Manager.shared.getSignedUrl(key: post_intro_video_thumb_path, withSuccess: { introVideoThumb in
                                            featuredProfile.introductionVideoThumb = introVideoThumb
                                            
                                            if featuredProfile.postGroup!.count > 0 {
                                                for index in 0 ..< featuredProfile.postGroup!.count {
                                                    var groupPost = featuredProfile.postGroup![index]
                                                    
                                                    if let group_video = groupPost.invitedUserVideoURL, let group_video_thumb = groupPost.invitedUserVideoThumbnailURL {
                                                        var group_video = AWSS3Manager.shared.getMediaUrl(name: group_video, bucketName: .postVideo)
                                                        var group_video_thumb = AWSS3Manager.shared.getMediaUrl(name: group_video_thumb, bucketName: .postVideoThumb)
                                                        
                                                        group_video = "https://d234fq55kjo26g.cloudfront.net/\(group_video)"
                                                        group_video_thumb = "https://d234fq55kjo26g.cloudfront.net/\(group_video_thumb)"
                                                        
                                                        groupPost.invitedUserVideoURL = group_video
                                                        groupPost.invitedUserVideoThumbnailURL = group_video_thumb
                                                        
                                                        featuredProfile.postGroup![index] = groupPost
                                                    }
                                                }
                                                
                                                featuredProfileModel.data![index] = featuredProfile
                                            } else {
                                                featuredProfileModel.data![index] = featuredProfile
                                            }
                                            
                                            if let postComments = featuredProfile.postComments {
                                                if postComments.count > 0 {
                                                    for commentIdx in 0 ..< postComments.count {
                                                        var comment = postComments[commentIdx]
                                                        
                                                        guard let comment_intro_video = comment.introductionVideo, let comment_intro_video_thumb = comment.introductionVideoThumb else { return }
                                                        
                                                        let comment_intro_video_path = AWSS3Manager.shared.getMediaUrl(name: comment_intro_video, bucketName: .introVideo)
                                                        let comment_intro_video_thumb_path = AWSS3Manager.shared.getMediaUrl(name: comment_intro_video_thumb, bucketName: .introThumbnail)
                                                        
                                                        AWSS3Manager.shared.getSignedUrl(key: comment_intro_video_path, withSuccess: { commentIntroVideo in
                                                            comment.introductionVideo = commentIntroVideo
                                                            
                                                            AWSS3Manager.shared.getSignedUrl(key: comment_intro_video_thumb_path, withSuccess: { commentIntroVideoThumb in
                                                                comment.introductionVideoThumb = commentIntroVideoThumb
                                                                
                                                                featuredProfile.postComments![commentIdx] = comment
                                                            })
                                                        })
                                                    }
                                                }
                                            }
                                            
                                            featuredProfileModel.data![index] = featuredProfile
                                        })
                                    })
                                })
                            })
                        }
                    }
                }
                
                success(featuredProfileModel, featuredProfileModel.message ?? "")
                Indicator.hide()
            } catch let error {
                print(error.localizedDescription)
                
                failure(error.localizedDescription)
                Indicator.hide()
            }
        }, failure: { error, errorCode, isAuth -> Void  in
            failure(error)
            Indicator.hide()
        }, connectionFailed: { error -> Void in
            failure(error)
            Indicator.hide()
        })
    }
}

