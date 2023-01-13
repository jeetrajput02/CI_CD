//
//  FollowersViewModel.swift
//  WhosNext
//
//  Created by differenz195 on 14/10/22.
//

import SwiftUI

public class FollowersViewModel: ObservableObject {
    // MARK: - Variables
    @Published var followerModel: UserFollowersListModel? = nil
    @Published var followRequestList: [FollowRequestData] = []

    @Published var searchText: String = ""

    @Published var showFollowunFollowActionSheet: Bool = false

    @Published var navigationLink: String? = nil

    @Published var moveToFollowers: Bool = false
    @Published var moveToProfile: Bool = false
    
    @Published var userId: Int = -1
    @Published var selectedUser: UserFollowersListData? = nil
    
    @Published var errorMsg = ""
    @Published var showError = false
}

// MARK: - Functions
extension FollowersViewModel {
    func onBtnFollowers_Click() -> Void {
        self.moveToFollowers = true
    }
}

// MARK: - API Calls
extension FollowersViewModel {
    /// `api call` for get the followers of the user
    func getUserFollowersList() -> Void {
        guard let currentUser = UserDefaults.getData(UserDefaultsKey.kLoginUser, data: UserModel.self) else { return }
        
        let param = [ProfileModelKey.user_id: self.userId == -1 ? currentUser.userId : self.userId] as [String: Any]
        
        UserFollowersListModel.getUserFollowersList(params: param, success: { response, message -> Void in
            guard let model = response else { return }
            
            self.followerModel = model
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }
    
    /// `api call` for getting the list of follower's request
    func getFollowRequestList() -> Void {
        FollowRequestModel.getFollowRequestList(success: { response, message -> Void in
            guard let followRequestList = response?.data else { return }
            
            self.followRequestList = followRequestList
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }
    
    /// `api call` for follow/unfollow user
    func followUnfollowUser(userId: Int, completion: @escaping () -> Void) -> Void {
        let param = [ProfileModelKey.user_id: "\(userId)"] as [String: Any]
        
        ProfileModel.followunFollowUser(param: param, success: {
            completion()
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }
    
    /// `api call` for Accept & Reject Request
    func acceptRejectRequestApi(userID: String, followType: String, completion: @escaping () -> Void) -> Void {
        let param = [
            "user_id": userID,
            "follow_status" : followType
        ] as [String: Any]
        
        NotificationModel.acceptRejectRequest(params: param, success: {
            completion()
            Indicator.hide()
        }, failure: { error -> Void in
            
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }
}
