//
//  FeaturedProfileViewModel.swift
//  WhosNext
//
//  Created by differenz240 on 07/12/22.
//

import SwiftUI
import AVKit

class FeaturedProfileViewModel: ObservableObject {
    /// `variables`
    @Published var featuredProfileModel: FeaturedProfileModel? = nil
    @Published var featuredProfiles: [FeaturedProfileData] = []
    
    @Published var postDetailModel: PostDetailModel? = nil
    @Published var selectedPost: FeaturedProfileData? = nil
    @Published var currentPage: Int = 1
    
    @Published var reportReasonsModel: ReportReasonModel? = nil
    @Published var selectedReportReason: ReportReasonData? = nil
    @Published var showReportSheet: Bool = false

    @Published var videoUrl: String = ""
    
    @Published var userID: Int = 0
    @Published var userFullName: String = ""
    @Published var postId: Int = 0
    @Published var videoSheet = false
    @Published var isMoreBtnSheet = false
    
    @Published var player: AVPlayer?
    @Published var isShowMuteBtn: Bool = true
    @Published var moveToComments: Bool = false
    @Published var moveToProfile: Bool = false
    
    @Published var isSideBarOpened: Bool = false
    @Published var moveToNotification: Bool = false
    @Published var moveToShareScreen: Bool = false
    
    @Published var updatedCommentPostId: Int = 0
    @Published var isCommentUpdated: Bool = false
    
    @Published var errorMsg: String = ""
    @Published var showError: Bool = false
    
    @Published var appeared: Bool = true
    @Published var viewAppeared: Bool = true
    @Published var videoViewAppeared: Bool = true
}

// MARK: - API Calls
extension FeaturedProfileViewModel {
    /// `api call` for get featured profile
    func getFeaturedProfile() -> Void {
        let params = [
            FeaturedProfileParams.page.rawValue: self.currentPage
        ] as [String: Any]
        
        FeaturedProfileModel.getFeaturedProfile(params: params, success: { response, message -> Void in
            if self.currentPage == 1 {
                self.featuredProfileModel = response
                
                guard let profiles = response?.data else { return }
                self.featuredProfiles = profiles
            } else {
                guard let profiles = response?.data else { return }
                self.featuredProfileModel?.data?.append(contentsOf: profiles)
                self.featuredProfiles.append(contentsOf: profiles)
            }
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }
    
    /// `api call` for pagination in featured profile api
    func loadMoreFeaturedProfiles(currentProfile profile: FeaturedProfileData) -> Void {
        guard let data = self.featuredProfileModel?.data, data.count >= (self.currentPage * 10) else { return }
        
        if (self.featuredProfileModel?.totalCount ?? 0) > data.count {
            if self.featuredProfileModel?.data?.last?.postID == profile.postID {
                self.currentPage += 1
                self.getFeaturedProfile()
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

    /// `update post data`
    func updatePostData() -> Void {
        if self.selectedPost != nil {
            self.postDetails(postID: "\(self.selectedPost?.postID ?? 0)") {
                guard let newPost = self.postDetailModel?.data else { return }
                
                for idx in 0 ..< self.featuredProfiles.count {
                    if self.featuredProfiles[idx].postID == newPost.postID {
                        self.featuredProfiles[idx].postID = newPost.postID
                        self.featuredProfiles[idx].userID = newPost.userID
                        self.featuredProfiles[idx].postType = newPost.postType
                        self.featuredProfiles[idx].postSubType = newPost.postSubType
                        self.featuredProfiles[idx].postURL = newPost.postURL
                        self.featuredProfiles[idx].postThumbnail = newPost.postThumbnail
                        self.featuredProfiles[idx].postCaption = newPost.postCaption
                        self.featuredProfiles[idx].taggedSelectedPeople = newPost.taggedSelectedPeople
                        self.featuredProfiles[idx].postVisibility = newPost.postVisibility
                        self.featuredProfiles[idx].postViewCount = newPost.postViewCount
                        self.featuredProfiles[idx].postHeight = newPost.postHeight
                        self.featuredProfiles[idx].postWidth = newPost.postWidth
                        self.featuredProfiles[idx].username = newPost.username
                        self.featuredProfiles[idx].firstName = newPost.firstName
                        self.featuredProfiles[idx].lastName = newPost.lastName
                        self.featuredProfiles[idx].fullName = newPost.fullName
                        self.featuredProfiles[idx].introductionVideoThumb = newPost.introductionVideoThumb
                        self.featuredProfiles[idx].introductionVideo = newPost.introductionVideo
                        self.featuredProfiles[idx].lastModificationTime = newPost.lastModificationTime
                        self.featuredProfiles[idx].timeDisplayStr = newPost.timeDisplayStr
                        self.featuredProfiles[idx].isVerified = newPost.isVerified
                        self.featuredProfiles[idx].postLikeCount = newPost.postLikeCount
                        self.featuredProfiles[idx].postCommentCount = newPost.postCommentCount
                        self.featuredProfiles[idx].isOwnLike = newPost.isOwnLike
                        self.featuredProfiles[idx].isOwnView = newPost.isOwnView
                        self.featuredProfiles[idx].isOwnPost = newPost.isOwnPost
                        self.featuredProfiles[idx].taggedSelectedPeopleArr = newPost.taggedSelectedPeopleArr
                        self.featuredProfiles[idx].postComments = newPost.postComments
                        self.featuredProfiles[idx].postGroup = newPost.postGroup
                    }
                }
                
                self.selectedPost = nil
            }
        }
    }
}
