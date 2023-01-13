//
//  PostViewModel.swift
//  WhosNext
//
//  Created by differenz195 on 17/11/22.
//

import SwiftUI
import AVKit

class PostViewModel: ObservableObject {
    // MARK: - Variables
    @Published var arrImage: GridPostModel? = nil
    @Published var postDetailModel: PostDetailModel? = nil
    @Published var userProfilePostList: UserProfilePostListModel? = nil
    @Published var posts: [UserProfilePostListData] = []
    @Published var selectedPost: UserProfilePostListData? = nil

    @Published var updatedCommentPostId: Int = 0
    @Published var isCommentUpdated: Bool = false

    @Published var userId: Int = -1

    @Published var videoUrl: String = ""
    @Published var moveToProfile: Bool = false
    @Published var moveToComments: Bool = false
    @Published var moveToShareScreen: Bool = false

    @Published var isShowMuteBtn: Bool = true
    @Published var likeValue:Int = 0
    @Published var isMoreBtnSheet: Bool = false
    @Published var videoSheet: Bool = false
    @Published var userID: Int = 0
    @Published var userFullName: String = ""
    @Published var postId: Int = 0
    @Published var viewAppeared: Bool = true

    @Published var groupShowsControls = false
    @Published var groupVideoGravity: AVLayerVideoGravity = .resizeAspectFill
    @Published var groupLoop = true
    @Published var groupIsMuted = false
    @Published var groupIsPlaying: Bool = false
    @Published var groupStartVideoSeconds:Double = 0.0
    @Published var groupBackInSeconds:Double = 0.0
    @Published var groupForwardInSeconds:Double = 0.0
    @Published var groupLastPlayInSeconds:Double = 0.0
    @Published var groupShow = false
    @Published var groupCounter: Int = 0
    @Published var groupURLArray: [URL] = []
    @Published var groupThumbnailURL:[URL] = []
    @Published var muteBtnOpacity: Int = 1

    @Published var errorMsg = ""
    @Published var showError = false
}

// MARK: - API Call
extension PostViewModel {
    /// `api call` for Grid post view
    func gridPostApi(type: String, completion: @escaping () -> Void) -> Void {
        let param = [
            GridPostModelKey.type: type
        ] as [String: Any]
        
        GridPostModel.gridPostApi(params: param, success: { response, message -> Void in
            self.arrImage = response
            
            completion()
            Indicator.hide()
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }
    
    /// `api call` for post like
    func postLike(postID: String, completion: @escaping () -> Void) -> Void {
        let param = [PostModelKey.postID: postID] as [String: Any]
        
        PostModel.postLike(params: param, success: { () -> Void in
            completion()
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }
    
    /// `api call` for post Delete
    func postDelete(postID: String, completion: @escaping () -> Void) -> Void {
        let param = [PostModelKey.postID: postID] as [String: Any]
        
        PostModel.postDelete(params: param, success: {
            completion()
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }
    
    /// `api call` for post report
    func postReport(postID: String, completion: @escaping () -> Void) -> Void {
        let param = [PostModelKey.postID: postID] as [String: Any]
        
        PostModel.postReport(params: param, success: {
            completion()
            Indicator.hide()
        }, failure: { error -> Void in
            
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }
    
    /// `api call` for  post detail view
    func postDetails(postID: String, completion: @escaping () -> Void) -> Void {
        let param = [PostModelKey.postID: postID] as [String: Any]
        
        PostDetailModel.postDetails(params: param, success: { response, message -> Void in
            guard let postDetailModel = response else { return }
            
            self.postDetailModel = postDetailModel
            completion()
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }
    
    /// `api call` for post list of user
    func getPostListForUsers() -> Void {
        guard let currentUser = UserDefaults.getData(UserDefaultsKey.kLoginUser, data: UserModel.self) else { return }
        
        let param = [ProfileModelKey.user_id: self.userId == -1 ? currentUser.userId : self.userId] as [String: Any]
        
        UserProfilePostListModel.getPostListForUsers(params: param, success: { response, message -> Void in
            guard let model = response else { return }
            
            self.userProfilePostList = model
            
            guard let posts = model.data else { return }
            self.posts = posts
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }
    
    /// `api call` for post view count
    func postViewCountApi(postID: String, viewType: String, completion: @escaping () -> Void) -> Void {
        let param = [PostModelKey.id: postID, PostModelKey.viewType: viewType] as [String: Any]
        PostModel.postViewCount(params: param, success: {
            completion()
            Indicator.hide()
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            Alert.show(title: "", message: error)
        })
    }
    
    /// `update post data`
    func updatePostData() -> Void {
        if self.selectedPost != nil {
            self.postDetails(postID: "\(self.selectedPost?.postID ?? 0)") {
                guard let newPost = self.postDetailModel?.data else { return }
                
                for idx in 0 ..< self.posts.count {
                    if self.posts[idx].postID == newPost.postID {
                        self.posts[idx].postID = newPost.postID
                        self.posts[idx].userID = newPost.userID
                        self.posts[idx].postType = newPost.postType
                        self.posts[idx].postSubType = newPost.postSubType
                        self.posts[idx].postURL = newPost.postURL
                        self.posts[idx].postThumbnail = newPost.postThumbnail
                        self.posts[idx].postCaption = newPost.postCaption
                        self.posts[idx].taggedSelectedPeople = newPost.taggedSelectedPeople
                        self.posts[idx].postVisibility = newPost.postVisibility
                        self.posts[idx].postViewCount = newPost.postViewCount
                        self.posts[idx].postHeight = newPost.postHeight
                        self.posts[idx].postWidth = newPost.postWidth
                        self.posts[idx].username = newPost.username
                        self.posts[idx].firstName = newPost.firstName
                        self.posts[idx].lastName = newPost.lastName
                        self.posts[idx].fullName = newPost.fullName
                        self.posts[idx].introductionVideoThumb = newPost.introductionVideoThumb
                        self.posts[idx].introductionVideo = newPost.introductionVideo
                        self.posts[idx].lastModificationTime = newPost.lastModificationTime
                        self.posts[idx].timeDisplayStr = newPost.timeDisplayStr
                        self.posts[idx].isVerified = newPost.isVerified
                        self.posts[idx].postLikeCount = newPost.postLikeCount
                        self.posts[idx].postCommentCount = newPost.postCommentCount
                        self.posts[idx].isOwnLike = newPost.isOwnLike
                        self.posts[idx].isOwnView = newPost.isOwnView
                        self.posts[idx].isOwnPost = newPost.isOwnPost
                        self.posts[idx].taggedSelectedPeopleArr = newPost.taggedSelectedPeopleArr
                        self.posts[idx].postComments = newPost.postComments
                        self.posts[idx].postGroup = newPost.postGroup
                    }
                }
                
                self.selectedPost = nil
                self.postId = 0
            }
        }
    }
}
