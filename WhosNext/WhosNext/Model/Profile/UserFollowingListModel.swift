//
//  UserFollowingListModel.swift
//  WhosNext
//
//  Created by differenz240 on 23/11/22.
//

import Foundation

struct UserFollowingListModel: Codable, Equatable, Hashable {
    var success: Bool?
    var statusCode: Int?
    var message: String?
    var data: [UserFollowingListData]?
    
    enum CodingKeys: String, CodingKey {
        case success
        case statusCode = "status_code"
        case message, data
    }
}

struct UserFollowingListData: Codable, Equatable, Hashable {
    var followID, followerID, followingID, followStatus: Int?
    var userID: Int?
    var firstName, lastName, username, introductionVideo: String?
    var introductionVideoThumb: String?
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
extension UserFollowingListModel {
    /// `api call` for get the followings of the user
    static func getUserFollowingList(param: [String: Any], success: @escaping (UserFollowingListModel?, String) -> Void, failure: @escaping (String) -> Void) -> Void {
        Indicator.show()

        APIManager.makeRequest(with: Constant.ServerAPI.kUserFollowingList, method: .post, parameter: param, success: { response -> Void in
            guard let json = response as? [String: Any] else { return }
            guard let data = try? JSONSerialization.data(withJSONObject: json) else { return }
            
            do {
                var userFollowingListModel = try JSONDecoder().decode(UserFollowingListModel.self, from: data)
                
                if userFollowingListModel.data!.count > 0 {
                    for index in 0 ..< userFollowingListModel.data!.count {
                        var follower = userFollowingListModel.data![index]
                        
                        if let url = follower.introductionVideoThumb {
                            let path = AWSS3Manager.shared.getMediaUrl(name: url, bucketName: .introThumbnail)
                            AWSS3Manager.shared.getSignedUrl(key: path, withSuccess: { signedUrl in
                                follower.introductionVideoThumb = signedUrl
                                userFollowingListModel.data![index] = follower
                            })
                        }
                    }
                }

                success(userFollowingListModel, userFollowingListModel.message ?? "")
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
