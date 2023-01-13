//
//  RegisterView.swift
//  WhosNext
//
//  Created by differenz195 on 27/09/22.
//

import SwiftUI

struct RegisterView: View {
    // MARK: - Variables
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var registerVM: RegisterViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @FocusState private var focusState: CommonTextFieldFocusState?
    @State var shouldPresentImagePicker : Bool = false
    
    @State var isVideoImage : Bool = false
    @State var isShowSheet : Bool = false
    @State var isShowVideos : Bool = false
    @State var arrImage: [UIImage] = []
    
    var body: some View {
        VStack {
            Group {
                NavigationLink(destination: TermsPrivacyView(isForPrivacy: self.registerVM.isForPrivacy), isActive: self.$registerVM.moveToTermsPrivacy, label: {})
            }
            
            Image(IdentifiableKeys.ImageName.kAppTitleText)
                .frame(height: 50, alignment: .center)
                .padding(.bottom, 45)
            
            self.bottomView()
        }
        .padding(.horizontal, 60.0)
        .onAppear {
            self.registerVM.clearState()
            if self.registerVM.categoryList.count == 0 {
                self.registerVM.getCategoryList()
            }

            self.focusState = .firstName
        }
        .alert(isPresented: self.$registerVM.showingError) {
            Alert(title: Text(""), message: Text(self.registerVM.errorMessage), dismissButton: .default(Text("OK")) {
            })
        }
        .sheet(isPresented: self.$shouldPresentImagePicker, onDismiss: {
            if self.registerVM.videoURL == nil {
                self.isShowVideos = false
            }
        }) {
            CustomImagePickerView(sourceType: self.registerVM.isPresentCamera ? (UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary) : .photoLibrary, isVideoAllow: self.isShowVideos, arrImage: self.$arrImage, image: self.$registerVM.ShowImage ,isPresented: self.$shouldPresentImagePicker, videoURL: self.$registerVM.videoURL)
        }
        .actionSheet(isPresented: self.$registerVM.isShowPhotoLibrary) { () -> ActionSheet in
            ActionSheet(title: Text(""), message: Text("Browse Your Videos"), buttons: [
                .default(Text("Capture Video"), action: {
                    self.shouldPresentImagePicker = true
                    self.registerVM.isPresentCamera = true
                    self.isShowVideos = true
                }),
                .default(Text("Pick Video From Gallery"), action: {
                    self.shouldPresentImagePicker = true
                    self.registerVM.isPresentCamera = false
                    self.isShowVideos = true
                }),
                .cancel()
            ])
        }
        .sheet(isPresented: self.$isShowSheet) {
            SelectTalentList(categoryListModel: self.$registerVM.categoryList, selectedCategories: self.$registerVM.selectedCategories, isFromRegister: true)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: HStack {
            Button {
                self.presentationMode.wrappedValue.dismiss()
            } label: {
                Image(colorScheme == .dark ? IdentifiableKeys.ImageName.kBackarrowwhite : IdentifiableKeys.ImageName.kBackArrowBlack)
            }

            Spacer()
        })
    }
}


