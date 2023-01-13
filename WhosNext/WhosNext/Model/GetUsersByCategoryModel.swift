//
//  GetUsersByCategoryModel.swift
//  WhosNext
//
//  Created by differenz240 on 22/11/22.
//

import SwiftUI

enum GetUsersByCategoryKeys: String {
    case category_id, search_keyword
}

struct GetUsersByCategoryModel: Codable, Equatable, Hashable, Identifiable {
    var id = UUID()

    var success: Bool?
    var statusCode: Int?
    var message: String?
    var data: [GetUsersByCategoryData]?
    
    enum CodingKeys: String, CodingKey {
        case success
        case statusCode = "status_code"
        case message, data
    }
}

struct GetUsersByCategoryData: Codable, Equatable, Hashable, Identifiable {
    var userID, id: Int?
    var firstName, lastName: String?
    var username, email: String?
    var categoryID, introductionVideo, introductionVideoThumb, fullName: String?
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case username, email
        case categoryID = "category_id"
        case introductionVideo = "introduction_video"
        case introductionVideoThumb = "introduction_video_thumb"
        case fullName = "full_name"
    }
}

// MARK: - API Calls
extension GetUsersByCategoryModel {
    /// `api call` for user list by category id
    static func getUsersByCategory(params: [String: Any], success: @escaping (GetUsersByCategoryModel?, String) -> Void, failure: @escaping (String) -> Void) -> Void {
        Indicator.show()
        
        APIManager.makeRequest(with: Constant.ServerAPI.kGetUsersByCategory, method: .post, parameter: params, success: { response -> Void in
            guard let json = response as? [String: Any] else { return }
            guard let data = try? JSONSerialization.data(withJSONObject: json) else { return }
            
            do {
                var getUsersByCategory = try JSONDecoder().decode(GetUsersByCategoryModel.self, from: data)

                if (getUsersByCategory.data?.count ?? 0) > 0 {
                    for index in 0 ..< getUsersByCategory.data!.count {
                        var user = getUsersByCategory.data![index]
                        
                        if let url = user.introductionVideoThumb {
                            let path = AWSS3Manager.shared.getMediaUrl(name: url, bucketName: .introThumbnail)
                            AWSS3Manager.shared.getSignedUrl(key: path, withSuccess: { signedUrl in
                                user.introductionVideoThumb = signedUrl
                                getUsersByCategory.data![index] = user
                            })
                        }
                    }
                }
                
                success(getUsersByCategory, getUsersByCategory.message ?? "")
                Indicator.hide()
            } catch let error {
                print(error.localizedDescription)
                Indicator.hide()
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
