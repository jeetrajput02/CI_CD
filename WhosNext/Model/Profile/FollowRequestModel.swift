//
//  FollowRequestModel.swift
//  WhosNext
//
//  Created by differenz240 on 11/01/23.
//

import Foundation

struct FollowRequestModel: Codable, Equatable, Hashable, Identifiable {
    var id = UUID()

    var success: Bool?
    var statusCode: Int?
    var message: String?
    var data: [FollowRequestData]?
    
    enum CodingKeys: String, CodingKey {
        case success
        case statusCode = "status_code"
        case message, data
    }
}

struct FollowRequestData: Codable, Equatable, Hashable, Identifiable {
    var id = UUID()

    var followID, followingID: Int?
    var fullname, username, firstName: String?
    
    enum CodingKeys: String, CodingKey {
        case followID = "follow_id"
        case followingID = "following_id"
        case fullname, username
        case firstName = "first_name"
    }
}

// MARK: - API Calls
extension FollowRequestModel {
    /// `api call` for getting the list of follower's request
    static func getFollowRequestList(success: @escaping (FollowRequestModel?, String) -> Void, failure: @escaping (String) -> Void) -> Void {
        Indicator.show()
        
        APIManager.makeRequest(with: Constant.ServerAPI.kFollowRequestList, method: .get, parameter: nil, success: { response -> Void in
            guard let json = response as? [String: Any], let data = try? JSONSerialization.data(withJSONObject: json) else { return }
            
            do {
                let followRequestModel = try JSONDecoder().decode(FollowRequestModel.self, from: data)
                
                success(followRequestModel, followRequestModel.message ?? "")
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
