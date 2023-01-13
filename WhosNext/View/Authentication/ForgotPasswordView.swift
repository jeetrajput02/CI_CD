//
//  ForgotPasswordView.swift
//  WhosNext
//
//  Created by differenz195 on 28/09/22.

import SwiftUI

struct ForgotPasswordView: View {
    // MARK: - Variables
    @StateObject var forgotPasswordVM: ForgotPasswordViewModel = ForgotPasswordViewModel()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @FocusState private var focusState: CommonTextFieldFocusState?
    @State var showAlert = false

    var body: some View {
        VStack {
            // Move to Otp Screen
            NavigationLink(destination: OtpView(otp: self.forgotPasswordVM.otp, otpUserId: self.forgotPasswordVM.userID), isActive: self.$forgotPasswordVM.moveToOtp, label: {})
            
            Image(IdentifiableKeys.ImageName.kAppTitleText)
                .frame(height: 50, alignment: .center)
                .padding(.horizontal, 35)
            Spacer()
            
            self.bottomView()
        }
        .onAppear {
            self.forgotPasswordVM.clearState()

            self.focusState = .email
        }
        .alert(item: self.$forgotPasswordVM.info, content: { info in
            Alert(title: Text(""), message: Text(info.message), dismissButton: .default(Text("OK")) {
                if info.id == .success {
                    self.forgotPasswordVM.moveToOtp = true
                }
            })
        })
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


// MARK: -  Helper Methods
extension ForgotPasswordView {
    /// `bottom` view
    func bottomView() -> some View {
        VStack(alignment: .center) {
            CommonTextField(placeholderText: IdentifiableKeys.Labels.kEmail, isSecuredField: false, text: $forgotPasswordVM.email, focusState: self.$focusState, currentFocus: .constant(.email)) {
                print("Email")
            }
            .submitLabel(.done)
            .keyboardType(.emailAddress)
        
            CommonButton(title: IdentifiableKeys.Buttons.kSubmit, disabled: false, backgroundColor: Color.black, foregroundColor: Color.white, cornerradius: 5, fontSizes: Constant.FontSize._20FontSize, fontStyles: Constant.FontStyle.Medium, showImage: false) {
                self.showAlert = true
                self.forgotPasswordVM.forgotPasswordApiCall {}
             
                print("tap SUBMIT btn")
            }

            Spacer()
        }
        .padding(.top, 200)
        .padding(.horizontal, 45)
    }
}

// MARK: - Previews
struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
