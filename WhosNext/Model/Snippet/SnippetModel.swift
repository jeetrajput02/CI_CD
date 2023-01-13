//
//  SnippetModel.swift
//  WhosNext
//
//  Created by differenz240 on 16/11/22.
//

import Foundation

enum SnippetModelKeys: String {
    case snippet_id, snippet_type, snippet_file, snippet_thumbnail_file, snippet_detail
}

// MARK: - CreateSnippetModel
struct CreateSnippetModel: Codable {
    var success: Bool
    var statusCode: Int
    var message: String
    
    enum CodingKeys: String, CodingKey {
        case success
        case statusCode = "status_code"
        case message
    }
}

// MARK: - GetSnippetListModel
struct GetSnippetListModel: Codable, Hashable, Equatable, Identifiable {
    var id = UUID()
    
    var success: Bool?
    var statusCode: Int?
    var message: String?
    var totalCount: Int?
    var data: [HomeSinppetData]?
    
    enum CodingKeys: String, CodingKey {
        case success
        case statusCode = "status_code"
        case message
        case totalCount = "total_count"
        case data
    }
}

// MARK: - GetSnippetPermissionModel
struct GetSnippetPermissionModel: Codable {
    var success: Bool?
    var statusCode: Int?
    var message: String?
    var data: GetSnippetPermissionData?
    
    enum CodingKeys: String, CodingKey {
        case success
        case statusCode = "status_code"
        case message, data
    }
}

struct GetSnippetPermissionData: Codable {
    var snippetRequest: Int?
    
    enum CodingKeys: String, CodingKey {
        case snippetRequest = "snippet_request"
    }
}

