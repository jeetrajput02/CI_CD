//
//  PostModel.swift
//  WhosNext
//
//  Created by differenz195 on 16/11/22.
//

import Foundation


enum PostModelKey {
    static let postID = "post_id"
    static let reasonID = "reason_id"
    static let id = "id"
    static let postType = "post_type"
    static let postSubType = "post_sub_type"
    static let postUrl = "post_url"
    static let postCaption = "post_caption"
    static let taggedSelectedPeople = "tagged_selected_people"
    static let taggedSelectedPeopleInGroupVideo = "tagged_selected_people_in_group_video"
    static let totalLike = "total_like"
    static let postThumbnail = "post_thumbnail"
    static let viewType = "view_type"
    static let post_width = "post_width"
    static let post_height = "post_height"
    
}
struct PostModel: Codable {
    var success: Bool
    var statusCode: Int
    var message: String
    var data: PostData

    enum CodingKeys: String, CodingKey {
        case success
        case statusCode = "status_code"
        case message, data
    }
}

struct PostData: Codable {

    var postType, postSubType: Int?
    var postID,postUrl, postCaption, taggedSelectedPeople, totalLike, postThumbnail, postViewCount: String?

    enum CodingKeys: String, CodingKey {

        case postID = "post_id"
        case postType = "post_type"
        case postSubType = "post_sub_type"
        case postUrl = "post_url"
        case postCaption = "post_caption"
        case taggedSelectedPeople = "tagged_selected_people"
        case totalLike = "total_like"
        case postThumbnail = "post_thumbnail"
        case postViewCount = "post_view_count"
    }
}

// MARK: - API Calls
extension PostModel {
    /// `api call` for user create the post
    static func createUpdatePost(params: [String: Any], success: @escaping (PostModel?, String) -> Void, failure: @escaping (String) -> Void) -> Void {
        APIManager.makeRequest(with: Constant.ServerAPI.kCreateOrUpdatePost, method: .post , parameter: params, success: { response -> Void in
            guard let json = response as? [String: Any] else { return }
            guard let data = try? JSONSerialization.data(withJSONObject: json) else { return }
            
            do {
                let updatedPostModel = try JSONDecoder().decode(PostModel.self, from: data)
                
                success(updatedPostModel, updatedPostModel.message)
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
    
    /// `api call` for post like
    static func postLike(params: [String: Any], success: @escaping () -> Void, failure: @escaping (String) -> Void) -> Void {
        APIManager.makeRequest(with: Constant.ServerAPI.kPostLike, method: .post, parameter: params, success: { response -> Void in
            success()
        }, failure: { error, errorCode, isAuth -> Void in
            Indicator.hide()
            
            failure(error)
        }, connectionFailed: { error -> Void in
            Indicator.hide()
            
            failure(error)
        })
    }
    
    /// `api call` for post delete
    static func postDelete(params: [String: Any], success: @escaping () -> (), failure: @escaping (String) -> Void) -> Void {
        APIManager.makeRequest(with: Constant.ServerAPI.kDeletePost, method: .post, parameter: params, success: { response -> Void in
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
    
    /// `api call` for post report
    static func postReport(params: [String: Any], success: @escaping () -> (), failure: @escaping (String) -> Void) -> Void {
        APIManager.makeRequest(with: Constant.ServerAPI.kPostReport, method: .post, parameter: params, success: { response -> Void in
            success()
        }, failure: { error, errorCode, isAuth -> Void in
            Indicator.hide()
            
            failure(error)
        }, connectionFailed: { error -> Void in
            Indicator.hide()
            
            failure(error)
        })
    }
    
    /// `api call` for post details
    static func postDetails(params: [String: Any], success: @escaping () -> (), failure: @escaping (String) -> Void) -> Void {
        APIManager.makeRequest(with: Constant.ServerAPI.kPostDetail, method: .post, parameter: params, success: { response -> Void in
            success()
        }, failure: { error, errorCode, isAuth -> Void in
            Indicator.hide()
            
            failure(error)
        }, connectionFailed: { error -> Void in
            Indicator.hide()
            
            failure(error)
        })
    }
    
    /// `api call` for post View Count
    static func postViewCount(params: [String: Any], success: @escaping () -> Void, failure: @escaping (String) -> Void) -> Void {
        APIManager.makeRequest(with: Constant.ServerAPI.kUpdateViewCount, method: .post, parameter: params, success: { response -> Void in
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
