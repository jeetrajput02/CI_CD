//
//  OtpViewModel.swift
//  WhosNext
//
//  Created by differenz195 on 09/11/22.
//

import Foundation
import SwiftUI

public class OtpViewModel: ObservableObject {
    // MARK: - Variables
    @Published var otp: String = ""
    @Published var moveToResetPassword: Bool = false
    @Published var email: String = ""
    @Published var userID: String = ""
    
    ///validation
    @Published var showingError = false
    @Published var errorMessage: String = ""
    @Published var otpFromBacked: String = ""
    
    func onBtnVerify_Click() {
        if self.otpFromBacked == self.otp {
            self.moveToResetPassword = true
        } else {
            errorMessage = IdentifiableKeys.ValidationMessages.kValidOtp
            showingError = true
        }
        
        guard self.isValidUserinput() else { return }
    }
    
    /**
     This method is used to validate user input.
     - Returns: Return boolean value to indicate input data is valid or not.
     */
    func isValidUserinput() -> Bool {
        
        if self.otp.trimWhiteSpace.isEmpty {
            errorMessage = IdentifiableKeys.ValidationMessages.kOtpVerify
            showingError = true
            return false
        }
        return true
    }
    
    func clearState() -> Void {
        self.otp = ""
        self.moveToResetPassword = false
        self.email = ""
        self.userID = ""
        self.showingError = false
        self.errorMessage = ""
        self.otpFromBacked = ""
    }
}
