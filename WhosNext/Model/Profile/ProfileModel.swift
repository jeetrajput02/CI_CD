//
//  ProfileModel.swift
//  WhosNext
//
//  Created by differenz240 on 08/11/22.
//

import Foundation
import SwiftUI

enum ProfileModelKey {
    static let user_id = "user_id"
    static let first_name = "first_name"
    static let last_name = "last_name"
    static let username = "username"
    static let email = "email"
    static let city_id = "city_id"
    static let category_id = "category_id"
    static let introduction_video = "introduction_video"
    static let introduction_video_thumb = "introduction_video_thumb"
    static let video_height = "video_height"
    static let video_width = "video_width"
    static let about_self = "about_self"
    static let is_private = "is_private"
    static let website_url_1 = "website_url_1"
    static let website_url_2 = "website_url_2"
    static let website_url_3 = "website_url_3"
    static let website_url_4 = "website_url_4"
    static let website_url_5 = "website_url_5"
}

struct ProfileModel: Codable, Equatable, Hashable, Identifiable {
    var id = UUID()

    var success: Bool
    var statusCode: Int
    var message: String
    var data: ProfileData
    
    enum CodingKeys: String, CodingKey {
        case success
        case statusCode = "status_code"
        case message, data
    }
}

struct ProfileData: Codable, Equatable, Hashable, Identifiable {
    var id = UUID()

    var userID, userType: Int
    var firstName, lastName, username, email: String
    var cityID, city: String
    var introductionVideo, introductionVideoThumb: String?
    var videoHeight, videoWidth: Double?
    var aboutSelf, categoryID: String
    var categoryArr: [CategoryArr]
    var categoryName: String
    var isPrivate, isSubscribed, isNotificationEnable, isVerified: Bool
    var authorization: String
    var postCount, followersCount, followingCount, profileViewCount: Int
    var websiteURL1, websiteURL2, websiteURL3, websiteURL4, websiteURL5: String
    var groupVideos: [ProfileGroupVideo]?
    var isFollowing: Int
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case userType = "user_type"
        case firstName = "first_name"
        case lastName = "last_name"
        case username, email
        case cityID = "city_id"
        case city
        case introductionVideo = "introduction_video"
        case introductionVideoThumb = "introduction_video_thumb"
        case videoHeight = "video_height"
        case videoWidth = "video_width"
        case aboutSelf = "about_self"
        case categoryID = "category_id"
        case categoryArr = "category_arr"
        case categoryName = "category_name"
        case isPrivate = "is_private"
        case isSubscribed = "is_subscribed"
        case isNotificationEnable = "is_notification_enable"
        case isVerified = "is_verified"
        case authorization = "Authorization"
        case postCount = "post_count"
        case followersCount = "followers_count"
        case followingCount = "following_count"
        case profileViewCount = "profile_view_count"
        case websiteURL1 = "website_url_1"
        case websiteURL2 = "website_url_2"
        case websiteURL3 = "website_url_3"
        case websiteURL4 = "website_url_4"
        case websiteURL5 = "website_url_5"
        case groupVideos = "group_videos"
        case isFollowing = "is_following"
    }
}

struct CategoryArr: Codable, Equatable, Hashable, Identifiable {
    var id = UUID()

    var categoryID: Int
    var category: String
    
    enum CodingKeys: String, CodingKey {
        case categoryID = "category_id"
        case category
    }
}

struct ProfileGroupVideo: Codable, Equatable, Hashable, Identifiable {
    var id = UUID()

