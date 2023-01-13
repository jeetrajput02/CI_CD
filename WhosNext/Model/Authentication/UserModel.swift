//
//  UserModel.swift
//  WhosNext
//
//  Created by differenz195 on 04/11/22.
//

import Foundation

enum userModelKey {
    static let userId = "user_id"
    static let userType = "user_type"
    static let password = "password"
    static let firstName = "first_name"
    static let lastName = "last_name"
    static let userName = "username"
    static let accessToken = "access_token "
    static let email = "email"
    static let cityId = "city_id"
    static let city = "city"
    static let introductionVideo = "introduction_video"
    static let aboutSelf   =  "about_self"
    static let categoryId   = "category_id"
    static let categoryName  = "category_name"
    static let isPrivate    = "is_private"
    static let isSubscribed     = "is_subscribed"
    static let isNotificationEnable  = "is_notification_enable"
    static let authorization = "Authorization"
    static let deviceType   = "device_type"
    static let deviceToken  = "device_token"
    static let deviceModel  = "device_model"
    static let appVersion   = "app_version"
    static let message = "message"
    static let currentPassword = "current_password"
    static let newPassword = "new_password"
    static let confirmPassword = "confirm_password"
    static let forgotToken = "forgot_token"
    static let introduction_video = "introduction_video"
    static let introduction_video_thumb = "introduction_video_thumb"
    static let video_height = "video_height"
    static let video_width = "video_width"
}

struct UserModel: Codable {
    
    var userId, userType, deviceType, forgotToken : Int
    var firstName, lastName, userName, email, cityId, city, introductionVideo, aboutSelf, category_id, category_name, password, accessToken, authorization : String
    var deviceToken,deviceModel, appVersion : String
    
    
    init(Dict:[String:Any]) {
        
        self.userId = Dict[userModelKey.userId] as? Int ?? 0
        self.userType = Dict[userModelKey.userType] as? Int ?? 0
        self.forgotToken = Dict[userModelKey.forgotToken] as? Int ?? 0
        self.email = Dict[userModelKey.email] as? String ?? ""
        self.password = Dict[userModelKey.password] as? String ?? ""
        self.firstName = Dict[userModelKey.firstName] as? String ?? ""
        self.lastName = Dict[userModelKey.lastName] as? String ?? ""
        self.userName = Dict[userModelKey.userName] as? String ?? ""
        self.cityId = Dict[userModelKey.cityId] as? String ?? ""
        self.accessToken = Dict[userModelKey.accessToken] as? String ?? ""
        self.city = Dict[userModelKey.city] as? String ?? ""
        self.introductionVideo = Dict[userModelKey.introductionVideo] as? String ?? ""
        self.aboutSelf = Dict[userModelKey.aboutSelf] as? String ?? ""
        self.category_id = Dict[userModelKey.categoryId] as? String ?? ""
        self.category_name = Dict[userModelKey.categoryName] as? String ?? ""
        self.deviceToken = Dict[userModelKey.deviceToken] as? String ?? ""
        self.deviceModel = Dict[userModelKey.deviceModel] as? String ?? ""
        self.deviceType = Dict[userModelKey.deviceType] as? Int ?? 0
        self.appVersion = Dict[userModelKey.appVersion] as? String ?? ""
        self.authorization = Dict[userModelKey.authorization] as? String ?? ""
    }
    
}

// MARK: - DataClass
//struct DeviceDetils: Codable {
//
//    var deviceToken, model, appVersion: String
//    var deviceType: Int
//
//    init(Dict: [String:Any]) {
//        self.deviceToken = Dict[DeviceTypeKey.deviceToken] as? String ?? ""
//        self.model = Dict[DeviceTypeKey.model] as? String ?? ""
//        self.deviceType = Dict[DeviceTypeKey.deviceType] as? Int ?? 0
//        self.appVersion = Dict[DeviceTypeKey.appVersion] as? String ?? ""
//    }
//
//}

extension UserModel {
    
    //Login API Call
    static func loginAPICall(params: [String:Any],
                             success: @escaping (UserModel?, String)-> Void,
                             failure: @escaping (String)-> Void,
                             showLoader:Bool = false) {
        if showLoader
        {
        Indicator.show()
        }
        APIManager.makeRequest(with: Constant.ServerAPI.kLogin, method: .post, parameter: params) { response in
            
            if showLoader
            {
            Indicator.hide()
            }
            let dict = response as? [String:Any] ?? [:]
            let isSuccess = dict[APIManagerKey.IsSuccess] as? Bool ?? false
            let message = dict[APIManagerKey.Message] as? String ?? ""
            let _ = dict[APIManagerKey.StatusCode] as? Int ?? 0
            let dictUserData = dict[APIManagerKey.Data] as? [String:Any] ?? [:]
            let userData = UserModel(Dict: dictUserData)
            
            if isSuccess {
                
                success(userData,message)
                
            } else {
                failure(message)
            }
            
        } failure: { error, errorcode, isAuth in
            if showLoader
            {
            Indicator.hide()
            }
            failure(error)
        } connectionFailed: { error in
            if showLoader
            {
            Indicator.hide()
            }
            failure(error)
        }
    }
    
