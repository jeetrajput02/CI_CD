//
//  AllUserListModel.swift
//  WhosNext
//
//  Created by differenz195 on 16/11/22.
//

import Foundation

struct AllUserListModel: Codable, Equatable, Hashable, Identifiable {
    var id = UUID()

    var success: Bool
    var statusCode: Int
    var message: String
    var data: [AllUserListData]
    
    enum CodingKeys: String, CodingKey {
        case success
        case statusCode = "status_code"
        case message, data
    }
}

struct AllUserListData: Codable, Equatable, Hashable, Identifiable {
    var id = UUID()

    let firstName, lastName, username, fullName: String?
    let userID: Int?

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case username = "username"
        case userID = "user_id"
        case fullName = "full_name"
    }
}


// MARK: - API Calls
extension AllUserListModel {
    /// `api call` for get the cities
    static func getAllUserList(success: @escaping (AllUserListModel?, String) -> Void, failure: @escaping (String) -> Void) -> Void {
        Indicator.show()
        
        APIManager.makeRequest(with: Constant.ServerAPI.kGetAllUserList, method: .get, parameter: nil, success: { response -> Void in
            Indicator.hide()
            
            guard let json = response as? [String: Any] else { return }
            guard let data = try? JSONSerialization.data(withJSONObject: json) else { return }
            
            do {
                let allUserListModel = try JSONDecoder().decode(AllUserListModel.self, from: data)
                
                success(allUserListModel, allUserListModel.message)
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
