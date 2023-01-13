//
//  ResetPasswordViewModel.swift
//  WhosNext
//
//  Created by differenz195 on 09/11/22.
//

import SwiftUI

public class ResetPasswordViewModel: ObservableObject {
    @Published var password : String = ""
    @Published var confirmPassword : String = ""
    @Published var userID : String = ""
    
    ///validation
    @Published var showingError = false
    @Published var errorMessage : String = ""
    @Published var info: AlertInfo?
}

// MARK: - Helper Methods
extension ResetPasswordViewModel {
    /**
     This method is used to validate user input.
     - Returns: Return boolean value to indicate input data is valid or not.
     */
    func isValidUserinput() -> Bool {
        
        if self.password.trimWhiteSpace.isEmpty {
            self.info = AlertInfo(id: .validation, title: "", message: IdentifiableKeys.ValidationMessages.kEmptyPassword)
            showingError = true
            return false
        }
        
        else if self.confirmPassword.trimWhiteSpace.isEmpty {
            self.info = AlertInfo(id: .validation, title: "", message: IdentifiableKeys.ValidationMessages.kConfirmPassword)
            showingError = true
            return false
        }
        else if self.confirmPassword != self.password {
            self.info = AlertInfo(id: .validation, title: "", message: IdentifiableKeys.ValidationMessages.kDoesNotMatchConfirmPassword)
            showingError = true
            return false
            
        }
        /* else if self. != self.password {
         errorMessage = IdentifiableKeys.ValidationMessages.kDoesNotMatchConfirmPassword
         showingError = true
         return false
         
         } */
        return true
    }
    
    func clearState() -> Void {
        self.password = ""
        self.confirmPassword = ""
        self.userID = ""
        self.showingError = false
        self.errorMessage = ""
        self.info = nil
    }
}

// MARK: - API Calls
extension ResetPasswordViewModel {
    // Reset Password API Call
    func resetPasswordApiCall(isShoLoader:Bool = true, Success: @escaping () -> ()) {
        guard self.isValidUserinput() else { return }
        
        let params: [String:Any] = [userModelKey.password : self.password,
                                    userModelKey.userId : self.userID]
        
        print("All Reset Password Params :- \(params)")
        
        if isShoLoader {
            Indicator.show()
        }
        
        UserModel.resetPassword(params: params, success: { response, message in
         
            if isShoLoader {
                Indicator.hide()
            }
            
            self.info = AlertInfo(id: .success, title: "", message: "Reset password successfuly.")
            
        }, failure: { (errmsg) in
            if isShoLoader {
                Indicator.hide()
            }
            
            print(errmsg)
            
            self.showingError = true
            Alert.show(message: errmsg)
            
        })
    }
}
