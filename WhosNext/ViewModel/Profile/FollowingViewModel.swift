//
//  FollowingViewModel.swift
//  WhosNext
//
//  Created by differenz195 on 17/10/22.
//

import SwiftUI

public class FollowingViewModel: ObservableObject {
    // MARK: - Variables
    @Published var followingModel: UserFollowingListModel? = nil
    @Published var searchText: String = ""
    
    @Published var showFollowunFollowActionSheet: Bool = false
    
    @Published var navigationLink: String? = nil

    @Published var moveToFollowing: Bool = false
    @Published var moveToProfile: Bool = false
    
    @Published var userId: Int = -1
    @Published var selectedUser: UserFollowingListData? = nil

    @Published var errorMsg = ""
    @Published var showError = false
}

// MARK: - Functions
extension FollowingViewModel {
    func onBtnFollowing_Click() -> Void {
        self.moveToFollowing = true
    }
}

// MARK: - API Calls
extension FollowingViewModel {
    /// `api call` for get the followings of the user
    func getUserFollowingList() -> Void {
        guard let currentUser = UserDefaults.getData(UserDefaultsKey.kLoginUser, data: UserModel.self) else { return }
        
        let param = [ProfileModelKey.user_id: self.userId == -1 ? currentUser.userId : self.userId] as [String: Any]
        
        UserFollowingListModel.getUserFollowingList(param: param, success: { response, message -> Void in
            guard let model = response else { return }
            
            self.followingModel = model
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
}
