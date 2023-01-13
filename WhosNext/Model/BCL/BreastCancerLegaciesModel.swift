//
//  BreastCancerLegaciesModel.swift
//  WhosNext
//
//  Created by differenz195 on 07/12/22.
//

import Foundation

enum BreastCancerLegaciesModelKeys: String {
    case post_id, legacies_name, legacies_description, post_url, post_thumbnail, post_height, post_width, carnation, date_of_birth, date_of_passing
}

// MARK: - BreastCancerLegaciesModel
struct BreastCancerLegaciesModel: Codable, Equatable, Hashable {
    let postID, legaciesName, legaciesDescription, postURL: String?
    let postThumbnail, postHeight, postWidth, carnation, dateOfBirth, dateOfPassing: String?
    
    enum CodingKeys: String, CodingKey {
        case postID = "post_id"
        case legaciesName = "legacies_name"
        case legaciesDescription = "legacies_description"
        case postURL = "post_url"
        case postThumbnail = "post_thumbnail"
        case postHeight = "post_height"
        case postWidth = "post_width"
        case carnation
        case dateOfBirth = "date_of_birth"
        case dateOfPassing = "date_of_passing"
    }
}

// MARK: - legaciesHomeScreenModel
struct LegaciesHomeScreenModel: Codable, Hashable, Equatable, Identifiable {
    var id = UUID()
    
    var success: Bool?
    var statusCode: Int?
    var message: String?
    var totalCount: Int?
    var data: [LegaciesHomeScreenData]?
    
    enum CodingKeys: String, CodingKey {
        case success
        case statusCode = "status_code"
        case message
        case totalCount = "total_count"
        case data
    }
}

struct LegaciesHomeScreenData: Codable, Hashable, Equatable, Identifiable {
    var id = UUID()
    
    var postID, userID, postCategory, postType, postSubType: Int?
    var postURL, postThumbnail: String?
    var postHeight, postWidth: Double?
    var postViewCount: Int?
    var legaciesName, legaciesDescription: String?
    var carnation: Int?
    var dateOfBirth, dateOfPassing: String?
    var username, firstName, lastName, fullName: String?
    var introductionVideoThumb, introductionVideo: String?
    var lastModificationTime: String?
    var timeDisplayStr: String?
    var isVerified: Bool?
    var postLikeCount, postCommentCount, isOwnLike, isOwnView, isOwnPost: Int?
    var postComments: [PostComment]?
    var postGroup: [PostGroup]?
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
        case postHeight = "post_height"
        case postWidth = "post_width"
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
        case postGroup = "post_group"
        case isVideoPlaying = "is_video_playing"
        case isNotificationFired = "is_notification_fired"
        case callCountApiCall = "call_count_api_call"
    }
}

// MARK: - API Calls
extension BreastCancerLegaciesModel {
    /// `api call` for create or update legacies
    static func createOrUpdateLegacies(params: [String: Any], success: @escaping () -> Void, failure: @escaping (String) -> Void) -> Void {
        Indicator.show()
        
        APIManager.makeRequest(with: Constant.ServerAPI.kCreateOrUpdateLegacies, method: .post, parameter: params,  success:  { response -> Void in
            success()
        }, failure: { error, errorcode, isAuth -> Void in
            Indicator.hide()
            failure(error)
        }, connectionFailed: { error -> Void in
            Indicator.hide()
            failure(error)
        })
    }
}

// MARK: - API Calls
extension LegaciesHomeScreenModel {
    /// `api call` for getting BCL data
    static func getLegaciesData(params: [String: Any], success: @escaping (LegaciesHomeScreenModel?, String) -> Void, failure: @escaping (String) -> Void) -> Void {
        Indicator.show()

        APIManager.makeRequest(with: Constant.ServerAPI.kLegaciesHomeScreen, method: .post, parameter: params, success: { response -> Void in
            guard let json = response as? [String: Any] else { return }
            guard let data = try? JSONSerialization.data(withJSONObject: json) else { return }

            do {
                var legaciesHomeScreenModel = try JSONDecoder().decode(LegaciesHomeScreenModel.self, from: data)

                if legaciesHomeScreenModel.data != nil {
                    if (legaciesHomeScreenModel.data?.count ?? 0) > 0 {
                        for index in 0 ..< legaciesHomeScreenModel.data!.count {
                            var legacy = legaciesHomeScreenModel.data![index]

                            guard let post_url = legacy.postURL, let post_thumb = legacy.postThumbnail, let post_intro_video = legacy.introductionVideo, let post_intro_video_thumb = legacy.introductionVideoThumb else { return }
                            
                            let post_url_path = AWSS3Manager.shared.getMediaUrl(name: post_url, bucketName: .bclImage)
                            let post_thumb_path = AWSS3Manager.shared.getMediaUrl(name: post_thumb, bucketName: .bclImage)
                            let post_intro_video_path = AWSS3Manager.shared.getMediaUrl(name: post_intro_video, bucketName: .introVideo)
                            let post_intro_video_thumb_path = AWSS3Manager.shared.getMediaUrl(name: post_intro_video_thumb, bucketName: .introThumbnail)

                            AWSS3Manager.shared.getSignedUrl(key: post_url_path) { postUrl in
                                legacy.postURL = postUrl

                                AWSS3Manager.shared.getSignedUrl(key: post_thumb_path) { postThumb in
                                    legacy.postThumbnail = postThumb

                                    AWSS3Manager.shared.getSignedUrl(key: post_intro_video_path) { introVideo in
                                        legacy.introductionVideo = introVideo

                                        AWSS3Manager.shared.getSignedUrl(key: post_intro_video_thumb_path) { introVideoThumb in
                                            legacy.introductionVideoThumb = introVideoThumb

                                            if legacy.postComments != nil {
                                                if (legacy.postComments?.count ?? 0) > 0 {
                                                    for commentIndex in 0 ..< legacy.postComments!.count {
                                                        var comment = legacy.postComments![commentIndex]

                                                        guard let comment_intro_video = comment.introductionVideo, let comment_intro_video_thumb = comment.introductionVideoThumb else { return }

                                                        let comment_intro_video_path = AWSS3Manager.shared.getMediaUrl(name: comment_intro_video, bucketName: .introVideo)
                                                        let comment_intro_video_thumb_path = AWSS3Manager.shared.getMediaUrl(name: comment_intro_video_thumb, bucketName: .introThumbnail)

                                                        AWSS3Manager.shared.getSignedUrl(key: comment_intro_video_path) { commentIntroVideo in
                                                            comment.introductionVideo = commentIntroVideo
                                                            
                                                            AWSS3Manager.shared.getSignedUrl(key: comment_intro_video_thumb_path) { commentIntroVideoThumb in
                                                                comment.introductionVideoThumb = commentIntroVideoThumb
                                                                
                                                                legacy.postComments![commentIndex] = comment
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            legaciesHomeScreenModel.data![index] = legacy
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                success(legaciesHomeScreenModel, legaciesHomeScreenModel.message ?? "")
                Indicator.hide()
            } catch let error {
                print(error.localizedDescription)
                
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
}
