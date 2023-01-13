//
//  SnippetRequestView.swift
//  WhosNext
//
//  Created by differenz240 on 10/01/23.
//

import SwiftUI

struct SnippetRequestView: View {
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    @StateObject private var snippetVM: SnippetViewModel = SnippetViewModel()
    @StateObject private var sidebarVM: SidebarViewModel = SidebarViewModel()

    var body: some View {
        ZStack {
            self.sideMenuNavigationLink()

            SnippetRequestList(snippetVM: self.snippetVM)

            if self.snippetVM.isSideBarOpened {
                SideMenuView(sidebarVM: self.sidebarVM, isSidebarVisible: self.$snippetVM.isSideBarOpened)
                    .environment(\.moveToOtherView, self.sidebarVM.moveToView)
            }
        }
        .hideNavigationBar(isSideBarMenuOpen: self.snippetVM.isSideBarOpened)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button(action: {
                        self.snippetVM.isSideBarOpened.toggle()
                    }, label: {
                        Image(IdentifiableKeys.ImageName.kMenuBar)
                    })

                    Text(IdentifiableKeys.NavigationbarTitles.kFollowRequest)
                        .foregroundColor(Color.myDarkCustomColor)
                        .font(.custom(Constant.FontStyle.Heavy.rawValue, size: Constant.FontSize._22FontSize))
                }
            }
        }
        .onAppear {
            self.snippetVM.getSnippetRequestList()
        }
    }
}

// MARK: - Custom Views
private extension SnippetRequestView {
    struct SnippetRequestList: View {
        @StateObject var snippetVM: SnippetViewModel

        var body: some View {
            ScrollView(showsIndicators: false) {
                LazyVStack {
                    ForEach(self.$snippetVM.snippetRequestList) { $snippetRequest in
                        VStack {
                            HStack {
                                Text(snippetRequest.username ?? "")
                                    .font(.custom(Constant.FontStyle.Bold.rawValue, size: Constant.FontSize._14FontSize))
                                
                                Spacer()
                                
                                HStack(spacing: 12.0) {
                                    Button(action: {
                                        self.snippetVM.acceptRejectSnippetRequest(userId: snippetRequest.userID ?? 0, status: 2, completion: {
                                            self.snippetVM.getSnippetRequestList()
                                        })
                                    }, label: {
                                        Image("approve")
                                            .resizable()
                                            .frame(width: 22.0, height: 22.0)
                                    })
                                    
                                    Button(action: {
                                        self.snippetVM.acceptRejectSnippetRequest(userId: snippetRequest.userID ?? 0, status: 3, completion: {
                                            self.snippetVM.getSnippetRequestList()
                                        })
                                    }, label: {
                                        Image("disapprove")
                                            .resizable()
                                            .frame(width: 22.0, height: 22.0)
                                    })
                                }
                            }
                            
                            RoundedRectangle(cornerRadius: 0)
                                .frame(height: 1.5)
                                .foregroundColor(Color.appSnippetsColor)
                        }
                        .padding(.all, 12.0)
                    }
                }
            }
            .padding(.top, 8.0)
        }
    }
}

// MARK: -  Helper Methods
extension SnippetRequestView {
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
struct SnippetUploadAccessRequestView_Previews: PreviewProvider {
    static var previews: some View {
        SnippetRequestView()
    }
}
