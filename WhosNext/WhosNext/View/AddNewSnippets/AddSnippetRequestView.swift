//
//  AddSnippetRequestView.swift
//  WhosNext
//
//  Created by differenz195 on 10/01/23.
//

import SwiftUI

struct AddSnippetRequestView: View {
    @EnvironmentObject private var viewRouter: ViewRouter

    @StateObject private var snippetVM: SnippetViewModel = SnippetViewModel()
    @StateObject private var sidebarVM: SidebarViewModel = SidebarViewModel()
    
    var snippetData: GetSnippetPermissionData?

    var body: some View {
        ZStack {
            self.sideMenuNavigationLink()

            VStack {
                Image(IdentifiableKeys.ImageName.kAppTitleText)
                    .frame(width: UIScreen.main.bounds.width - 10,height: 250, alignment: .center)
                    .background(Color.myCustomColor)

                VStack() {
                    Text("Opps! You haven't access  to create new snippets.Please request to system administrator to provide access")
                        .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal,50)
                    
                    HStack(spacing: 15.0) {
                        Button(action: {
                            self.viewRouter.currentView = .Home
                            NavigationUtil.popToRootView()
                        }, label: {
                            Text(IdentifiableKeys.Buttons.kcancel)
                                .padding(.all, 10)
                                .padding(.horizontal, 15)
                                .font(.custom(Constant.FontStyle.Bold.rawValue, size: Constant.FontSize._16FontSize))
                                .foregroundColor(Color.white)
                                .background(Color.red)
                        })
                        
                        Button(action: {
                            if self.snippetData == nil {
                                self.snippetVM.snippetSendRequest {
                                    self.viewRouter.currentView = .Home
                                    NavigationUtil.popToRootView()
                                }
                            }
                        }, label: {
                            Text(self.snippetData?.snippetRequest == 1 ? IdentifiableKeys.Buttons.kRequested : IdentifiableKeys.Buttons.kRequest)
                                .padding(.all, 10)
                                .padding(.horizontal, 15)
                                .font(.custom(Constant.FontStyle.Bold.rawValue, size: Constant.FontSize._16FontSize))
                                .foregroundColor(Color.white)
                                .background(Color.blue)
                        })
                    } .padding(.top, 20)
                }

                Spacer()
            }

            if self.snippetVM.isSideBarOpened {
                SideMenuView(sidebarVM: self.sidebarVM, isSidebarVisible: self.$snippetVM.isSideBarOpened)
                    .environment(\.moveToOtherView, self.sidebarVM.moveToView)
            }
        }
        .hideNavigationBar(isSideBarMenuOpen: self.snippetVM.isSideBarOpened)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button {
                        self.snippetVM.isSideBarOpened.toggle()
                    } label: {
                        Image(IdentifiableKeys.ImageName.kMenuBar)
                    }
                    
                    Text(IdentifiableKeys.NavigationbarTitles.kAddRequestSnippets)
                        .font(.custom(Constant.FontStyle.Heavy.rawValue, size: Constant.FontSize._28FontSize))
                    
                }
            }
        }
    }
}

// MARK: -  Helper Methods
extension AddSnippetRequestView {
    /// `side menu` navigation links
    func sideMenuNavigationLink() -> some View {
        ZStack {
            VStack {
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
                
                if self.sidebarVM.navigationLink == menuItemName.kPictures {
                    /// `move to pictures screen`
                    NavigationLink("", destination: PicturesView(), tag: menuItemName.kPictures, selection: self.$sidebarVM.navigationLink)
                }
                
                if self.sidebarVM.navigationLink == menuItemName.kSnippetsList {
                    /// `move to snippet list screen`
                    NavigationLink("", destination: SnippetsListView(), tag: menuItemName.kSnippetsList, selection: self.$sidebarVM.navigationLink)
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

                if self.sidebarVM.navigationLink == menuItemName.kHomePage {
                    /// `move to home screen`
                    NavigationLink("", destination: HomeView(), tag: menuItemName.kHomePage , selection: self.$sidebarVM.navigationLink)
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
struct AddSnippetRequestView_Previews: PreviewProvider {
    static var previews: some View {
        AddSnippetRequestView(snippetData: GetSnippetPermissionData())
    }
}

