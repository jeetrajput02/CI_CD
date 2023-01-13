//
//  ForgotPasswordViewModel.swift
//  WhosNext
//
//  Created by differenz195 on 09/11/22.
//

import Foundation
import SwiftUI

struct AlertInfo: Identifiable {
    enum AlertType {
        case validation
        case success
    }
    
    var id: AlertType
    let title: String
    let message: String
}


public class ForgotPasswordViewModel: ObservableObject {
    @Published var email : String = ""
    @Published var userID : String = ""
    @Published var moveToOtp : Bool = false
    @Published var otp: String = ""
    @Published var info: AlertInfo?

    ///validation
    @Published var showingError = false
    @Published var errorMessage : String = ""
}

// MARK: - Functions
extension ForgotPasswordViewModel {
    /**
     This method is used to validate user input.
     - Returns: Return boolean value to indicate input data is valid or not.
     */
    func isValidUserinput() -> Bool {
        let emailRegEx = IdentifiableKeys.ConstantString.kEmailRegex
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        if self.email.trimWhiteSpace.isEmpty {
            self.info = AlertInfo(id: .validation, title: "", message: IdentifiableKeys.ValidationMessages.kEmptyEmail)
            self.showingError = true
            
            return false
        } else if !emailTest.evaluate(with: self.email)  {
            self.info = AlertInfo(id: .validation, title: "", message: IdentifiableKeys.ValidationMessages.kInvalidEmail)
            self.showingError = true
            
            return false
        }
        
        return true
    }
    
    func clearState() -> Void {
        self.email = ""
        self.userID = ""
        self.moveToOtp = false
        self.otp = ""
        self.info = nil
        self.showingError = false
        self.errorMessage = ""
    }
}

// MARK: - Helper Methods
extension ForgotPasswordViewModel {
    /// `api call` for forgot password
    func forgotPasswordApiCall(isShoLoader:Bool = true, Suceess: @escaping () -> ()) {
        guard self.isValidUserinput() else { return }
        
        let params: [String:Any] = [userModelKey.email : self.email,
                                    userModelKey.userId : self.userID,
                                    userModelKey.forgotToken : self.otp]
        
        print("All Forgot Password Params :- \(params)")
        UserDefaults.standard.set(self.userID, forKey: "forgotUserID")

        if isShoLoader {
            Indicator.show()
        }
        
        UserModel.forgotPassword(params: params, success: { response, message in
            if isShoLoader {
                Indicator.hide()
            }

            if message == "No such email is exists in system." {
                Alert.show(title: "", message: message)
            } else {
                self.otp = String(response?.forgotToken ?? 0)
                self.userID = String(response?.userId ?? 0)

                self.info = AlertInfo(id: .success, title: "", message: "OTP has been sent to your email.")
                print("Forgot Password Successfully....!")
            }

            self.email = ""
        } , failure: { (errmsg) in
            if isShoLoader {
                Indicator.hide()
            }

            print(errmsg)

            self.showingError = true
            Alert.show(message: errmsg)
        })
    }
}
