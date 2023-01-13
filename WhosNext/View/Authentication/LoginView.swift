//
//  LoginView.swift
//  WhosNext
//
//  Created by differenz195 on 27/09/22.
//

import SwiftUI

struct LoginView: View {
    // MARK: - Variablles
    @StateObject var loginVM: LoginViewModel = LoginViewModel()
    @StateObject var viewRouter: ViewRouter = ViewRouter()
    
    @FocusState private var focusState: CommonTextFieldFocusState?

    var body: some View {
            VStack {
                Group {
                    //Move to Register Screen
                    NavigationLink(destination: RegisterView(), isActive: $loginVM.moveToSignUp, label: {})
                    
                    //Move to Forgot Password Screen
                    NavigationLink(destination: ForgotPasswordView(), isActive: $loginVM.moveToForgotPassword, label: {})
                    
                    //Move to TermsPrivacy Screen
                    NavigationLink(destination: TermsPrivacyView(isForPrivacy: self.loginVM.isForPrivacy), isActive: $loginVM.moveToTermsPrivacy, label: {})
                    
                    //Move to Home Screen
                    if self.loginVM.moveToHome {
                        NavigationLink(destination: HomeView(), isActive: $loginVM.moveToHome, label: {})
                    }
                }
                
                Image(IdentifiableKeys.ImageName.kAppTitleText)
                    .frame(height: 50, alignment: .center)
                    .padding(.top, 45)
                    .padding(.horizontal, 35)
                Spacer()
                
                VStack(alignment: .center) {
                    CommonTextField(placeholderText: IdentifiableKeys.Labels.kUsername, isSecuredField: false, text: $loginVM.userName, focusState: self.$focusState, currentFocus: .constant(.username), onCommit: {
                        self.focusState = .password
                    })
                    .submitLabel(.next)

                    CommonTextField(placeholderText: IdentifiableKeys.Labels.kPassword, isSecuredField: true, text: $loginVM.password, focusState: self.$focusState, currentFocus: .constant(.password), onCommit: {
                        self.focusState = nil
                    })
                    .submitLabel(.done)
                    
                    CommonButton(title: IdentifiableKeys.Buttons.kLogin) {
                        self.loginVM.onBtnLogin_Click()
                    }

                    VStack{
                        Button(action: {
                            self.loginVM.onBtnForgotPassword_Click()
                        }, label: {
                            Text(IdentifiableKeys.Buttons.kForgotPassword)
                                .font(.custom(Constant.FontStyle.Heavy.rawValue, size: Constant.FontSize._16FontSize))
//                                .foregroundColor(Color.black)
                                .foregroundColor(Color.myDarkCustomColor)
                                .fixedSize(horizontal: true, vertical: false)
                        })
                        
                        CommonButton(title: IdentifiableKeys.Buttons.kCreateAccount, disabled: false, backgroundColor: Color.black, foregroundColor: Color.white, cornerradius: 5, fontSizes: Constant.FontSize._16FontSize, fontStyles: Constant.FontStyle.Heavy, showImage: false) {
                            print("Tap Create Account Btn")
                            self.loginVM.onBtnSignUp_Click()
                        }
                        .padding(.top , 20)
                        .fixedSize(horizontal: true, vertical: false)
                    }
                    .padding(.top , 20)
                    .padding(.horizontal, 55)
                    
                    Rectangle()
                        .frame(height: 1)
                        .background(Color.myDarkCustomColor)
                    
                    HStack {
                        Button(action: {
                            print("Tap Privacy Policy Btn")
                            self.loginVM.onBtnTermsPrivacy_Click(isForPrivacy: true)
                        }, label: {
                            Text(IdentifiableKeys.Labels.kPrivacyPolicy)
                                .font(.custom(Constant.FontStyle.TMedium.rawValue, size: Constant.FontSize._16FontSize))
                            
                                .foregroundColor(Color.myDarkCustomColor)
                        })
                        
                        Spacer()

                        Button(action: {
                            print("Tap Terms & Condition Btn")
                            self.loginVM.onBtnTermsPrivacy_Click(isForPrivacy: false)
                        }, label: {
                            Text(IdentifiableKeys.Labels.kTermsandCondition)
                                .font(.custom(Constant.FontStyle.TMedium.rawValue, size: Constant.FontSize._16FontSize))
                                .foregroundColor(Color.myDarkCustomColor)
                        })
                    }
                }
                .padding(.horizontal, 60)

                Spacer()
            }
            .onAppear {
                self.loginVM.clearState()

                self.focusState = .username
            }
            .alert(isPresented: $loginVM.showingError) {
                Alert(title: Text(""), message: Text(loginVM.errorMessage), dismissButton: .default(Text("OK")) {
                })
            }
            .hideNavigationBar()
            .accentColor(.black)
    }
}

// MARK: - Previews
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
