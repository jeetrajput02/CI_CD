//
//  SnippetRequestModel.swift
//  WhosNext
//
//  Created by differenz240 on 10/01/23.
//

import Foundation

struct SnippetRequestModel: Codable, Equatable, Hashable, Identifiable {
    var id = UUID()

    var success: Bool?
    var statusCode: Int?
    var message: String?
    var data: [SnippetRequestData]?
    
    enum CodingKeys: String, CodingKey {
        case success
        case statusCode = "status_code"
        case message, data
    }
}

struct SnippetRequestData: Codable, Equatable, Hashable, Identifiable {
    var id = UUID()

    var userID: Int?
    var username, introductionVideoThumb: String?
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case username
        case introductionVideoThumb = "introduction_video_thumb"
    }
}

// MARK: - API Calls
extension SnippetRequestModel {
    /// `api call` for getting the list of snippet request
    static func getSnippetRequestList(success: @escaping (SnippetRequestModel?, String) -> Void, failure: @escaping (String) -> Void) -> Void {
        Indicator.show()
        
        APIManager.makeRequest(with: Constant.ServerAPI.kSnippetRequestList, method: .get, parameter: nil, success: { response -> Void in
            guard let json = response as? [String: Any], let data = try? JSONSerialization.data(withJSONObject: json) else { return }
            
            do {
                let snippetRequestModel = try JSONDecoder().decode(SnippetRequestModel.self, from: data)
                
                success(snippetRequestModel, snippetRequestModel.message ?? "")
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
    
    /// `api call` for accept reject snippet request
    static func acceptRejectSnippetRequest(params: [String: Any], success: @escaping () -> Void, failure: @escaping (String) -> Void) -> Void {
        Indicator.show()
        
        APIManager.makeRequest(with: Constant.ServerAPI.kAcceptRejectSnippetRequest, method: .post, parameter: params, success: { response -> Void in
            success()
            
            Indicator.hide()
        }, failure: { error, errorCode, isAuth -> Void in
            Indicator.hide()
            
            failure(error)
        }, connectionFailed: { error -> Void in
            Indicator.hide()
            
            failure(error)
        })
    }
    
    /// `api call` for accept & reject request
    static func snippetSendRequest(success: @escaping () -> Void, failure: @escaping (String) -> Void) {
        APIManager.makeRequest(with: Constant.ServerAPI.kSendRequest, method: .get, parameter: nil, success: { response -> Void in
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
