//
//  CommentsModel.swift
//  WhosNext
//
//  Created by differenz195 on 11/10/22.
//

import Foundation

enum CommentsModelKeys: String {
    case post_id, post_comment, comment_id
}

struct CommentsModel: Codable, Equatable, Hashable, Identifiable {
    var id = UUID()

    var success: Bool
    var statusCode: Int
    var message: String
    var data: [CommentsData]

    enum CodingKeys: String, CodingKey {
        case success
        case statusCode = "status_code"
        case message, data
    }
}

struct CommentsData: Codable, Equatable, Hashable, Identifiable {
    var id = UUID()

    var commentID, userID, postID: Int
    var postComment, firstName, lastName, username: String
    var introductionVideoThumb: String?
    var fullName, introductionVideo, lastModificationTime: String
    var timeDisplayStr: String
    
    enum CodingKeys: String, CodingKey {
        case commentID = "comment_id"
        case userID = "user_id"
        case postID = "post_id"
        case postComment = "post_comment"
        case firstName = "first_name"
        case lastName = "last_name"
        case username
        case fullName = "full_name"
        case introductionVideoThumb = "introduction_video_thumb"
        case introductionVideo = "introduction_video"
        case lastModificationTime = "last_modification_time"
        case timeDisplayStr = "time_display_str"
    }
}

// MARK: - API Calls
extension CommentsModel {
    /// `api call` for comments list
    static func getCommentsList(params: [String: Any], success: @escaping (CommentsModel?, String) -> Void, failure: @escaping (String) -> Void) -> Void {
        Indicator.show()
        
        APIManager.makeRequest(with: Constant.ServerAPI.kPostCommentList, method: .post, parameter: params, success: { response -> Void in
            guard let json = response as? [String: Any] else { return }
            guard let data = try? JSONSerialization.data(withJSONObject: json) else { return }
            
            do {
                let commentsModel = try JSONDecoder().decode(CommentsModel.self, from: data)
                
                success(commentsModel, commentsModel.message)
                Indicator.hide()
            } catch let error {
                print(error.localizedDescription)
            }
        }, failure: { error, errorCode, isAuth -> Void in
            Indicator.hide()
            
            failure(error)
        }, connectionFailed: { error -> Void in
            Indicator.hide()
            
            failure(error)
        })
    }
    
    /// `api call` for comment on post
    static func postComment(params: [String: Any], success: @escaping () -> Void, failure: @escaping (String) -> Void) -> Void {
        Indicator.show()
        
        APIManager.makeRequest(with: Constant.ServerAPI.kPostComment, method: .post, parameter: params, success: { response -> Void in
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
    
    /// `api call` for delete the comment
    static func deleteComment(params: [String: Any], success: @escaping () -> Void, failure: @escaping (String) -> Void) -> Void {
        Indicator.show()

        APIManager.makeRequest(with: Constant.ServerAPI.kPostCommentDelete, method: .post, parameter: params, success: { response -> Void in
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
}
