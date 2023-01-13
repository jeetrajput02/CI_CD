//
//  ShareToViewModel.swift
//  WhosNext
//
//  Created by differenz195 on 01/11/22.
//

import SwiftUI
import AVKit

enum ShareToViewFocusState: Equatable, Hashable {
    case caption
    case none
}

enum ShareToViewPicketType { case image, video, none }

public class ShareToViewModel: ObservableObject {
    // MARK: - Variables
    @Published var navigationLink: String? = nil
    @Published var moveToShareScreen: Bool = false
    @Published var moveToGroupVideo: Bool = false
    @Published var moveToSelectPeople: Bool = false
    @Published var allUserListModel: AllUserListModel? = nil
    @Published var selectedUser: AllUserListData? = nil
    @Published var postModel: PostModel?
    
    @Published var pickerType: ShareToViewPicketType = .none
    @Published var showPicker: Bool = false
    @Published var isShowVideos: Bool = false
    @Published var shouldPresentImagePicker: Bool = false
    @Published var isPresentCamera: Bool = false
    @Published var videoURL: URL? = nil
    @Published var image: UIImage? = nil
    @Published var arrImage: [UIImage] = []
    @Published var postType: Int = 0
    @Published var mediaSelected: Bool = false
    
    @Published var imageURL: URL? = nil
    @Published var imageRemote: String = ""
    
    @Published var videoUrl: URL? = nil
    @Published var videoRemote: String = ""
    @Published var videoThumbRemote: String = ""

    @Published var isUploading: Bool = false
    @Published var progress: Float = 0.0

    @Published var errorMsg = ""
    @Published var showError = false
    
    @Published var postHeight: Double = 0.0
    @Published var postWidth: Double = 0.0
}

// MARK: - Functions
extension ShareToViewModel {
    /// `move` tom share view
    func onBtnShare_Click() {
        self.moveToShareScreen = true
    }
}

