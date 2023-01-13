//
//  GridPostModel.swift
//  WhosNext
//
//  Created by differenz195 on 17/11/22.
//

import Foundation


enum GridPostModelKey {
    static let postID = "post_id"
    static let postThumbnail = "post_thumbnail"
    static let type = "type"
}

struct GridPostModel: Codable, Hashable {
    var success: Bool
    var statusCode: Int
    var message: String
    var data: [GridPostData]

    enum CodingKeys: String, CodingKey {
        case success
        case statusCode = "status_code"
        case message, data
    }
}

struct GridPostData: Codable, Hashable {
    var postID: Int
    var postThumbnail: String

    enum CodingKeys: String, CodingKey {
        case postID = "post_id"
        case postThumbnail = "post_thumbnail"
    }
}

//MARK: - API Calls
extension GridPostModel {
    /// `api call` for grid post
    static func gridPostApi(params: [String: Any], success: @escaping (GridPostModel?, String) -> Void, failure: @escaping (String) -> Void) -> Void {
        Indicator.show()
        
        APIManager.makeRequest(with: Constant.ServerAPI.kPostGridView, method: .post, parameter: params, success: { response -> Void in
            guard let json = response as? [String: Any] else { return }
            guard let data = try? JSONSerialization.data(withJSONObject: json) else { return }
        
            do {
                var updatedGridPostModel = try JSONDecoder().decode(GridPostModel.self, from: data)

                for index in 0 ..< updatedGridPostModel.data.count {
                    var post = updatedGridPostModel.data[index]

                    let url = AWSS3Manager.shared.getMediaUrl(name: post.postThumbnail, bucketName: .postImage) // change bucket
                    AWSS3Manager.shared.getSignedUrl(key: url, withSuccess: { signedUrl in
                        post.postThumbnail = signedUrl

                        updatedGridPostModel.data[index] = post
                    })
                }

                success(updatedGridPostModel, updatedGridPostModel.message)
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
    
}