// MARK: - API Calls
extension CreateSnippetModel {
    /// `api call` for creting a snippet
    static func createSnippetApiCall(params: [String: Any], success: @escaping  (CreateSnippetModel?, String) -> Void, failure: @escaping (String) -> Void) -> Void {
        Indicator.show()
        
        APIManager.makeRequest(with: Constant.ServerAPI.kCreateOrUpdateSnippet, method: .post, parameter: params, success: { response -> Void in
            guard let json = response as? [String: Any], let data = try? JSONSerialization.data(withJSONObject: json) else { return }
            
            do {
                let createSnippetModel = try JSONDecoder().decode(CreateSnippetModel.self, from: data)
                
                success(createSnippetModel, createSnippetModel.message)
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
    
    
    /// `api call` for creting a snippet
    static func createSnippetApiCall1(params: [String: Any], imageData: [String: Data]?, videoData: [String: Data]?, audioData: [String: Data]?,
                                      success: @escaping  (CreateSnippetModel?, String) -> Void, failure: @escaping (String) -> Void) -> Void {
        Indicator.show()
        
        APIManager.makeRequestWithMedia(Constant.ServerAPI.kCreateOrUpdateSnippet, params: params, dataImage: imageData, dataVideo: videoData, dataAudio: audioData,
                                        withSuccess: { response -> Void in
            guard let json = response as? [String: Any], let data = try? JSONSerialization.data(withJSONObject: json) else { return }
            
            do {
                let createSnippetModel = try JSONDecoder().decode(CreateSnippetModel.self, from: data)
                
                success(createSnippetModel, createSnippetModel.message)
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

// MARK: - API Calls
extension GetSnippetListModel {
    /// `api call` for getting snippet list data
    static func getSnippetListData(params: [String: Any], success: @escaping (GetSnippetListModel?, String) -> Void, failure: @escaping (String) -> Void) -> Void {
        Indicator.show()
        
        APIManager.makeRequest(with: Constant.ServerAPI.kSnippetList, method: .post, parameter: params, success: { response -> Void in
            guard let json = response as? [String: Any] else { return }
            print(json)
            guard let data = try? JSONSerialization.data(withJSONObject: json) else { return }
            print(data)
            
            do {
                var getSnippetListModel = try JSONDecoder().decode(GetSnippetListModel.self, from: data)
                
                if getSnippetListModel.data != nil {
                    if (getSnippetListModel.data?.count ?? 0) > 0 {
                        for index in 0 ..< getSnippetListModel.data!.count {
                            var snippet = getSnippetListModel.data![index]
                            var snippet_file_bucket: AWSBucket
                            var snippet_file_path = ""
                            
                            guard let snippet_file = snippet.snippetFile, let snippet_thumb = snippet.snippetThumb, let snippet_intro_video = snippet.introductionVideo, let snippet_intro_video_thumb = snippet.introductionVideoThumb else { return }
                            
                            if snippet.snippetType == 1 {
                                snippet_file_bucket = .snippetImage
                                snippet_file_path =  AWSS3Manager.shared.getMediaUrl(name: snippet_file, bucketName: snippet_file_bucket)
                            } else if snippet.snippetType == 2 {
                                snippet_file_bucket = .snippetVideo
                                snippet_file_path =  AWSS3Manager.shared.getMediaUrl(name: snippet_file, bucketName: snippet_file_bucket)
                            } else if snippet.snippetType == 3 {
                                snippet_file_bucket = .snippetAudio
                                snippet_file_path =  AWSS3Manager.shared.getMediaUrl(name: snippet_file, bucketName: snippet_file_bucket)
                            }
                            
                            let snippet_thumb_path = AWSS3Manager.shared.getMediaUrl(name: snippet_thumb, bucketName: .snippetThumb)
                            let snippet_intro_video_path = AWSS3Manager.shared.getMediaUrl(name: snippet_intro_video, bucketName: .introVideo)
                            let snippet_intro_video_thumb_path = AWSS3Manager.shared.getMediaUrl(name: snippet_intro_video_thumb, bucketName: .introThumbnail)
                            
                            AWSS3Manager.shared.getSignedUrl(key: snippet_file_path, withSuccess: { snippetFile in
                                snippet.snippetFile = snippetFile
                                
                                AWSS3Manager.shared.getSignedUrl(key: snippet_thumb_path, withSuccess: { snippetThumb in
                                    snippet.snippetThumb = snippetThumb
                                    
                                    AWSS3Manager.shared.getSignedUrl(key: snippet_intro_video_path, withSuccess: { introVideo in
                                        snippet.introductionVideo = introVideo
                                        
                                        AWSS3Manager.shared.getSignedUrl(key: snippet_intro_video_thumb_path, withSuccess: { introVideoThumb in
                                            snippet.introductionVideoThumb = introVideoThumb
                                            
                                            getSnippetListModel.data![index] = snippet
                                        })
                                    })
                                })
                            })
                        }
                    }
                }
                
                success(getSnippetListModel, getSnippetListModel.message ?? "")
                Indicator.hide()
            } catch let error {
                print(error.localizedDescription)
                
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
    
    /// `api call` for delete snippet
    static func deleteSnippet(params: [String: Any], success: @escaping () -> (), failure: @escaping (String) -> Void) -> Void {
        /// `api call` for Deleting Snippet
        APIManager.makeRequest(with: Constant.ServerAPI.kDeleteSnippet, method: .post, parameter: params, success: { response -> Void in
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
    
    /// `api call` for snippet permission
    static func getSnippetPermission(success: @escaping (GetSnippetPermissionModel?, String) -> Void, failure: @escaping (String) -> Void) -> Void {
        Indicator.show()
        
        APIManager.makeRequest(with: Constant.ServerAPI.kGetSnippetPermission, method: .get, parameter: nil, success: { response -> Void in
            guard let json = response as? [String: Any] else { return }
            guard let data = try? JSONSerialization.data(withJSONObject: json) else { return }
            
            do {
                let getSnippetModel = try JSONDecoder().decode(GetSnippetPermissionModel.self, from: data)

                success(getSnippetModel, getSnippetModel.message ?? "")
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
}

