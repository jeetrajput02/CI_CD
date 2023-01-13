//
//  Constant.swift
//  WhosNext
//
//  Created by Pooja Gandhi on 12/07/22.
//

import SwiftUI
import WebKit

//MARK: - UserDefaults Key
struct UserDefaultsKey {
    static let kAuthToken                          = "Token"
    static let kLoginUser                          = "loginUser"
    static let kIsAlreadyLogin                     = "AlreadyLogin"
    static let kIsLogout                           = "Logout"
    static let kDeviceToken                        = "device_token"
}

/// `AWS `
struct AWS {
    static let secretkey                           =  "q8a5yUovkHcI2ZsLUX70gsprrhs+oJie4RKof1Yn"
    static let accesskey                           =  "AKIA47WRPVGYLI6C4K5A"
}

// MARK: - Constant
class Constant {
    /// `header constants`
    static let content_type                         = "Content-Type"
    static let Authorization                        = "Authorization"
    
    /// `api constants`
    struct ServerAPI {
        /// `[base_url]`
        ///     - `dev`: "http://192.168.1.131/WhosNext/api/"
        ///     - `live`: "http://52.32.87.210/api/"
        
        static let BASE_URL                         =  "http://52.32.87.210/api/"
//         static let BASE_URL                         =  "http://192.168.1.131/WhosNext/api/"
        
        /// `common` apis
        static let kPostCommentList                 = "PostCommentList"
        static let kGetCity                         = "GetCity"
        static let kGetCategory                     = "GetCategory"
        static let kGetReportReason                 = "GetReportReason"
        static let kNotificationList                = "NotificationList"
        static let kNotificationBadgeCount          = "NotificationBadgeCount"
        static let kAcceptRejectRequest             = "AcceptRejectRequest"
        
        /// `notifications` apis
        static let kRejectGroupVideo                = "RejectGroupVideo"
        static let kUpdateGroupVideo                = "UpdateGroupVideo"
        static let kUpdateGroupVideoUser            = "UpdateGroupVideoUser"
        
        /// `admin` apis
        static let kCreateUpdateDeleteCity          = "CreateUpdateDeleteCity"
        static let kCreateUpdateDeleteCategory      = "CreateUpdateDeleteCategory"
        
        /// `authentication` apis
        static let kLogin                           = "Login"
        static let kRegisterUser                    = "Registration"
        static let kChangePassword                  = "ChangePassword"
        static let kForgotPassword                  = "ForgotPassword"
        static let kResetPassword                   = "ResetPassword"
        
        /// `post` apis
        static let kHomeScreen                      = "HomeScreen"
        static let kGetAllUserList                  = "GetAllUserList"
        static let kCreateOrUpdatePost              = "CreateOrUpdatePost"
        static let kDeletePost                      = "DeletePost"
        static let kPostLike                        = "PostLike"
        static let kPostComment                     = "PostComment"
        static let kPostReport                      = "PostReport"
        static let kPostList                        = "PostList"
        static let kPostGridView                    = "PostGridView"
        static let kPostCommentDelete               = "PostCommentDelete"
        static let kPostDetail                      = "PostDetail"
        static let kUpdateViewCount                 = "UpdateViewCount"
        
        /// `snippet` apis
        static let kCreateOrUpdateSnippet           = "CreateOrUpdateSnippet"
        static let kSnippetList                     = "SnippetList"
        static let kDeleteSnippet                   = "DeleteSnippet"
        static let kSendRequest                     = "SendRequest"
        static let kAcceptRejectSnippetRequest      = "AcceptRejectSnippetRequest"
        static let kSnippetRequestList              = "SnippetRequestList"
        static let kGetSnippetPermission            = "GetSnippetPermission"
        
        /// `profile` apis
        static let kGetUserProfile                  = "GetUserProfile"
        static let kUpdateUserProfile               = "UpdateUserProfile"
        static let kDeactivateAccount               = "DeactivateAccount"
        static let kUserFollowersList               = "UserFollowersList"
        static let kUserFollowingList               = "UserFollowingList"
        static let kUserProfilePostList             = "UserProfilePostList"
        static let kFollowUser                      = "FollowUser"
        static let kFeaturedProfile                 = "FeaturedProfile"
        static let kFollowRequestList               = "FollowRequestList"
        
        /// `BreastCancerLegacies` apis
        static let kCreateOrUpdateLegacies          = "CreateOrUpdateLegacies"
        static let kLegaciesHomeScreen              = "LegaciesHomeScreen"
        static let kLegaciesDetail                  = "LegaciesDetail"
        
        /// `discover` apis
        static let kGetUsersByCategory              = "GetUsersByCategory"
    }
    
    // MARK: - Date Format Strings
    struct DateFormatString {
        static let MMMM__YYYY                                    = "MMMM, YYYY"
        static let MMMM_YYYY                                     = "MMMM YYYY"
        static let MMM_yy                                        = "MMM yy"
        static let ApiDateFormat                                 = "yyyy-MM-dd"
        static let ShowDateFormat                                = "MMM dd, yyyy"
        static let dd_MMM_yyyy                                   = "dd MMM, yyyy"
        static let YYYY_MM_dd_HH_mm_ss                           = "yyyy-MM-dd HH:mm:ss"
        static let YYYY_MM_dd_hh_mm_a                            = "yyyy-MM-dd hh:mm a"
        static let dd_MMMM                                       = "dd MMMM"
        static let HH_mm                                         = "HH:mm"
        static let hh_mm_a                                       = "hh:mm a"
        static let hh_mm_a_MMM_dd                                = "hh:mm a, MMM dd"
        static let hh_mm                                         = "hh:mm"
        static let a                                             = "a"
    }
    
