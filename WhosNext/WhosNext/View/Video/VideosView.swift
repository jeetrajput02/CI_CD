//
//  VideosView.swift
//  WhosNext
//
//  Created by differenz195 on 18/10/22.
//

import SwiftUI
import AVKit

struct VideosView: View {
    // MARK: - Variables
    @StateObject var sidebarVM: SidebarViewModel = SidebarViewModel()
    @StateObject var shareToVM: ShareToViewModel = ShareToViewModel()
    @StateObject var notificationVM: NotificationViewModel = NotificationViewModel()

    @State  var isSideBarOpened = false
    @State var isShowActionSheet : Bool = false
    @State var selectOptionMenu: SelectOptionMenu = .selectOption
    @State var shouldPresentImagePicker: Bool = false
    @State var isPresentCamera = false
    @State var isShowVideos: Bool = false
    @State var isShowImage: UIImage?
    @State var videoURL: URL?
    @State var arrImage: [UIImage] = []
    
    @State var isGroupVideo: Bool = false

    var body: some View {
        ZStack {
            self.sideMenuNavigationLink()
            
            NavigationLink(destination: NotificationView(), isActive: $notificationVM.moveToNotification, label: {})
            NavigationLink(destination: ShareToView(isVideo: true, videoUrl: self.videoURL), isActive: self.$shareToVM.moveToShareScreen , label: {})
            NavigationLink(destination: GroupVideosView(isVideo: true, videoUrl: self.videoURL), isActive: self.$shareToVM.moveToGroupVideo , label: {})
            
            VStack {
                Spacer()
                
                VStack(alignment: .center,spacing: 10.0) {
                    Text(IdentifiableKeys.Labels.kGroupVideo)
                        .font(.custom(Constant.FontStyle.Heavy.rawValue, size: 45))
                    
                    Text("OR")
                        .font(.custom(Constant.FontStyle.Medium.rawValue, size: 32))
                    
                    Text(IdentifiableKeys.Labels.kFeedVideo)
                        .font(.custom(Constant.FontStyle.Heavy.rawValue, size: 45))
                }
                .multilineTextAlignment(.center)
                .frame(width: 130)

                Spacer()

                VStack(alignment: .trailing) {
                    HStack {
                        Spacer()
                        Button {
                            self.isShowActionSheet = true
                            self.selectOptionMenu = .selectOption
                        } label: {
                            Image(IdentifiableKeys.ImageName.kVideoinBlack)
                        }
                    }
                }
                .padding([.bottom, .trailing], 5)
            }

            SideMenuView(sidebarVM: self.sidebarVM, isSidebarVisible: self.$isSideBarOpened)
                .environment(\.moveToOtherView, self.sidebarVM.moveToView)
            
        }
        .onChange(of: self.videoURL) { newValue in
            if newValue != nil {
                if self.isGroupVideo == false {
                    self.shareToVM.onBtnShare_Click()
                } else {
                    self.shareToVM.moveToGroupVideo = true
                }
            }
        }
        .fullScreenCover(isPresented: self.$shouldPresentImagePicker) {
            CustomImagePickerView(sourceType: self.isPresentCamera ? (UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary) : .photoLibrary, isVideoAllow: self.isShowVideos, arrImage: self.$arrImage, image: self.$isShowImage ,isPresented: self.$shouldPresentImagePicker, videoURL: self.$videoURL)
        }
        .actionSheet(isPresented: self.$isShowActionSheet) {
            if self.selectOptionMenu == .selectOption {
                return ActionSheet(title: Text(""), message: Text("Select Option"), buttons: [
                    .default(Text("Group Video"), action: {
                        // Alert.show(message: "coming soon!")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                            self.isGroupVideo = true
                            self.selectOptionMenu = .browseVideos
                            self.isShowActionSheet = true
                        })
                    }),
                    .default(Text("Feed Post"), action: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                            self.isGroupVideo = false
                            self.selectOptionMenu = .browseVideos
                            self.isShowActionSheet = true
                        })
                    }),
                    .cancel()
                ])
            } else {
                return  ActionSheet(title: Text(""), message: Text("Browse Your Videos"), buttons: [
                    .default(Text("Take From Camera"), action: {
                        self.shouldPresentImagePicker = true
                        self.isPresentCamera = true
                        self.isShowVideos = true
                    }),
                    .default(Text("Select From Gallery"), action: {
                        self.shouldPresentImagePicker = true
                        self.isShowVideos = true
                        self.isPresentCamera = false
                    }),
                    .cancel()
                ])
            }
        }
        .hideNavigationBar(isSideBarMenuOpen: self.isSideBarOpened)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button {
                        self.isSideBarOpened = true
                    } label: {
                        Image(IdentifiableKeys.ImageName.kMenuBar)
                    }
                    
                    Text(IdentifiableKeys.NavigationbarTitles.kVideos)
                        .font(.custom(Constant.FontStyle.Heavy.rawValue, size: Constant.FontSize._28FontSize))
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button {
                        // self.notificationVM.onBtnNotification_Click()
                        Alert.show(message: "coming soon!")
                    } label: {
                        Image(IdentifiableKeys.ImageName.kNotification)
                    }
                }
            }
        }
    }
}

// MARK: - Helper Methods
extension VideosView {
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
}

// MARK: - Previews
struct VideosView_Previews: PreviewProvider {
    static var previews: some View {
        VideosView()
    }
}
