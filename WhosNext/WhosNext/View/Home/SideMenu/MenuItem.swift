//
//  MenuItem.swift
//  WhosNext
//
//  Created by differenz195 on 03/10/22.
//

import Foundation

public struct MenuItem: Identifiable, Hashable {
    public var id: Int
    var text: String
    
    /// `normal` user menu
    static func sideMenuItemUsers() -> [MenuItem] {
        var arrNormalUserMenu = [MenuItem]()
        
        arrNormalUserMenu = [MenuItem(id: 0, text: menuItemName.kFeturedProfiles),
                             MenuItem(id: 1, text: menuItemName.kBreastCancerLegacies),
                             MenuItem(id: 2, text: menuItemName.kDiscover),
                             MenuItem(id: 3, text: menuItemName.kHomePage),
                             MenuItem(id: 4, text: menuItemName.kMyProfile),
                             MenuItem(id: 5, text: menuItemName.kMessaging),
                             MenuItem(id: 6, text: menuItemName.kPictures),
                             MenuItem(id: 7, text: menuItemName.kVideos),
                             MenuItem(id: 8, text: menuItemName.kChangePassword),
                             MenuItem(id: 9, text: menuItemName.kAddNewSnippets),
                             MenuItem(id: 10, text: menuItemName.kLogout)]
        
        return arrNormalUserMenu
    }
    
    /// `admin` user menu
    static func sideMenuItemsAdmin() -> [MenuItem] {
        var arrAdminUser = [MenuItem]()
        
        arrAdminUser =  [MenuItem(id: 0, text: menuItemName.kFeturedProfiles),
                         MenuItem(id: 1, text: menuItemName.kBreastCancerLegacies),
                         MenuItem(id: 2, text: menuItemName.kDiscover),
                         MenuItem(id: 3, text: menuItemName.kHomePage),
                         MenuItem(id: 4, text: menuItemName.kMyProfile),
                         MenuItem(id: 5, text: menuItemName.kMessaging),
                         MenuItem(id: 6, text: menuItemName.kSendPushNotification),
                         MenuItem(id: 7, text: menuItemName.kPictures),
                         MenuItem(id: 8, text: menuItemName.kVideos),
                         MenuItem(id: 9, text: menuItemName.kChangePassword),
                         MenuItem(id: 10, text: menuItemName.kCity),
                         MenuItem(id: 11, text: menuItemName.kCategory),
                         MenuItem(id: 12, text: menuItemName.kAddNewSnippets),
                         MenuItem(id: 13, text: menuItemName.kSnippetsList),
                         MenuItem(id: 14, text: menuItemName.kSnippetsUploadAccess),
                         MenuItem(id: 15, text: menuItemName.kLogout)]
        
        return arrAdminUser
    }
}

/// `names` of menu items
enum menuItemName {
    static let kFeturedProfiles = "Fetured Profiles"
    static let kBreastCancerLegacies = "Breast Cancer Legacies"
    static let kDiscover = "Discover"
    static let kHomePage = "Home Page"
    static let kMyProfile = "My Profile"
    static let kMessaging = "Messaging"
    static let kSendPushNotification = "Send Push Notification"
    static let kPictures = "Pictures"
    static let kVideos = "Videos"
    static let kChangePassword = "Change Password"
    static let kAddNewSnippets = "Add New Snippets"
    static let kCity = "City"
    static let kCategory = "Category"
    static let kSnippetsList = "Snippets List"
    static let kSnippetsUploadAccess = "Snippets Upload Access Request"
    static let kLogout = "Logout"
}
