//
//  HomeViewModel.swift
//  WhosNext
//
//  Created by differenz195 on 03/10/22.
//

import SwiftUI

class HomeViewModel: ObservableObject {
    // MARK: - Variables
    @Published var homeScreenModel: HomeScreenModel? = nil
    @Published var posts: [HomePostData] = []
    
    @Published var postDetailModel: PostDetailModel? = nil
    @Published var selectedPost: HomePostData? = nil
    @Published var notificationModel: NotificationModel? = nil
    
    @Published var reportReasonsModel: ReportReasonModel? = nil
    @Published var selectedReportReason: ReportReasonData? = nil
    
    @Published var updatedCommentPostId: Int = 0
    @Published var isCommentUpdated: Bool = false
    @Published var currentPostID: Int = 0
    @Published var scrollPostId: Int = 0
    @Published var badgeCount: Int = 0
    @Published var currentpage: Int = 1
    @Published var nextpage: Int = 0
    var cPage: Int = 0
    
    @Published var moveToProfile: Bool = false
    @Published var moveToNotification: Bool = false
    @Published var moveToShareScreen: Bool = false
    @Published var isSideBarOpened: Bool = false
    @Published var showReportSheet: Bool = false
    @Published var videoUrl: String = ""
    @Published var userID: Int = 0
    @Published var userFullName: String = ""
    @Published var postId: Int = 0
    @Published var videoSheet: Bool = false
    @Published var showDetailVideo: Bool = false
    @Published var isMoreBtnSheet: Bool = false
    @Published var isShowControls: Bool = true
    @Published var isShowMuteBtn: Bool = true
    @Published var moveToComments: Bool = false
    @Published var index = 0
    @Published var isAnimating = true
    @Published var remainingTimeSeconds: String = "00"
    @Published var remainingTimeMinutes: String = "00"
    
    @Published var x: CGFloat = 0
    @Published var count: Double = 1
    @Published var screen = UIScreen.main.bounds.width - 80
    @Published var movalble_X: CGFloat = 18
    @Published var navigateToImageView: Bool = false
    @Published var navigateToAudioView: Bool = false
    @Published var navigateToAllSnippetView: Bool = false
    @Published var currentSnippetData: HomeSinppetData = HomeSinppetData()
    @Published var fileURL = ""
    @Published var scale: Double = 0.5
    @Published var timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    @Published var errorMsg: String = ""
    @Published var showError: Bool = false
    @Published var appeared: Bool = true
    @Published var viewAppeared: Bool = true
    @Published var videoViewAppeared: Bool = true
    @Published var counterOfVideoPlaying: Int = 1
    @Published var mySnippetMultiArray: [[HomeSinppetData]] = []
    @Published var myCount: Int = 0
    @Published var postIDForSnippet: [Int] = []
    @Published var isLoaded: Bool = true
    
    @Published var isMoveToID: Bool = false
    @Published var postIDToMove: Int = 0
    @Published var scrollViewDisabled: Bool = false
}

// MARK: - Functions
extension HomeViewModel {
    /// `get current page`
    func getCurrentPage() -> Int {
        var currentPage: Int = 0
        
        for idx in 0 ..< self.posts.count {
            if self.currentPostID == self.posts[idx].postID {
                currentPage = ((idx + 2) / 10) + 1
                
                return currentPage
            }
        }
        
        return currentPage
    }
}