    //Register API Call
    static func registerUser(params: [String:Any],
                             success: @escaping (UserModel?, String)-> Void,
                             failure: @escaping (String)-> Void,
                             showLoader:Bool = false) {
        if showLoader {
            Indicator.show()
        }

        APIManager.makeRequest(with: Constant.ServerAPI.kRegisterUser, method: .post, parameter: params, success:  { response in
            let dict = response as? [String:Any] ?? [:]
            let isSuccess = dict[APIManagerKey.IsSuccess] as? Bool ?? false
            let message = dict[APIManagerKey.Message] as? String ?? ""
            let _ = dict[APIManagerKey.StatusCode] as? Int ?? 0
            let apiDictData = dict[APIManagerKey.Data] as? [String:Any] ?? [:]
            let userData = UserModel(Dict: apiDictData)
            
            if showLoader {
                Indicator.hide()
            }
            
            if isSuccess {
                success(userData, message)
            }
            
        }, failure: { error, errorcode , isAuth in
            if showLoader
            {
            Indicator.hide()
            }
            failure(error)
        }, connectionFailed: { error in
            if showLoader {
                Indicator.hide()
            }
            failure(error)
        })
        
    }
    
    //Change Password API Call
    static func changePassword(params:[String:Any],
                               success: @escaping (UserModel?, String)-> Void,
                               failure: @escaping (String)-> Void,
                               showLoader:Bool = false){
        if showLoader
        {
        Indicator.show()
        }
        APIManager.makeRequest(with: Constant.ServerAPI.kChangePassword, method: .post, parameter: params) { response in
            if showLoader
            {
            Indicator.hide()
            }
            let dict = response as? [String:Any] ?? [:]
            let isSuccess = dict[APIManagerKey.IsSuccess] as? Bool ?? false
            let message = dict[APIManagerKey.Message] as? String ?? ""
            let _ = dict[APIManagerKey.StatusCode] as? Int ?? 0
            let dictUserData = dict[APIManagerKey.Data] as? [String:Any] ?? [:]
            let userData = UserModel(Dict: dictUserData)
            
            if isSuccess {
                
                success(userData,message)
                
            } else {
                failure(message)
            }
            
        } failure: { error, errorcode, isAuth in
            if showLoader
            {
            Indicator.hide()
            }
            failure(error)
        } connectionFailed: { error in
            if showLoader
            {
            Indicator.hide()
            }
            failure(error)
        }
    }
    
    //Forgot Password API Call
    static func forgotPassword(params:[String:Any],
                               success: @escaping (UserModel?, String)-> Void,
                               failure: @escaping (String)-> Void,
                               showLoader:Bool = false){
        if showLoader
        {
        Indicator.show()
        }
        APIManager.makeRequest(with: Constant.ServerAPI.kForgotPassword, method: .post, parameter: params) { response in
            if showLoader
            {
            Indicator.hide()
            }
            let dict = response as? [String:Any] ?? [:]
            let isSuccess = dict[APIManagerKey.IsSuccess] as? Bool ?? false
            let message = dict[APIManagerKey.Message] as? String ?? ""
            let _ = dict[APIManagerKey.StatusCode] as? Int ?? 0
            let dictUserData = dict[APIManagerKey.Data] as? [String:Any] ?? [:]
            let userData = UserModel(Dict: dictUserData)
            
            if isSuccess {
                
                success(userData,message)
                
            } else {
                failure(message)
            }
            
        } failure: { error, errorcode, isAuth in
            if showLoader
            {
            Indicator.hide()
            }
            failure(error)
        } connectionFailed: { error in
            if showLoader
            {
            Indicator.hide()
            }
            failure(error)
        }
    }
    
    
    //Reset Password API Call
    static func resetPassword(params:[String:Any],
                              success: @escaping (UserModel?, String)-> Void,
                              failure: @escaping (String)-> Void,
                              showLoader:Bool = false){
        if showLoader
        {
        Indicator.show()
        }
        APIManager.makeRequest(with: Constant.ServerAPI.kResetPassword, method: .post, parameter: params) { response in
            if showLoader
            {
            Indicator.hide()
            }
            let dict = response as? [String:Any] ?? [:]
            let isSuccess = dict[APIManagerKey.IsSuccess] as? Bool ?? false
            let message = dict[APIManagerKey.Message] as? String ?? ""
            let _ = dict[APIManagerKey.StatusCode] as? Int ?? 0
            let dictUserData = dict[APIManagerKey.Data] as? [String:Any] ?? [:]
            let userData = UserModel(Dict: dictUserData)
            
            if isSuccess {
                
                success(userData,message)
                
            } else {
                failure(message)
            }
            
        } failure: { error, errorcode, isAuth in
            if showLoader
            {
            Indicator.hide()
            }
            failure(error)
        } connectionFailed: { error in
            if showLoader
            {
            Indicator.hide()
            }
            failure(error)
        }
    }
    
    
    //    static func logout(success:@escaping(String)->Void,
    //                       failure: @escaping (String)-> Void,
    //                       showLoader:Bool = true) {
    //
    //        if showLoader {
    //            Indicator.show()
    //        }
    //
    //        APIManager.makeRequest(with: Constant.API.kLogOut, method: .get, parameter: nil) { response in
    //
    //            if showLoader {
    //                Indicator.hide()
    //            }
    //
    //            let dict = response as? [String:Any] ?? [:]
    //            let message = dict[APIManagerKey.Message] as? String ?? ""
    //            success(message)
    //
    //        } failure: { error, errorcode, isAuth in
    //            if showLoader {
    //                Indicator.hide()
    //            }
    //
    //            failure(error)
    //
    //        } connectionFailed: { error in
    //            if showLoader {
    //                Indicator.hide()
    //            }
    //
    //            failure(error)
    //        }
    //    }
    
}