    // MARK: - Font Style
    enum FontStyle: String {
        /// `futura`
        case MediumItalic                                        = "Futura Medium Italic"
        case BoldCondensed                                       = "Futura Bold Condensed"
        case Bold                                                = "Futura Bold"
        case ExtraBoldCondensed                                  = "Futura Extra Bold Condensed"
        case Italic                                              = "Futur a Italic"
        case BoldItalic                                          = "Futura Bold Italic"
        case Book                                                = "Futura Book"
        case ExtraBoldCondensedOblique                           = "Futura Extra Bold Condensed Oblique"
        case TBoldOblique                                        = "Futura T Bold Oblique"
        case TBold                                               = "Futura T Bold"
        case BoldCondensedOblique                                = "Futura Bold Condensed Oblique"
        case LightCondensed                                      = "Futura Light Condensed"
        case BoldOblique                                         = "Futura Bold Oblique"
        case Regular                                             = "Futura Regular"
        case MediumCondensedOblique                              = "Futura Medium Condensed Oblique"
        case Black                                               = "Futura Black"
        case Heavy                                               = "Futura Heavy"
        case Medium                                              = "Futura Medium"
        case CondensedExtraBold                                  = "Futura Condensed ExtraBold"
        case BQRegular                                           = "Futura BQ Regular"
        case Condensed                                           = "Futura Condensed"
        case HvHeavy                                             = "Futura Hv Heavy"
        case TMedium                                             = "Futura T Medium"
        case LightCondensedOblique                               = "Futura Light Condensed Oblique"
        case MediumOblique                                       = "Futura Medium Oblique"
        case MediumCondensed                                     = "Futura Medium Condensed"
        case Light                                               = "Futura Light"
        
        /// `blowbrush`
        case Blowbrush                                           = "blowbrush"
        case AlexBrushRegular                                    = "AlexBrushRegular"
        
    }
    
    // MARK: - App Font Size
    struct FontSize {
        static let _10FontSize: CGFloat                          = DeviceType.IsDeviceIPad ? 12 : 10
        static let _12FontSize: CGFloat                          = DeviceType.IsDeviceIPad ? 14 : 12
        static let _14FontSize: CGFloat                          = DeviceType.IsDeviceIPad ? 16 : 14
        static let _16FontSize: CGFloat                          = DeviceType.IsDeviceIPad ? 18 : 16
        static let _17FontSize: CGFloat                          = DeviceType.IsDeviceIPad ? 19 : 17
        static let _18FontSize: CGFloat                          = DeviceType.IsDeviceIPad ? 20 : 18
        static let _20FontSize: CGFloat                          = DeviceType.IsDeviceIPad ? 22 : 20
        static let _22FontSize: CGFloat                          = DeviceType.IsDeviceIPad ? 24 : 22
        static let _24FontSize: CGFloat                          = DeviceType.IsDeviceIPad ? 26 : 24
        static let _28FontSize: CGFloat                          = DeviceType.IsDeviceIPad ? 30 : 28
        static let _30FontSize: CGFloat                          = DeviceType.IsDeviceIPad ? 32 : 30
        static let _32FontSize: CGFloat                          = DeviceType.IsDeviceIPad ? 34 : 32
    }
}

// MARK: - APIStatusCode
struct APIStatusCode {
    static let kSessionInvalid          = 401
    static let kSuccessResponse         = 200
    static let kFailResponse            = 400
}

// MARK: - iPhone Screensize
struct ScreenSize {
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

// MARK: - iPhone devicetype
struct DeviceType {
    static let IS_IPHONE_4_OR_LESS  = ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPHONE_X          = ScreenSize.SCREEN_HEIGHT == 812.0
    static let IS_IPHONE_XMAX       = ScreenSize.SCREEN_HEIGHT == 896.0
    static let IS_PAD               = UIDevice.current.userInterfaceIdiom == .pad
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
    static let IS_IPAD_PRO          = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1366.0
    static let IsDeviceIPad         = IS_PAD || IS_IPAD || IS_IPAD_PRO ? true : false
}

// MARK: - ScreenControlsMultipliers
struct ScreenControlsMultipliers {
    static let kHeightOfNavigationBar: CGFloat  = 40
    static let kHeaderImageWidth: CGFloat       = ScreenSize.SCREEN_WIDTH - (DeviceType.IsDeviceIPad ? 160 : 120)
    static let kHeightOfTextField               = ScreenSize.SCREEN_HEIGHT * 0.065
    static let kHeightOfAppButton               = ScreenSize.SCREEN_HEIGHT * 0.065
    static let kHeightOfMaleFemaleSelection     = ScreenSize.SCREEN_HEIGHT * 0.05
    static let kHeightOfAchievement             = ScreenSize.SCREEN_HEIGHT * 0.06
    static let kHeightOfSearchBar: CGFloat      = DeviceType.IsDeviceIPad ? 55 : 45 /* ScreenSize.SCREEN_HEIGHT * 0.055 */
    static let kHeightOfImage : CGFloat         = ScreenSize.SCREEN_WIDTH * 0.5
}

// MARK: - Action Sheet Enum
enum OptionsMenu { case main, imageMenu, videoMenu , audioMenu }

enum SelectOptionMenu { case selectOption, browseVideos }

//MARK: - Image Quality
enum JPEGQuality: CGFloat {
    case lowest  = 0
    case low     = 0.25
    case medium  = 0.5
    case high    = 0.75
    case highest = 1
}

