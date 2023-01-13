//
//  OtpView.swift
//  WhosNext
//
//  Created by differenz195 on 09/11/22.
//

import SwiftUI

struct OtpView: View {
    // MARK: - Variables
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @StateObject var otpVM: OtpViewModel = OtpViewModel()

    @FocusState private var focusState: CommonTextFieldFocusState?

    var otp : String
    var otpUserId : String
    
    var body: some View {
        VStack {
            NavigationLink(destination: ResetPasswordView(resetUserId: otpUserId), isActive: self.$otpVM.moveToResetPassword, label: {})
            
            Image(IdentifiableKeys.ImageName.kAppTitleText)
                .frame(height: 50, alignment: .center)
                .padding(.horizontal, 35)
            Spacer()
            
            bottomView()
            
        }
        .onAppear {
            self.otpVM.clearState()
            self.otpVM.otpFromBacked = self.otp

            self.focusState = .otp
        }
        .alert(isPresented: self.$otpVM.showingError) {
            Alert(title: Text(""), message: Text(self.otpVM.errorMessage), dismissButton: .default(Text("OK")) {})
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: HStack {
            Button {
                self.presentationMode.wrappedValue.dismiss()
            } label: {
                Image(IdentifiableKeys.ImageName.kBackArrowBlack)
            }

            Spacer()
        })
    }
}

// MARK: - Helper Methods
extension OtpView {
    /// `bottom` view
    func bottomView() -> some View {
        VStack(alignment: .center) {
            CommonTextField(placeholderText: IdentifiableKeys.Labels.kVerifyOtp, isSecuredField: false, text: self.$otpVM.otp, focusState: self.$focusState, currentFocus: .constant(.otp), onCommit: {
                self.focusState = nil
            })
            .keyboardType(.numberPad)
            .submitLabel(.done)
            
            CommonButton(title: IdentifiableKeys.Buttons.kVerifyOtp, disabled: false, backgroundColor: Color.black, foregroundColor: Color.white, cornerradius: 5, fontSizes: Constant.FontSize._20FontSize, fontStyles: Constant.FontStyle.Medium, showImage: false) {
                self.otpVM.onBtnVerify_Click()
            }
            

            Spacer()
        }
        .padding(.top, 200)
        .padding(.horizontal, 45)
    }
}

// MARK: - Previews
struct OtpView_Previews: PreviewProvider {
    static var previews: some View {
        OtpView(otp: "", otpUserId: "")
    }
}
