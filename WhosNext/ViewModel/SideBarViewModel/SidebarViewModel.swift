//
//  SidebarViewModel.swift
//  WhosNext
//
//  Created by differenz195 on 13/10/22.
//

import SwiftUI

public class SidebarViewModel: ObservableObject {
    @Published var snippetData: GetSnippetPermissionModel = GetSnippetPermissionModel()

    @Published var navigationLink: String? = ""
    @Published var isShowAlert = false
    @Published var moveToLogin: Bool = false
    
    @Published var errorMsg: String = ""
    @Published var showError: Bool = false
}

// MARK: - API Calls
extension SidebarViewModel {
    /// `api call` for snippet permission
    func getSnippetPermissionApi(completion: @escaping () -> Void) -> Void {
        GetSnippetListModel.getSnippetPermission(success: { response, message -> Void in
            guard let model = response else { return }
            self.snippetData = model

            completion()            
            Indicator.hide()
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }
}

// MARK: - Helper Methods
extension SidebarViewModel {
    func moveToView() -> Void {
        switch sideMenuGlobalVariable {
            case menuItemName.kFeturedProfiles:
                self.navigationLink = menuItemName.kFeturedProfiles
            case menuItemName.kBreastCancerLegacies:
                self.navigationLink = menuItemName.kBreastCancerLegacies
            case menuItemName.kDiscover:
                self.navigationLink = menuItemName.kDiscover
            case menuItemName.kHomePage:
                self.navigationLink = menuItemName.kHomePage
            case menuItemName.kMyProfile:
                self.navigationLink = menuItemName.kMyProfile
            case menuItemName.kMessaging:
                self.navigationLink = menuItemName.kMessaging
            case menuItemName.kSendPushNotification:
                self.navigationLink = menuItemName.kSendPushNotification
            case menuItemName.kPictures:
                self.navigationLink = menuItemName.kPictures
            case menuItemName.kVideos:
                self.navigationLink = menuItemName.kVideos
            case menuItemName.kChangePassword:
                self.navigationLink = menuItemName.kChangePassword
            case menuItemName.kCity:
                self.navigationLink = menuItemName.kCity
            case menuItemName.kCategory:
                self.navigationLink = menuItemName.kCategory
            case menuItemName.kAddNewSnippets:
                self.navigationLink = menuItemName.kAddNewSnippets
            case menuItemName.kSnippetsList:
                self.navigationLink = menuItemName.kSnippetsList
            case menuItemName.kSnippetsUploadAccess:
                self.navigationLink = menuItemName.kSnippetsUploadAccess
            case menuItemName.kLogout:
                self.navigationLink = menuItemName.kLogout
            default:
                break
        }
    }

    /// `logout`
    func logout() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.kLoginUser)
        self.moveToLogin = true
    }
}
