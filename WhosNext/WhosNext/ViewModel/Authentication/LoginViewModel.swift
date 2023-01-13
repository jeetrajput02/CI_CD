//
//  LoginViewModel.swift
//  WhosNext
//
//  Created by differenz148 on 29/09/22.
//

import Foundation
import SwiftUI

public class LoginViewModel: ObservableObject {
    @Published var moveToSignUp: Bool = false
    @Published var moveToForgotPassword: Bool = false
    @Published var moveToTermsPrivacy: Bool = false
    @Published var moveToHome: Bool = false
    @Published var isForPrivacy = true
    @Published var userName: String = ""
    @Published var password: String = ""
    
    ///validation
    @Published var showingError = false
    @Published var errorMessage : String = ""
    
    // MARK: - Buttons Action
    func onBtnSignUp_Click() {
        self.moveToSignUp = true
    }
    
    func onBtnForgotPassword_Click() {
        self.moveToForgotPassword = true
    }
    
    func onBtnTermsPrivacy_Click(isForPrivacy : Bool) {
        self.isForPrivacy = isForPrivacy
        self.moveToTermsPrivacy = true
    }
    
    func onBtnLogin_Click() {
        guard self.isValidUserinput() else { return }
        self.LoginApiCall()
    }
    
    func clearState() -> Void {
        self.moveToSignUp = false
        self.moveToForgotPassword = false
        self.moveToTermsPrivacy = false
        self.moveToHome = false
        self.isForPrivacy = true
        self.userName = ""
        self.password = ""
        self.showingError = false
        self.errorMessage = ""
    }
}

//MARK: - Helper Methods
extension LoginViewModel{
    
    /**
     This method is used to validate user input.
     - Returns: Return boolean value to indicate input data is valid or not.
     */
    //MARK: Validations
    func isValidUserinput() -> Bool {
        
        if self.userName.trimWhiteSpace.isEmpty {
            errorMessage = IdentifiableKeys.ValidationMessages.kEmptyUserName
            showingError = true
            return false
        }
        else if self.password.trimWhiteSpace.isEmpty {
            errorMessage = IdentifiableKeys.ValidationMessages.kEmptyPassword
            showingError = true
            return false
            
        }
        
        return true
    }
    
    //MARK: - Login Api Call
    func LoginApiCall(isShoLoader:Bool = true) {
        
        let params: [String:Any] = [userModelKey.userName : self.userName,
                                    userModelKey.password : self.password,
                                    userModelKey.deviceType : 1,
                                    userModelKey.deviceModel : "",
                                    userModelKey.appVersion : "",
                                    userModelKey.deviceToken : UserDefaults.standard.object(forKey: UserDefaultsKey.kDeviceToken) as? String ?? ""
                                    ]
        
//        guard let deviceToken = UserDefaults.standard.object(forKey: UserDefaultsKey.kDeviceToken) as? String else { return }

//        params.updateValue(userDeviceDetails, forKey: userModelKey.u)
        print("All Params:- \(params)")
        
        if isShoLoader{
            Indicator.show()
        }
      
        
        UserModel.loginAPICall(params: params, success: { response, message in
            
            if isShoLoader{
                Indicator.hide()
            }
          
            self.moveToHome = true
            self.userName = ""
            self.password = ""
            DispatchQueue.main.async {
            
                
                //save current user and userdefalut
                if let userData = response {
                    
                    UserDefaults.setData(userData, UserDefaultsKey.kLoginUser)
                    
//                    let accessToken = UserDefaults.getData(UserDefaultsKey.kLoginUser, data: UserModel.self)?.access_token ?? ""
//                    print("Token :- \(accessToken)")
                    

                    if userData.userType == 1 {
                        
                        print("************** usertype 1 ***************")
                    }
//
//                        if userData.is_profile_completed == true {
//                            print("Login to Athlete Huddle")
//                        }
//                        else{
//                            self.btnPersonalInfoSelect = true
//                            print("Login to Athlete Personal info")
//                        }
//
//                    } else if userData.user_type == 3 {
//
//                        if userData.is_profile_completed == true {
//                            self.btnShowDashboardSelect = true
////                            print("Login to AMO Dashboard")
//                        }else{
////                            self.btnTeamInfoSelect = true
//                            self.btnTeamAdminSelect = true
////                            print("Login to AMO Profile info")
//                        }
//
//                    }
                    
                }
            
            }
        }, failure: { (errmsg) in
            if isShoLoader{
                Indicator.hide()
            }
            self.errorMessage = errmsg
            self.showingError = true
            Alert.show(message: errmsg)

        })
    }
}
