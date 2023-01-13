//
//  EditProfileView.swift
//  WhosNext
//
//  Created by differenz195 on 12/10/22.
//

import SwiftUI
import AVKit
import SDWebImageSwiftUI

struct EditProfileView: View {
    // MARK: - Variables
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var profileVM: ProfileViewModel

    @FocusState private var focusState: CommonTextFieldFocusState?
    
    var body: some View {
        ScrollView {
            VStack {
                self.userInfoSection()
                self.websiteSection()
                self.categorySection()
                self.videoSection()
                self.aboutSection()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: HStack {
            Button {
                self.presentationMode.wrappedValue.dismiss()
            } label: {
                Image(IdentifiableKeys.ImageName.kBackArrowBlack)
            }
            
            Text(IdentifiableKeys.NavigationbarTitles.kEditProfile)
                .font(.custom(Constant.FontStyle.Heavy.rawValue, size: Constant.FontSize._28FontSize))
        })
        .navigationBarColor(backgroundColor: UIColor(named: "uniColor"))
        .onAppear {
            /// `api call` to get `cities`
            self.profileVM.getCities { cityModel in
                if let model = self.profileVM.profileModel {
                    DispatchQueue.main.async {
                        if let city = self.profileVM.cityModel?.data.filter({ "\($0.cityID)" == model.data.cityID }) {
                            self.profileVM.selectedCity = city.first
                        }

                        /// `api call` to get `categories`
                        if self.profileVM.categoryList.count == 0 {
                            self.profileVM.getCategoryList { categoryList in
                                DispatchQueue.main.async {
                                    if model.data.categoryID != "" {
                                        self.profileVM.selectedCategories.removeAll()
                                        
                                        if let categoryArr = self.profileVM.profileModel?.data.categoryArr {
                                            for category in categoryArr {
                                                let dict = [
                                                    selectTalentModelKey.categoryId: category.categoryID,
                                                    selectTalentModelKey.category: category.category
                                                ] as [String: Any]
                                                let tempCategory = SelectTalentModel(Dict: dict)
                                                
                                                self.profileVM.selectedCategories.append(tempCategory)
                                            }
                                            
                                            self.profileVM.category = self.profileVM.selectedCategories.map({
                                                $0.categoryId == -1 ? "\($0.category)" : "\($0.categoryId)"
                                            }).joined(separator: ",")
                                        }
                                    }
                                }
                            }
                        }
                        
                        self.profileVM.firstName = model.data.firstName
                        self.profileVM.lasttName = model.data.lastName
                        self.profileVM.userName = model.data.username
                        self.profileVM.email = model.data.email
                        self.profileVM.city = model.data.city

                        self.profileVM.website1 = model.data.websiteURL1 == "" ? "http://" : model.data.websiteURL1
                        self.profileVM.website2 = model.data.websiteURL2 == "" ? "http://" : model.data.websiteURL2
                        self.profileVM.website3 = model.data.websiteURL3 == "" ? "http://" : model.data.websiteURL3
                        self.profileVM.website4 = model.data.websiteURL4 == "" ? "http://" : model.data.websiteURL4
                        self.profileVM.website5 = model.data.websiteURL5 == "" ? "http://" : model.data.websiteURL5
                        
                        if model.data.aboutSelf != "" {
                            self.profileVM.aboutSelf = model.data.aboutSelf
                        }
                        
                        self.focusState = .firstName
                        
                        Indicator.hide()
                    }
                }
            }
        }
        .fullScreenCover(isPresented: self.$profileVM.videoSheet) {
            if self.profileVM.videoURL != nil {
                PlayerViewController(videoURL: self.profileVM.videoURL!)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .fullScreenCover(isPresented: self.$profileVM.shouldPresentImagePicker) {
            CustomImagePickerView(sourceType: self.profileVM.isPresentCamera ? (UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary) : .photoLibrary, isVideoAllow: self.profileVM.isShowVideos, arrImage: self.$profileVM.arrImage, image: self.$profileVM.isShowImage ,isPresented: self.$profileVM.shouldPresentImagePicker, videoURL: self.$profileVM.videoURL)
        }
        .actionSheet(isPresented: self.$profileVM.isShowPhotosLibrary) { () -> ActionSheet in
            ActionSheet(
                title: Text(""),
                message: Text("Browse Your Videos"),
                buttons: [
                    .default(Text("Capture Video"), action: {
                        self.profileVM.isShowVideos = true
                        self.profileVM.shouldPresentImagePicker = true
                        self.profileVM.isPresentCamera = true
                    }),
                    .default(Text("Pick Video From Gallery"), action: {
                        self.profileVM.shouldPresentImagePicker = true
                        self.profileVM.isPresentCamera = false
                        self.profileVM.isShowVideos = true
                    }),
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: self.$profileVM.isShowSheet, onDismiss: {
            DispatchQueue.main.async {
                self.profileVM.category = self.profileVM.selectedCategories.map({
                    $0.categoryId == -1 ? "\($0.category)" : "\($0.categoryId)"
                }).joined(separator: ",")
            }
        }) {
            SelectTalentList(categoryListModel: self.$profileVM.categoryList, selectedCategories: self.$profileVM.selectedCategories, isFromRegister: false)
        }
        .sheet(isPresented: self.$profileVM.isShowCitySheet, onDismiss: {
            self.profileVM.city = self.profileVM.selectedCity?.city ?? ""
        }) {
            SelectCitySheet(cityModel: self.$profileVM.cityModel, selectedCity: self.$profileVM.selectedCity)
        }
        .alert(isPresented: self.$profileVM.isOpenValidationAlert) {
            Alert(
                title: Text(""),
                message: Text(self.profileVM.validationAlertMsg),
                dismissButton: .default(Text("OK")) {}
            )
        }
    }
}

// MARK: - UI Helpers
extension EditProfileView {
    /// `user info` section
    func userInfoSection() -> some View {
        VStack {
            CommonEditProfileText(text: IdentifiableKeys.Labels.kFirstName)
            CommonEditProfileTextField(placeholderText: IdentifiableKeys.Labels.kFirstName, text: self.$profileVM.firstName, focusState: self.$focusState, currentFocus: .constant(.firstName), onCommit: {
                self.focusState = .lastName
            })
            .submitLabel(.next)
            .onChange(of: self.profileVM.firstName, perform: { firstName in
                if firstName.last == " " {
                    self.profileVM.firstName.removeLast()
                }
            })
            
            CommonEditProfileText(text: IdentifiableKeys.Labels.kLastName)
            CommonEditProfileTextField(placeholderText: IdentifiableKeys.Labels.kLastName, text: self.$profileVM.lasttName, focusState: self.$focusState, currentFocus: .constant(.lastName), onCommit: {
                self.focusState = .username
            })
            .submitLabel(.next)
            .onChange(of: self.profileVM.lasttName, perform: { lasttName in
                if lasttName.last == " " {
                    self.profileVM.lasttName.removeLast()
                }
            })
            
            CommonEditProfileText(text: IdentifiableKeys.Labels.kUsername)
            CommonEditProfileTextField(placeholderText: IdentifiableKeys.Labels.kUsername, text: self.$profileVM.userName, focusState: self.$focusState, currentFocus: .constant(.username), onCommit: {
                self.focusState = .email
            })
            .submitLabel(.next)
            .onChange(of: self.profileVM.userName, perform: { userName in
                if userName.last == " " {
                    self.profileVM.userName.removeLast()
                }
            })
            
            VStack {
                CommonEditProfileText(text: IdentifiableKeys.Labels.kEmail)
                CommonEditProfileTextField(placeholderText: IdentifiableKeys.Labels.kEmail, text: self.$profileVM.email, focusState: self.$focusState, currentFocus: .constant(.email), onCommit: {
                    self.focusState = .website1
                })
                .submitLabel(.next)
                .keyboardType(.emailAddress)
                .onChange(of: self.profileVM.email, perform: { email in
                    if email.last == " " {
                        self.profileVM.email.removeLast()
                    }
                })
                
                self.citySection()
            }
        }
    }
    
    /// `website` section
    func websiteSection() -> some View{
        VStack(spacing: 5) {
            CommonEditProfileText(text: IdentifiableKeys.Labels.kWebsite)
            
            VStack {
                CommonEditProfileTextField(placeholderText: IdentifiableKeys.Labels.kWebsite1, text: self.$profileVM.website1, focusState: self.$focusState, currentFocus: .constant(.website1), onCommit: {
                    self.focusState = .website2
                })
                .submitLabel(.next)
                .onChange(of: self.profileVM.website1, perform: { website1 in
                    if website1.last == " " {
                        self.profileVM.website1.removeLast()
                    }
                })

                CommonEditProfileTextField(placeholderText: IdentifiableKeys.Labels.kWebsite2, text: self.$profileVM.website2, focusState: self.$focusState, currentFocus: .constant(.website2), onCommit: {
                    self.focusState = .website3
                })
                .submitLabel(.next)
                .onChange(of: self.profileVM.website2, perform: { website2 in
                    if website2.last == " " {
                        self.profileVM.website2.removeLast()
                    }
                })

                CommonEditProfileTextField(placeholderText: IdentifiableKeys.Labels.kWebsite3, text: self.$profileVM.website3, focusState: self.$focusState, currentFocus: .constant(.website3), onCommit: {
                    self.focusState = .website4
                })
                .submitLabel(.next)
                .onChange(of: self.profileVM.website3, perform: { website3 in
                    if website3.last == " " {
                        self.profileVM.website3.removeLast()
                    }
                })

                CommonEditProfileTextField(placeholderText: IdentifiableKeys.Labels.kWebsite4, text: self.$profileVM.website4, focusState: self.$focusState, currentFocus: .constant(.website4), onCommit: {
                    self.focusState = .website5
                })
                .submitLabel(.next)
                .onChange(of: self.profileVM.website4, perform: { website4 in
                    if website4.last == " " {
                        self.profileVM.website4.removeLast()
                    }
                })

                CommonEditProfileTextField(placeholderText: IdentifiableKeys.Labels.kWebsite5, text: self.$profileVM.website5, focusState: self.$focusState, currentFocus: .constant(.website5), onCommit: {
                    self.focusState = nil
                })
                .submitLabel(.done)
                .onChange(of: self.profileVM.website5, perform: { website5 in
                    if website5.last == " " {
                        self.profileVM.website5.removeLast()
                    }
                })
            }
            .foregroundColor(.blue)
        }
        
    }
    
    /// `city` section
    func citySection() -> some View {
        VStack {
            CommonEditProfileText(text: IdentifiableKeys.Labels.kCity)
            
            HStack {
                Text("      \(self.profileVM.city == "" ? "No city selected" : self.profileVM.city)")
                    .allowsHitTesting(false)
                    .padding(.leading, 10)
                    .frame(width: ScreenSize.SCREEN_WIDTH, height: 40, alignment: .leading)
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
                Spacer()
                Image(IdentifiableKeys.ImageName.kDropdown)
                    .resizable()
                    .frame(width: 12, height: 12, alignment: .trailing)
                    .padding(.trailing, 40)
            }
            .background(Color.appSnippetsColor)
        }
        .onTapGesture {
            self.profileVM.isShowCitySheet.toggle()
        }
    }
    
    /// `category` section
    func categorySection() -> some View {
        VStack {
            CommonEditProfileText(text: IdentifiableKeys.Labels.kCategory)
            
            HStack {
                let category = self.profileVM.selectedCategories.map({ $0.category }).joined(separator: ",")
                
                Text("      \(category == "" ? "No categories selected!" : category)")
                    .lineLimit(2)
                    .allowsHitTesting(false)
                    .padding(.leading, 10)
                    .frame(width: ScreenSize.SCREEN_WIDTH, height: 40, alignment: .leading)
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize ))
                Spacer()
                Image(IdentifiableKeys.ImageName.kDropdown)
                    .resizable()
                    .frame(width: 12, height: 12, alignment: .trailing)
                    .padding(.trailing, 40)
            }
            .background(Color.appSnippetsColor)
        }
        .onTapGesture {
            self.profileVM.isShowSheet = true
        }
    }
    
    /// `video` section
    func videoSection() -> some View {
        LazyVStack(spacing: 2) {
            HStack {
                Text(IdentifiableKeys.Labels.kIntroductionBioVideo)
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._20FontSize))
                    .padding(.leading, 42)

                Spacer()

                Text(self.profileVM.videoURL == nil  ? IdentifiableKeys.Buttons.kSelectVideo : IdentifiableKeys.Buttons.kReplaceVideo)
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._20FontSize))
                    .padding(.trailing, 45)
                    .onTapGesture {
                        self.profileVM.isShowPhotosLibrary.toggle()
                    }
            }

            if self.profileVM.videoURL?.absoluteString.contains("http") == false {
                if let image = Utilities.getThumbnailImage(forUrl: self.profileVM.videoURL ?? URL(fileURLWithPath: "")) {
                    Image(uiImage: image)
                        .resizable()
                        .frame(height: 300)
                        .onTapGesture {
                            self.profileVM.videoSheet.toggle()
                        }
                }
            } else {
                if self.profileVM.videoThumbnailURL != nil {
                    WebImage(url: self.profileVM.videoThumbnailURL)
                        .placeholder(Image(IdentifiableKeys.ImageName.kAppBanner).resizable())
                        .resizable()
                        .indicator(.activity)
                        .frame(width: ScreenSize.SCREEN_WIDTH, height: 300)
                    .onTapGesture {
                        self.profileVM.videoSheet.toggle()
                    }
                }
            }
        }
    }
    
    /// `about self` section
    func aboutSection() -> some View {
        VStack {
            ZStack(alignment: .topLeading) {
                TextEditor(text: Binding(self.$profileVM.aboutSelf, replacingNilWith: ""))
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
                    .colorMultiply(Color.appSnippetsColor)
                    .frame(alignment: .leading)
                
                Text(self.profileVM.aboutSelf ?? IdentifiableKeys.Labels.kDescribeyourself)
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
                    .foregroundColor(Color.secondary.opacity(0.5))
                    .opacity(self.profileVM.aboutSelf  == nil ? 1 : 0)
                    .padding([.horizontal], 4)
                    .padding(.vertical, 10)
            }
            .frame(width: ScreenSize.SCREEN_WIDTH, height: 100, alignment: .center)
            .background(Color.appSnippetsColor)
            .onChange(of: self.profileVM.aboutSelf, perform: { aboutSelf in
                if aboutSelf?.last == " " {
                    self.profileVM.aboutSelf?.removeLast()
                }
            })
            
            /// `update` button
            VStack {
                CommonButton(title: IdentifiableKeys.Buttons.kUpdate) {
                    self.profileVM.updateUserProfile {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            self.presentationMode.wrappedValue.dismiss()
                        })
                    }
                }
            }
            .padding(.top, 20)
        }
    }
}

// MARK: - Previews
struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
    }
}
