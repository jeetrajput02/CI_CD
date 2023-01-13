//
//  UserFollowersListModel.swift
//  WhosNext
//
//  Created by differenz195 on 22/11/22.
//

import Foundation

struct UserFollowersListModel: Codable, Equatable, Hashable {
    var success: Bool?
    var statusCode: Int?
    var message: String?
    var data: [UserFollowersListData]?
    
    enum CodingKeys: String, CodingKey {
        case success
        case statusCode = "status_code"
        case message, data
    }
}

struct UserFollowersListData: Codable, Equatable, Hashable {
    var followID, followerID, followingID, followStatus: Int?
    var userID: Int?
    var firstName, lastName, username: String?
    var introductionVideo, introductionVideoThumb: String?
    var userFollowStatus: Int?
    
    enum CodingKeys: String, CodingKey {
        case followID = "follow_id"
        case followerID = "follower_id"
        case followingID = "following_id"
        case followStatus = "follow_status"
        case userID = "user_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case username
        case introductionVideo = "introduction_video"
        case introductionVideoThumb = "introduction_video_thumb"
        case userFollowStatus = "user_follow_status"
    }
}

// MARK: - API Calls
extension UserFollowersListModel {
    /// `api call` for get the followers of the user
    static func getUserFollowersList(params: [String: Any], success: @escaping (UserFollowersListModel?, String) -> Void, failure: @escaping (String) -> Void) -> Void {
        Indicator.show()
        
        APIManager.makeRequest(with: Constant.ServerAPI.kUserFollowersList, method: .post, parameter: params, success: { response -> Void in
            guard let json = response as? [String: Any] else { return }
            guard let data = try? JSONSerialization.data(withJSONObject: json) else { return }
            
            do {
                var updatedFollowerModel = try JSONDecoder().decode(UserFollowersListModel.self, from: data)
                
                if updatedFollowerModel.data!.count > 0 {
                    for index in 0 ..< updatedFollowerModel.data!.count {
                        var follower = updatedFollowerModel.data![index]
                        
                        if let url = follower.introductionVideoThumb {
                            let path = AWSS3Manager.shared.getMediaUrl(name: url, bucketName: .introThumbnail)
                            AWSS3Manager.shared.getSignedUrl(key: path, withSuccess: { signedUrl in
                                follower.introductionVideoThumb = signedUrl
                                updatedFollowerModel.data![index] = follower
                            })
                        }
                    }
                }

                success(updatedFollowerModel, updatedFollowerModel.message ?? "")
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