// MARK: - Api Call
extension ShareToViewModel {
    /// `api call` for get the allUserList
    func getAllUserList(completion: @escaping (AllUserListModel?) -> Void) -> Void {
        AllUserListModel.getAllUserList(success: { allUserListModel, message -> Void in
            self.allUserListModel = allUserListModel
            
            completion(self.allUserListModel)
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }

    /// `api call` for user `create the post with image`
    func createPostWithImage(postID: String, postType: Int, postSubType: Int, postCaption: String, taggedSelectedPeople: String, completion: @escaping () -> Void) -> Void {
        // Indicator.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
            withAnimation {
                self.progress = 10.0
            }
        })

        AWSS3Manager.shared.uploadImage(image: self.image ?? UIImage(), bucketname: .postImage, withSuccess: { success, thumbName -> Void in
            guard let imageName = thumbName.split(separator: "/").last else { return }
            self.imageRemote = String(imageName)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
                withAnimation {
                    self.progress = 70.0
                }
            })

            let param = [
                PostModelKey.postID: postID,
                PostModelKey.postType: postType,
                PostModelKey.postSubType : postSubType,
                PostModelKey.postUrl: self.imageRemote,
                PostModelKey.postThumbnail: self.imageRemote,
                PostModelKey.postCaption: postCaption,
                PostModelKey.taggedSelectedPeople: taggedSelectedPeople,
                PostModelKey.post_width: self.image?.size.width ?? 0 ,
                PostModelKey.post_height: self.image?.size.height ?? 0
            ] as [String: Any]
            
            PostModel.createUpdatePost(params: param,success: { response, message -> Void in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
                    withAnimation {
                        self.progress = 100.0
                    }
                })

                completion()
                Indicator.hide()
            }, failure: { error -> Void in
                
                self.errorMsg = error
                self.showError = true
                
                Alert.show(title: "", message: error)
            })
        }, failure: { error -> Void in
            Indicator.hide()
        }, connectionFail: { error -> Void in
            Indicator.hide()
        })
    }
    
    /// `api call` for user `create the post with video`
    func createPostWithVideo(postID: String, postType: Int, postSubType: Int, postCaption: String, taggedSelectedPeople: String, taggedSelectedPeopleInGroupVideo: String, completion: @escaping () -> Void) -> Void {
        // Indicator.show()
        
        guard let videoURL = self.videoUrl else { return }
        let videoResolution = Utilities.getWidthHeightOfVideo(with: videoURL)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
            withAnimation {
                self.progress = 10.0
            }
        })

        AWSS3Manager.shared.uploadVideo(video: videoURL, bucketname: .postVideo, withSuccess: { fileUrl, remoteName -> Void in
            guard let videoName = remoteName.split(separator: "/").last else { return }
            self.videoRemote = String(videoName)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
                withAnimation {
                    self.progress = 40.0
                }
            })

            guard let image =  Utilities.getThumbnailImage(forUrl: videoURL) else { return }
            
            AWSS3Manager.shared.uploadImage(image: image, bucketname: .postVideoThumb, withSuccess: {
                (fileURL, thumbnail) in
                guard let thumbnailName = thumbnail.split(separator: "/").last else { return }
                self.videoThumbRemote = String(thumbnailName)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
                    withAnimation {
                        self.progress = 70.0
                    }
                })

                let param = [
                    PostModelKey.postID: postID,
                    PostModelKey.postType: postType,
                    PostModelKey.postSubType : postSubType,
                    PostModelKey.postUrl: self.videoRemote,
                    PostModelKey.postThumbnail: self.videoThumbRemote,
                    PostModelKey.postCaption: postCaption,
                    PostModelKey.taggedSelectedPeople: taggedSelectedPeople,
                    PostModelKey.taggedSelectedPeopleInGroupVideo: taggedSelectedPeopleInGroupVideo,
                    PostModelKey.post_width: String(videoResolution.first ?? 0.0) ,
                    PostModelKey.post_height: String(videoResolution.last ?? 0.0)
                ] as [String: Any]
                
                PostModel.createUpdatePost(params: param,success: { response, message -> Void in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
                        withAnimation {
                            self.progress = 100.0
                        }
                    })

                    completion()
                    Indicator.hide()
                }, failure: { error -> Void in
                    self.errorMsg = error
                    self.showError = true
                    
                    Alert.show(title: "", message: error)
                })
            }, failure: { (error) in
                Indicator.hide()
            }, connectionFail: {(error) in
                Indicator.hide()
            })
        }, failure: { error -> Void in
            Indicator.hide()
        }, connectionFail: { error -> Void in
            Indicator.hide()
        })
    }
    
    /// `api call` for user `update the post with image`
    func updatePostWithImage(postID: String, postType: Int, postSubType: Int, postCaption: String, taggedSelectedPeople: String, taggedSelectedPeopleInGroupVideo: String, deleteImageName: String, completion: @escaping () -> Void) -> Void {
        // Indicator.show()
        
        if self.image == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
                withAnimation {
                    self.progress = 30.0
                }
            })

            self.imageRemote = deleteImageName

            let param = [
                PostModelKey.postID: postID,
                PostModelKey.postType: postType,
                PostModelKey.postSubType : postSubType,
                PostModelKey.postUrl: self.imageRemote,
                PostModelKey.postThumbnail: self.imageRemote,
                PostModelKey.postCaption: postCaption,
                PostModelKey.taggedSelectedPeople: taggedSelectedPeople,
                PostModelKey.taggedSelectedPeopleInGroupVideo: taggedSelectedPeopleInGroupVideo,
                PostModelKey.post_width: self.postWidth,
                PostModelKey.post_height: self.postHeight
            ] as [String: Any]
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
                withAnimation {
                    self.progress = 70.0
                }
            })

            PostModel.createUpdatePost(params: param,success: { response, message -> Void in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
                    withAnimation {
                        self.progress = 100.0
                    }
                })

                completion()
                Indicator.hide()
            }, failure: { error -> Void in
                self.errorMsg = error
                self.showError = true
                
                Alert.show(title: "", message: error)
            })
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
                withAnimation {
                    self.progress = 10.0
                }
            })

            AWSS3Manager.shared.deleteMedia(fileName: deleteImageName, bucket: .postImage, withSuccess: { message -> Void in
                print("deleted \(deleteImageName) successfully from aws s3.")
                
                // Indicator.show()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
                    withAnimation {
                        self.progress = 20.0
                    }
                })

                AWSS3Manager.shared.uploadImage(image: self.image ?? UIImage(), bucketname: .postImage, withSuccess: { success, thumbName -> Void in
                    guard let imageName = thumbName.split(separator: "/").last else { return }
                    self.imageRemote = String(imageName)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
                        withAnimation {
                            self.progress = 70.0
                        }
                    })

                    let param = [
                        PostModelKey.postID: postID,
                        PostModelKey.postType: postType,
                        PostModelKey.postSubType : postSubType,
                        PostModelKey.postUrl: self.imageRemote,
                        PostModelKey.postThumbnail: self.imageRemote,
                        PostModelKey.postCaption: postCaption,
                        PostModelKey.taggedSelectedPeople: taggedSelectedPeople,
                        PostModelKey.post_width: self.image?.size.width ?? 0 ,
                        PostModelKey.post_height: self.image?.size.height ?? 0
                    ] as [String: Any]
                    
                    PostModel.createUpdatePost(params: param,success: { response, message -> Void in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
                            withAnimation {
                                self.progress = 100.0
                            }
                        })

                        completion()
                        Indicator.hide()
                    }, failure: { error -> Void in
                        self.errorMsg = error
                        self.showError = true
                        
                        Alert.show(title: "", message: error)
                    })
                }, failure: { error -> Void in
                    Indicator.hide()
                }, connectionFail: { error -> Void in
                    Indicator.hide()
                })
            }, failure: { error -> Void in
                Indicator.hide()
            })
        }
    }
    
    /// `api call` for user `update the post with video`
    func updatePostWithVideo(postID: String, postType: Int, postSubType: Int, postCaption: String, taggedSelectedPeople: String, deleteVideoName: String, deleteVideoThumbName: String, completion: @escaping () -> Void) -> Void {
        Indicator.show()
        
        if self.videoURL == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
                withAnimation {
                    self.progress = 30.0
                }
            })

            self.videoRemote = deleteVideoName
            self.videoThumbRemote = deleteVideoThumbName

            let param = [
                PostModelKey.postID: postID,
                PostModelKey.postType: postType,
                PostModelKey.postSubType : postSubType,
                PostModelKey.postUrl: self.videoRemote,
                PostModelKey.postThumbnail: self.videoThumbRemote,
                PostModelKey.postCaption: postCaption,
                PostModelKey.taggedSelectedPeople: taggedSelectedPeople,
                PostModelKey.post_width: self.postWidth,
                PostModelKey.post_height: self.postHeight
            ] as [String: Any]
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
                withAnimation {
                    self.progress = 70.0
                }
            })

            PostModel.createUpdatePost(params: param, success: { response, message -> Void in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
                    withAnimation {
                        self.progress = 100.0
                    }
                })

                completion()
                Indicator.hide()
            }, failure: { error -> Void in
                self.errorMsg = error
                self.showError = true
                
                Alert.show(title: "", message: error)
            })
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
                withAnimation {
                    self.progress = 10.0
                }
            })

            AWSS3Manager.shared.deleteMedia(fileName: deleteVideoName, bucket: .postVideo, withSuccess: { message -> Void in
                print("deleted \(deleteVideoName) successfully from aws s3.")
                
                // Indicator.show()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
                    withAnimation {
                        self.progress = 15.0
                    }
                })

                AWSS3Manager.shared.deleteMedia(fileName: deleteVideoThumbName, bucket: .postVideoThumb, withSuccess: { message -> Void in
                    print("deleted \(deleteVideoThumbName) successfully from aws s3.")
                    
                    guard let videoURL = self.videoURL else { return }

                    // Indicator.show()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
                        withAnimation {
                            self.progress = 20.0
                        }
                    })
                 
                    AWSS3Manager.shared.uploadVideo(video: videoURL, bucketname: .postVideo, withSuccess: { fileUrl, remoteName -> Void in
                        guard let videoName = remoteName.split(separator: "/").last else { return }
                        self.videoRemote = String(videoName)
                        
                        guard let image =  Utilities.getThumbnailImage(forUrl: videoURL) else { return }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
                            withAnimation {
                                self.progress = 55.0
                            }
                        })

                        AWSS3Manager.shared.uploadImage(image: image, bucketname: .postVideoThumb, withSuccess: { fileURL, thumbnail -> Void in
                            guard let thumbnailName = thumbnail.split(separator: "/").last else { return }
                            self.videoThumbRemote = String(thumbnailName)
                            
                            let videoResolution = Utilities.getWidthHeightOfVideo(with: videoURL)

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
                                withAnimation {
                                    self.progress = 70.0
                                }
                            })

                            let param = [
                                PostModelKey.postID: postID,
                                PostModelKey.postType: postType,
                                PostModelKey.postSubType : postSubType,
                                PostModelKey.postUrl: self.videoRemote,
                                PostModelKey.postThumbnail: self.videoThumbRemote,
                                PostModelKey.postCaption: postCaption,
                                PostModelKey.taggedSelectedPeople: taggedSelectedPeople,
                                PostModelKey.post_width: String(videoResolution.first ?? 0.0) ,
                                PostModelKey.post_height: String(videoResolution.last ?? 0.0)
                            ] as [String: Any]
                            
                            PostModel.createUpdatePost(params: param,success: { response, message -> Void in
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
                                    withAnimation {
                                        self.progress = 100.0
                                    }
                                })

                                completion()
                                Indicator.hide()
                            }, failure: { error -> Void in
                                self.errorMsg = error
                                self.showError = true
                                
                                Alert.show(title: "", message: error)
                            })
                        }, failure: { error -> Void in
                            Indicator.hide()
                        }, connectionFail: { error -> Void in
                            Indicator.hide()
                        })
                    }, failure: { error -> Void in
                        Indicator.hide()
                    }, connectionFail: { error -> Void in
                        Indicator.hide()
                    })
                }, failure: { error -> Void in
                    Indicator.hide()
                })
            }, failure: { error -> Void in
                Indicator.hide()
            })
        }
    }
}
