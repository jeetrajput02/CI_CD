//
//  MessageView.swift
//  WhosNext
//
//  Created by differenz195 on 21/10/22.
//

import SwiftUI
import AVKit

struct MessageView: View {
    /// `variables`
    @State  var isSideBarOpened = false
    @StateObject var sidebarVM: SidebarViewModel = SidebarViewModel()
    @StateObject var notificationVM: NotificationViewModel = NotificationViewModel()

    var body: some View {
        ZStack {
            self.sideMenuNavigationLink()

            Group {
                NavigationLink(destination: NotificationView(), isActive: $notificationVM.moveToNotification, label: {})
            }

            VStack {
                Image(IdentifiableKeys.ImageName.kNoPostUserLogo)
                    .resizable()
                    .frame(width: 40,height: 40)
                
                Text("No chat user found.")
            }
            
            SideMenuView(sidebarVM: self.sidebarVM, isSidebarVisible: self.$isSideBarOpened)
                .environment(\.moveToOtherView, self.sidebarVM.moveToView)
        }
        .hideNavigationBar(isSideBarMenuOpen: self.isSideBarOpened)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button {
                        self.isSideBarOpened.toggle()
                    } label: {
                        Image(IdentifiableKeys.ImageName.kMenuBar)
                    }
                }
            }

            ToolbarItem(placement: .principal) {
                HStack {
                    Text(IdentifiableKeys.NavigationbarTitles.kMessages)
                        .font(.custom(Constant.FontStyle.Heavy.rawValue, size: Constant.FontSize._28FontSize))

                    Spacer()

                    HStack(spacing: 2) {
                        Button {
                            self.notificationVM.onBtnNotification_Click()
                            print("******** tap notification ********")
                        } label: {
                            Image(IdentifiableKeys.ImageName.kNotification)
                                .resizable()
                                .frame(width: 20, height: 20, alignment: .center)
                        }

                        Button {
                            print("******** tap search ********")
                        } label: {
                            Image(IdentifiableKeys.ImageName.kBlackSearch)
                                .resizable()
                                .frame(width: 20, height: 20, alignment: .center)
                        }
                        
                        Button {
                            print("******** tap refresh ********")
                        } label: {
                            Image(IdentifiableKeys.ImageName.kBlackRefresh)
                                .resizable()
                                .frame(width: 20, height: 20, alignment: .center)
                        }
                    }
                }
                
            }
        }
    }
}

// MARK: - Helper Methods
extension MessageView {
    /// `side menu` navigation links
    func sideMenuNavigationLink() -> some View {
        ZStack {
            VStack {
                if self.sidebarVM.navigationLink == menuItemName.kHomePage {
                    /// `move to home screen`
                    NavigationLink("", destination: HomeView(), tag: menuItemName.kHomePage , selection: self.$sidebarVM.navigationLink)
                }
                
                if self.sidebarVM.navigationLink == menuItemName.kChangePassword {
                    /// `move to change password screen`
                    NavigationLink("", destination: ChangePasswordView(), tag: menuItemName.kChangePassword, selection: self.$sidebarVM.navigationLink)
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
            }
            
            VStack {
                if self.sidebarVM.navigationLink == menuItemName.kPictures {
                    /// `move to pictures screen`
                    NavigationLink("", destination: PicturesView(), tag: menuItemName.kPictures, selection: self.$sidebarVM.navigationLink)
                }
                
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
                    }
                }
            }
        }
    }
}

// MARK: - Previews
struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView()
    }
}