// MARK: - UI Helpers
extension RegisterView {
    /// `bottom` view
    func bottomView() -> some View {
        ScrollView(showsIndicators: false) {
            VStack {
                CommonTextField(placeholderText: IdentifiableKeys.Labels.kFirstName, isSecuredField: false, text: self.$registerVM.firstName, focusState: self.$focusState, currentFocus: .constant(.firstName), onCommit: {
                    self.focusState = .lastName
                })
                .submitLabel(.next)
                
                CommonTextField(placeholderText: IdentifiableKeys.Labels.kLastName, isSecuredField: false, text: self.$registerVM.lastName, focusState: self.$focusState, currentFocus: .constant(.lastName), onCommit: {
                    self.focusState = .username
                })
                .submitLabel(.next)
                
                CommonTextField(placeholderText: IdentifiableKeys.Labels.kUsername, isSecuredField: false, text: self.$registerVM.userName, focusState: self.$focusState, currentFocus: .constant(.username), onCommit: {
                    self.focusState = .email
                })
                .submitLabel(.next)
                
                CommonTextField(placeholderText: IdentifiableKeys.Labels.kEmail, isSecuredField: false, text: self.$registerVM.email, focusState: self.$focusState, currentFocus: .constant(.email), onCommit: {
                    self.focusState = .confirmEmail
                })
                .submitLabel(.next)
                .keyboardType(.emailAddress)
                
                CommonTextField(placeholderText: IdentifiableKeys.Labels.kConfirmEmail, isSecuredField: false, text: self.$registerVM.confirmEmail, focusState: self.$focusState, currentFocus: .constant(.confirmEmail), onCommit: {
                    self.focusState = .password
                })
                .submitLabel(.next)
                .keyboardType(.emailAddress)
                
                CommonTextField(placeholderText: IdentifiableKeys.Labels.kPassword, isSecuredField: true, text: self.$registerVM.password, focusState: self.$focusState, currentFocus: .constant(.password), onCommit: {
                    self.focusState = .confirmPassword
                })
                .submitLabel(.next)
                
                CommonTextField(placeholderText: IdentifiableKeys.Labels.kConfirmPassword, isSecuredField: true, text: self.$registerVM.confirmPassword, focusState: self.$focusState, currentFocus: .constant(.confirmPassword), onCommit: {
                    self.focusState = nil
                })
                .submitLabel(.done)
                
                VStack {
                    let category = self.registerVM.selectedCategories.map({ $0.category }).joined(separator: ",")

                    CommonButton(title: self.registerVM.selectedCategories.count > 0 ? category :  IdentifiableKeys.Buttons.kSelectyourtalentorbusinessplease, disabled: false, backgroundColor: Color.white, foregroundColor: Color.CustomColor.AppDropdownColor, cornerradius: 5, fontSizes: Constant.FontSize._14FontSize, fontStyles: Constant.FontStyle.Medium, showImage: true) {
                        isShowSheet = true
                        print("tap btn")
                        self.registerVM.tempValue.removeAll()
                    }
                    .multilineTextAlignment(.center)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.black)
                    )
                    
                    self.Videoupload()
                    self.CheckboxwithLabel()
                    
                    CommonButton(title: IdentifiableKeys.Buttons.kRegister) {
                        self.registerVM.registerUserApiCall {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                        print("tap Register Btn")
                    }
                }
            }
        }
    }
    
    /// `video` upload
    func Videoupload() -> some View {
        VStack {
            Button {
                self.registerVM.isShowPhotoLibrary = true
                self.isVideoImage = true
                print("tap Video upload Btn")
            } label: {
                if isShowVideos == true  {
                    if let url = self.registerVM.videoURL {
                        if let image = Utilities.getThumbnailImage(forUrl: url) {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 50, height: 50, alignment: .center)
                        }
                    }
                } else {
                    Image(IdentifiableKeys.ImageName.kVideoupload)
                        .resizable()
                        .frame(width: 50, height: 50, alignment: .center)
                }
            }
            
            Text(IdentifiableKeys.Labels.kAddIntroductionVideo)
                .font(Font.setFont(style:Constant.FontStyle.Medium, size: Constant.FontSize._12FontSize))
                .foregroundColor(Color.CustomColor.AppLabelColor)
        }        
    }
    
    /// `checkbox` with label
    func CheckboxwithLabel() -> some View {
        HStack(spacing: 1.0) {
            Button(action: {
                self.registerVM.isSelected.toggle()
                print("select dropdown menu Btn")
            }, label: {
//                Image(self.registerVM.isSelected ? IdentifiableKeys.ImageName.kCheked : colorScheme == .dark ? IdentifiableKeys.ImageName.kUncheckedWhite : IdentifiableKeys.ImageName.kUnchecked)
                Image(self.registerVM.isSelected ? IdentifiableKeys.ImageName.kCheked : IdentifiableKeys.ImageName.kUnchecked)
                    .resizable()
                    .frame(width: 23, height: 23, alignment: .center)
            })
            
            HStack(spacing: 0.0) {
                Text(IdentifiableKeys.Labels.kIAccept)
                    .foregroundColor(Color.CustomColor.AppLabelColor)
                
                Text(IdentifiableKeys.Labels.kPrivacyPolicy)
                    .foregroundColor(Color.myDarkCustomColor)
                    .onTapGesture {
                        self.registerVM.onBtnTermsPrivacy_Click(isForPrivacy: true)
                        print("Privacy Policy")
                    }
                
                Text(IdentifiableKeys.Labels.kTermsandCondition)
                    .foregroundColor(Color.myDarkCustomColor)
                    .onTapGesture(perform: {
                        self.registerVM.onBtnTermsPrivacy_Click(isForPrivacy: false)
                        print("Terms & Condition")
                    })
            }
            .font(Font.setFont(style:Constant.FontStyle.Medium, size: Constant.FontSize._14FontSize))
            .fixedSize(horizontal: true, vertical: false)
        }
    }
}

// MARK: - Previews
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
