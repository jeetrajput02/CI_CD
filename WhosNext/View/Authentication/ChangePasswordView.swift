//
//  ChangePasswordView.swift
//  WhosNext
//
//  Created by differenz243 on 06/10/22.
//

import SwiftUI
import AVKit

struct ChangePasswordView: View {
    // MARK: - Variables
    @EnvironmentObject private var viewRouter: ViewRouter

    @StateObject var changePasswordVM: ChangePasswordViewModel = ChangePasswordViewModel()
    @StateObject var sidebarVM: SidebarViewModel = SidebarViewModel()

    @FocusState private var focusState: CommonTextFieldFocusState?

    @State  var isSideBarOpened = false
        
    var body: some View {
        ZStack {
            NavigationLink(destination: LoginView(), isActive: self.$changePasswordVM.moveToLogin, label: {})
            self.sideMenuNavigationLink()
            
            VStack {
                Image(IdentifiableKeys.ImageName.kAppTitleText)
                    .frame(height: 50, alignment: .center)
                    .padding(.horizontal, 35)
                Spacer()
                
                self.bottomView()
            }
            .navigationBarItems(leading: HStack {
                Button {
                    self.isSideBarOpened.toggle()
                } label: {
                    Image(IdentifiableKeys.ImageName.kMenuBar)
                }
            })
            .alert(isPresented: self.$changePasswordVM.showingError) {
                Alert(title: Text(""), message: Text(self.changePasswordVM.errorMessage), dismissButton: .default(Text("OK")) {
                })
            }
            .gesture(DragGesture(minimumDistance: 10, coordinateSpace: .global)
                .onEnded({ value in
                    withAnimation {
                        if value.translation.width > 0 {
                            self.isSideBarOpened.toggle()
                        }
                    }
                }))
            .navigationBarColor(backgroundColor: UIColor(Color("uniColor")))

            SideMenuView(sidebarVM: self.sidebarVM, isSidebarVisible: self.$isSideBarOpened)
                .environment(\.moveToOtherView, self.sidebarVM.moveToView)
        }
        .background(Color.clear)
        .gesture(DragGesture(minimumDistance: 10, coordinateSpace: .global)
            .onEnded({ value in
                withAnimation {
                    if value.translation.width > 0 {
                        self.isSideBarOpened.toggle()
                    }
                }
            }))
        .hideNavigationBar(isSideBarMenuOpen: self.isSideBarOpened)
    }
}