    var postID, userID, postCategory, postType, postSubType: Int?
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

// MARK: - API Calls
extension ProfileModel {
    /// `api call` for get the user profile
    static func getUserProfileApiCall(params: [String: Any], success: @escaping (ProfileModel?, String) -> Void, failure: @escaping (String) -> Void) -> Void {
        Indicator.show()
        
        APIManager.makeRequest(with: Constant.ServerAPI.kGetUserProfile, method: .post, parameter: params, success: { response -> Void in
            guard let json = response as? [String: Any] else { return }
            guard let data = try? JSONSerialization.data(withJSONObject: json) else { return }
            
            do {
                var profileModel = try JSONDecoder().decode(ProfileModel.self, from: data)
                
                let video_path = AWSS3Manager.shared.getMediaUrl(name: profileModel.data.introductionVideo ?? "", bucketName: .introVideo)
                let video_thumbnail_path = AWSS3Manager.shared.getMediaUrl(name: profileModel.data.introductionVideoThumb ?? "", bucketName: .introThumbnail)

                AWSS3Manager.shared.getSignedUrl(key: video_path, withSuccess: { introVideo in
                    profileModel.data.introductionVideo = introVideo

                    AWSS3Manager.shared.getSignedUrl(key: video_thumbnail_path, withSuccess: { introVideoThumb in
                        profileModel.data.introductionVideoThumb = introVideoThumb

                        if profileModel.data.groupVideos != nil {
                            if (profileModel.data.groupVideos?.count ?? 0) > 0 {
                                for groupIdx in 0 ..< (profileModel.data.groupVideos?.count ?? 0) {
                                    var groupVideo = profileModel.data.groupVideos![groupIdx]

                                    let post_video_path = AWSS3Manager.shared.getMediaUrl(name: groupVideo.postURL ?? "", bucketName: .postVideo)
                                    let post_video_thumbnail_path = AWSS3Manager.shared.getMediaUrl(name: groupVideo.postThumbnail ?? "", bucketName: .postVideoThumb)

                                    AWSS3Manager.shared.getSignedUrl(key: post_video_path, withSuccess: { postUrl in
                                        groupVideo.postURL = postUrl

                                        AWSS3Manager.shared.getSignedUrl(key: post_video_thumbnail_path, withSuccess: { postThumb in
                                            groupVideo.postThumbnail = postThumb

                                            profileModel.data.groupVideos![groupIdx] = groupVideo
                                        })
                                    })
                                }
                            }
                        }
                    })
                })

                success(profileModel, profileModel.message)
                
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
    
    /// `api call` for update the user profile
    static func updateUserProfile(params: [String: Any], success: @escaping (ProfileModel?, String) -> Void, failure: @escaping (String) -> Void) -> Void {
        Indicator.show()
        
        APIManager.makeRequest(with: Constant.ServerAPI.kUpdateUserProfile, method: .post, parameter: params, success: { response -> Void in
            guard let json = response as? [String: Any] else { return }
            guard let data = try? JSONSerialization.data(withJSONObject: json) else { return }
            
            do {
                let updatedProfileModel = try JSONDecoder().decode(ProfileModel.self, from: data)
                
                success(updatedProfileModel, updatedProfileModel.message)
            } catch let error {
                print(error.localizedDescription)
                
                failure(error.localizedDescription)
            }
        }, failure: { error, errorCode, isAuth -> Void in
            Indicator.hide()
            
            failure(error)
        }, connectionFailed: { error -> Void in
            Indicator.hide()
            
            failure(error)
        })
    }
    
    /// `api call` for change profile visibility
    static func changeProfileVisibility(params: [String: Any], success: @escaping (ProfileModel?, String) -> Void, failure: @escaping (String) -> Void) -> Void {
        Indicator.show()
        
        APIManager.makeRequest(with: Constant.ServerAPI.kUpdateUserProfile, method: .post, parameter: params, success: { response -> Void in
            guard let json = response as? [String: Any] else { return }
            guard let data = try? JSONSerialization.data(withJSONObject: json) else { return }
            
            do {
                let updatedProfileModel = try JSONDecoder().decode(ProfileModel.self, from: data)
                
                success(updatedProfileModel, updatedProfileModel.message)
            } catch let error {
                print(error.localizedDescription)
                
                failure(error.localizedDescription)
            }
        }, failure: { error, errorCode, isAuth -> Void in
            Indicator.hide()
            
            failure(error)
        }, connectionFailed: { error -> Void in
            Indicator.hide()
            
            failure(error)
        })
    }
    
    /// `api call` for deactivate account
    static func deactivateAccount(success: @escaping (Bool, String) -> Void, failure: @escaping (String) -> Void) -> Void {
        Indicator.show()
        
        APIManager.makeRequest(with: Constant.ServerAPI.kDeactivateAccount, method: .get, parameter: nil, success: { response -> Void in
            success(true, "account deactivated succesfully.")
        }, failure: { error, errorCode, isAuth -> Void in
            Indicator.hide()
            
            failure(error)
        }, connectionFailed: { error -> Void in
            Indicator.hide()
            
            failure(error)
        })
    }
    
    /// `api call` for follow/unfollow user
    static func followunFollowUser(param: [String: Any], success: @escaping () -> Void, failure: @escaping (String) -> Void) -> Void {
        Indicator.show()
        
        APIManager.makeRequest(with: Constant.ServerAPI.kFollowUser, method: .post, parameter: param, success: { response -> Void in
            success()
        }, failure: { error, errorCode, isAuth -> Void in
            Indicator.hide()
            
            failure(error)
        }, connectionFailed: { error -> Void in
            Indicator.hide()
            
            failure(error)
        })
    }
}
