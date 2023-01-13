//
//  ChangePasswordViewModel.swift
//  WhosNext
//
//  Created by differenz195 on 09/11/22.
//

import Foundation
import SwiftUI

public class ChangePasswordViewModel: ObservableObject {
    
    @Published  var curentPassword: String = ""
    @Published  var newPassword: String = ""
    @Published  var confirmPassword: String = ""
    @Published var moveToLogin: Bool = false
    
    ///validation
    @Published var showingError = false
    @Published var errorMessage : String = ""
    
    //Register Btn Action
    /* func onBtnUpdate_Click(){
        guard self.isValidUserinput() else { return }
        //        self.moveToHome = true
        
        //API Call
        self.changePasswordApiCall()
    } */
}

//MARK: - Helper Methods

extension ChangePasswordViewModel {
    
    /**
     This method is used to validate user input.
     - Returns: Return boolean value to indicate input data is valid or not.
     */
    func isValidUserinput() -> Bool {
        
        if self.curentPassword.trimWhiteSpace.isEmpty {
            errorMessage = IdentifiableKeys.ValidationMessages.kCurrentPassword
            showingError = true
            return false
        }
        
        else if self.newPassword.trimWhiteSpace.isEmpty {
            errorMessage = IdentifiableKeys.ValidationMessages.kNewPassword
            showingError = true
            return false
        }
        
        else if self.confirmPassword.trimWhiteSpace.isEmpty {
            errorMessage = IdentifiableKeys.ValidationMessages.kConfirmPassword
            showingError = true
            return false
        }
        
        else if self.confirmPassword != self.newPassword{
            errorMessage = IdentifiableKeys.ValidationMessages.kDoesNotMatchNewPassword
            showingError = true
            return false
        }
        return true
    }
    
    //changePassword Api Call
    func changePasswordApiCall(isShoLoader:Bool = true, completion: @escaping (String) -> Void) {
        
        let params: [String:Any] = [userModelKey.currentPassword : self.curentPassword,
                                    userModelKey.newPassword : self.newPassword,
                                    userModelKey.confirmPassword : self.confirmPassword
        ]
        
        print("All Register Params :- \(params)")
        
        if isShoLoader{
            Indicator.show()
        }
        
        
        UserModel.changePassword(params: params, success: {  response, message in
        
            if isShoLoader{
                Indicator.hide()
            }
            self.moveToLogin = true
            
            DispatchQueue.main.async {
                print("Change Password Successfully....!")
                
            }
            //            self.showingError = true
            //            Alert.show(message: "Change Password Successfully....!")
            completion(message)
        }, failure: { (errmsg) in
            if isShoLoader{
                Indicator.hide()
            }
            print(errmsg)
            self.showingError = true
            Alert.show(message: errmsg)
            
        })
    }
}