//MARK: -  Helper Methods
extension ChangePasswordView {
    /// `side menu` navigation links
    func sideMenuNavigationLink() -> some View {
        ZStack {
            VStack {
                if self.sidebarVM.navigationLink == menuItemName.kHomePage {
                    /// `move to home screen`
                    NavigationLink("", destination: HomeView(), tag: menuItemName.kHomePage , selection: self.$sidebarVM.navigationLink)
                }
                
                if self.sidebarVM.navigationLink == menuItemName.kMyProfile {
                    /// `move to profile screen`
                    NavigationLink("", destination: ProfileView(), tag: menuItemName.kMyProfile, selection: self.$sidebarVM.navigationLink)
                }
                
                if self.sidebarVM.navigationLink == menuItemName.kAddNewSnippets {
                    if self.sidebarVM.snippetData.data?.snippetRequest == 2 {
                        /// `move to add new snippet screen`
                        NavigationLink("", destination: AddNewSnippetView(), tag: menuItemName.kAddNewSnippets , selection: self.$sidebarVM.navigationLink)
                    } else {
                        /// `move to snippet request screen`
                        NavigationLink("", destination: AddSnippetRequestView(snippetData: self.sidebarVM.snippetData.data), tag: menuItemName.kAddNewSnippets , selection: self.$sidebarVM.navigationLink)
                    }
                }
                
                if self.sidebarVM.navigationLink == menuItemName.kVideos {
                    /// `move to videos screen`
                    NavigationLink("", destination: VideosView(), tag: menuItemName.kVideos, selection: self.$sidebarVM.navigationLink)
                }
                
                if self.sidebarVM.navigationLink == menuItemName.kPictures {
                    /// `move to pictures screen`
                    NavigationLink("", destination: PicturesView(), tag: menuItemName.kPictures, selection: self.$sidebarVM.navigationLink)
                }
            }

            VStack {
                if self.sidebarVM.navigationLink == menuItemName.kFeturedProfiles {
                    /// `move to featured profiles screen`
                    NavigationLink("", destination: FeaturedProfileView(), tag: menuItemName.kFeturedProfiles, selection: self.$sidebarVM.navigationLink)
                }
                
                if self.sidebarVM.navigationLink == menuItemName.kBreastCancerLegacies {
                    /// `move to breast cancerlegacies screen`
                    NavigationLink("", destination: BreastCancerLegaciesView(), tag: menuItemName.kBreastCancerLegacies, selection: self.$sidebarVM.navigationLink)
                }
                
                if self.sidebarVM.navigationLink == menuItemName.kDiscover {
                    /// `move to discover people screen`
                    NavigationLink("", destination: DiscoverPeopleView(), tag: menuItemName.kDiscover, selection: self.$sidebarVM.navigationLink)
                }
                
                if self.sidebarVM.navigationLink == menuItemName.kMessaging {
                    /// `move to message screen`
                    NavigationLink("", destination: MessageView(), tag: menuItemName.kMessaging, selection: self.$sidebarVM.navigationLink)
                }

                if self.sidebarVM.navigationLink == menuItemName.kSnippetsUploadAccess {
                    /// `move to message screen`
                    NavigationLink("", destination: SnippetRequestView(), tag: menuItemName.kSnippetsUploadAccess, selection: self.$sidebarVM.navigationLink)
                }
            }

            VStack {
                if let user = UserDefaults.getData(UserDefaultsKey.kLoginUser, data: UserModel.self) {
                    if user.userType == 0 {
                        if self.sidebarVM.navigationLink == menuItemName.kCity {
                            /// `move to city screen`
                            NavigationLink("", destination: CityView(), tag: menuItemName.kCity, selection: self.$sidebarVM.navigationLink)
                        }
                        
                        if self.sidebarVM.navigationLink == menuItemName.kCategory {
                            /// `move to category screen`
                            NavigationLink("", destination: CategoryView(), tag: menuItemName.kCategory, selection: self.$sidebarVM.navigationLink)
                        }
                        
                        if self.sidebarVM.navigationLink == menuItemName.kSnippetsList {
                            /// `move to snippet list screen`
                            NavigationLink("", destination: SnippetsListView(), tag: menuItemName.kSnippetsList, selection: self.$sidebarVM.navigationLink)
                        }
                    }
                }
            }
        }
    }
    
    /// `bottom` view
    func bottomView() -> some View {
        VStack(alignment: .center) {
            CommonTextField(placeholderText: IdentifiableKeys.Labels.kCurrentPassword, isSecuredField: true, text: self.$changePasswordVM.curentPassword, focusState: self.$focusState, currentFocus: .constant(.currentPassword), onCommit: {
                self.focusState = .newPassword
            })
            .submitLabel(.next)
            
            CommonTextField(placeholderText: IdentifiableKeys.Labels.kNewPassword, isSecuredField: true, text: self.$changePasswordVM.newPassword, focusState: self.$focusState, currentFocus: .constant(.newPassword), onCommit: {
                self.focusState = .confirmPassword
            })
            .submitLabel(.next)
            
            CommonTextField(placeholderText: IdentifiableKeys.Labels.kRetypeNewPassword, isSecuredField: true, text: self.$changePasswordVM.confirmPassword, focusState: self.$focusState, currentFocus: .constant(.confirmPassword), onCommit: {
                self.focusState = nil
            })
            .submitLabel(.done)

            CommonButton(title: IdentifiableKeys.Buttons.kUpdate, disabled: false, backgroundColor: Color.black, foregroundColor: Color.white, cornerradius: 5, fontSizes: Constant.FontSize._20FontSize, fontStyles: Constant.FontStyle.Medium, showImage: false) {
                if self.changePasswordVM.isValidUserinput() {
                    self.changePasswordVM.changePasswordApiCall { message in
                        self.viewRouter.currentView = .Login
                        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.kLoginUser)
                        
                        NavigationUtil.popToRootView()
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: UInt64(1.0))) {
                            Alert.show(title: "", message: message)
                        }
                    }
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
struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordView()
    }
}
