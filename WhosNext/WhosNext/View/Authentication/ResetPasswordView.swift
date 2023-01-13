//
//  ResetPasswordView.swift
//  WhosNext
//
//  Created by differenz195 on 09/11/22.
//

import SwiftUI

struct ResetPasswordView: View {
    // MARK: - Variables
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @StateObject var resetPasswordVM: ResetPasswordViewModel = ResetPasswordViewModel()
    @StateObject var forgotPasswordVM: ForgotPasswordViewModel = ForgotPasswordViewModel()

    @FocusState private var focusState: CommonTextFieldFocusState?

    var resetUserId: String

    var body: some View {
        VStack {
            Image(IdentifiableKeys.ImageName.kAppTitleText)
                .frame(height: 50, alignment: .center)
                .padding(.horizontal, 35)
            Spacer()
            
            self.bottomView()
        }
        .onAppear {
            self.resetPasswordVM.clearState()
            self.resetPasswordVM.userID = self.resetUserId

            self.focusState = .password
        }
        .alert(item: self.$resetPasswordVM.info, content: { info in
            Alert(title: Text(""), message: Text(info.message), dismissButton: .default(Text("OK")) {
                if info.id == .success {
                    NavigationUtil.popToRootView()
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
extension ResetPasswordView {
    /// `bottom` view
    func bottomView() -> some View {
        VStack(alignment: .center) {
            
            CommonTextField(placeholderText: IdentifiableKeys.Labels.kPassword, isSecuredField: true, text: self.$resetPasswordVM.password, focusState: self.$focusState, currentFocus: .constant(.password), onCommit: {
                self.focusState = .confirmPassword
            })
            .submitLabel(.next)
            
            CommonTextField(placeholderText: IdentifiableKeys.Labels.kConfirmPassword, isSecuredField: true, text: self.$resetPasswordVM.confirmPassword, focusState: self.$focusState, currentFocus: .constant(.confirmPassword), onCommit: {
                self.focusState = nil
            })
            .submitLabel(.done)
            
            CommonButton(title: IdentifiableKeys.Buttons.kResetPassword, disabled: false, backgroundColor: Color.black, foregroundColor: Color.white, cornerradius: 5, fontSizes: Constant.FontSize._20FontSize, fontStyles: Constant.FontStyle.Medium, showImage: false) {
                self.resetPasswordVM.resetPasswordApiCall {
               
                }

                print("tap SUBMIT btn")
            }

            Spacer()
        }
        .padding(.top, 200)
        .padding(.horizontal, 45)
        
    }
}

// MARK: - Previews
struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView(resetUserId: "")
    }
}