// MARK: - API Calls
extension HomeViewModel {
    /// `api call` for home screen data
    func getHomeScreenData() -> Void {
        let params = ["page": self.currentpage, "nextpage" : "\(self.nextpage)"] as [String: Any]
        
        self.isLoaded = false
        
        HomeScreenModel.getHomeScreenData(params: params, showLoader: self.currentpage == 1, success: { response, message -> Void in
            guard let model = response else { return }
            
            self.nextpage = model.data?.nextpage ?? 0
            self.postIDToMove = model.data?.post?.first?.postID ?? 0
            self.mySnippetMultiArray.append(model.data?.sinppet ?? [])
            
            if self.cPage < self.mySnippetMultiArray.count && self.mySnippetMultiArray[self.cPage].count != (model.data?.sinppet?.count ?? 0) + 2 {
                if self.mySnippetMultiArray[self.cPage].count > 1 {
                    let firstElement = self.mySnippetMultiArray[self.cPage].first
                    let lastElement = self.mySnippetMultiArray[self.cPage].last
                    self.mySnippetMultiArray[self.cPage].insert(lastElement!, at: 0)
                    self.mySnippetMultiArray[self.cPage].append(firstElement!)
                }
            }
            
            if self.currentpage == 1 {
                self.postIDForSnippet = []
                self.homeScreenModel = model
                
                guard let posts = self.homeScreenModel?.data?.post else { return }
                self.posts = posts
                
                for i in 0 ..< (self.homeScreenModel?.data?.post?.count ?? 0){
                    if ((i + 1) % 10 == 0) {
                        self.postIDForSnippet.append(self.posts[i].postID!)
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    self.isMoveToID = true
                    Indicator.hide()
                })
                
                self.isLoaded = true
            } else {
                self.homeScreenModel?.data?.nextpage = model.data?.nextpage

                guard let posts = model.data?.post else { return }
                self.homeScreenModel?.data?.post?.append(contentsOf: model.data?.post ?? [])
                self.posts.append(contentsOf: posts)
                
                self.postIDForSnippet = []
                
                for i in 0 ..< (self.posts.count) {
                    if ((i + 1) % 10 == 0) {
                        self.postIDForSnippet.append(self.posts[i].postID!)
                    }
                }
                
                guard let snippets = model.data?.sinppet else { return }
                self.homeScreenModel?.data?.sinppet?.append(contentsOf: snippets)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    self.isMoveToID = true
                    Indicator.hide()
                })

                self.isLoaded = true
            }
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
        
        // self.isLoaded = true
    }
    
    /// `api call` for pagination in home screen api
    func loadMoreHomeScreenData(currentPost post: HomePostData) {
        guard let posts = self.homeScreenModel?.data?.post, posts.count >= (self.currentpage * 10), post.postID == self.posts.last?.postID else { return }
        
        if (self.homeScreenModel?.totalCount ?? 0) > posts.count {
            if self.homeScreenModel?.data?.post?.last?.postID == post.postID {
                DispatchQueue.main.async(execute: {
                    self.isLoaded = false
                    self.cPage += 1
                })
                
                self.currentpage += 1
                self.getHomeScreenData()
                
                self.isLoaded = true
            }
        }
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
    
    /// `api call` for post view count
    func postViewCountApi(postID: String, viewType: String, completion: @escaping () -> Void) -> Void {
        let param = [PostModelKey.id: postID, PostModelKey.viewType: viewType] as [String: Any]
        
        PostModel.postViewCount(params: param, success: {
            completion()
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            Alert.show(title: "", message: error)
        })
    }
    /// `api call` for post report
    func notificationBadgeCountApi(completion: @escaping (NotificationBadgeModel) -> Void) -> Void {
        HomeScreenModel.notificationBadgeCount(success: { model, message in
            completion(model!)
            Indicator.hide()
        }, failure: { error -> Void in
            
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }
    
    /// `api call` for post report
    func postReport(postID: String, reasonID: String, completion: @escaping () -> Void) -> Void {
        let param = [
            PostModelKey.postID: postID,
            PostModelKey.reasonID: reasonID
        ] as [String: Any]
        
        PostModel.postReport(params: param, success: {
            completion()
            Indicator.hide()
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

    /// `api call` for get report reason
    func getReportReasons() -> Void {
        ReportReasonModel.getReportReasons { response, message -> Void in
            self.reportReasonsModel = response
        } failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        }
    }
    
    /// `update snippet array`
    func updateSnippetArray(array : [HomeSinppetData]) -> [HomeSinppetData] {
        var newArray = array
        let firstElement = array.first
        let lastElement = array.last
        
        newArray.insert(lastElement!, at: 0)
        newArray.append(firstElement!)
        print("========================================\n\n\n================================")
        print(newArray)
        
        return newArray
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
            }
        }
    }
}
