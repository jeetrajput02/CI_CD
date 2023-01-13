//
//  PicturesView.swift
//  WhosNext
//
//  Created by differenz195 on 18/10/22.
//

import SwiftUI
import AVKit
import SDWebImageSwiftUI

struct PicturesView: View {
    @StateObject var sidebarVM: SidebarViewModel = SidebarViewModel()
    @StateObject var notificationVM: NotificationViewModel = NotificationViewModel()
    @StateObject var shareToVM: ShareToViewModel = ShareToViewModel()
    @StateObject var postToVM: PostViewModel = PostViewModel()
    
    @State var currentTabBar: Int = 0
    @State  var isSideBarOpened = false
    @State var isShowActionSheet: Bool = false
    @State var shouldPresentImagePicker: Bool = false
    @State var isPresentCamera = false
    @State var isShowImages: UIImage?
    @State var arrImage: [UIImage] = []
    @State  var isActive = false
    @State var videoURL: URL?
    
    private let columns = Array(repeating: GridItem(.adaptive(minimum: 150.0)), count: 3)

    var body: some View {
        ZStack {
            self.sideMenuNavigationLink()
            
            Group {
                NavigationLink(destination: NotificationView(), isActive: self.$notificationVM.moveToNotification, label: {})
                NavigationLink(destination: ShareToView(postImage: self.isShowImages), isActive: self.$shareToVM.moveToShareScreen , label: {})
            }
            
            VStack(alignment: .center) {
                CustomTabBarView(currentTab: self.$currentTabBar, tabBarOptions: ["PICTURES", "PICTURES OF YOU"])

                TabView(selection: self.$currentTabBar) {
                    self.picturesView().tag(0)
                    self.picturesForYou().tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }

            SideMenuView(sidebarVM: self.sidebarVM, isSidebarVisible: self.$isSideBarOpened)
                .environment(\.moveToOtherView, self.sidebarVM.moveToView)
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
                    
                    Text(IdentifiableKeys.NavigationbarTitles.kPosts)
                        .font(.custom(Constant.FontStyle.Heavy.rawValue, size: Constant.FontSize._28FontSize))
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button {
                        // self.notificationVM.onBtnNotification_Click()
                        print("tap notification")
                        Alert.show(message: "coming soon!")
                    } label: {
                        Image(IdentifiableKeys.ImageName.kNotification)
                    }

                    Button {
                        self.postToVM.gridPostApi(type: self.currentTabBar == 0 ? "1" : "2") {}
                    } label: {
                        Image(IdentifiableKeys.ImageName.kBlackRefresh)
                    }
                }
            }
        }
        .onAppear {
            self.postToVM.gridPostApi(type: self.currentTabBar == 0 ? "1" : "2") {}
        }
        .onChange(of: self.currentTabBar , perform: { newValue in
            self.postToVM.gridPostApi(type: self.currentTabBar == 0 ? "1" : "2") {}
        })
        .onChange(of: self.isShowImages) { newValue in
            if newValue != nil {
                self.shareToVM.onBtnShare_Click()
            }
        }
        .fullScreenCover(isPresented: self.$shouldPresentImagePicker) {
            CustomImagePickerView(sourceType: self.isPresentCamera ? (UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary) : .photoLibrary, arrImage: self.$arrImage, image: self.$isShowImages, isPresented: self.$shouldPresentImagePicker, videoURL: self.$videoURL)
        }
        .confirmationDialog("", isPresented: self.$isShowActionSheet, actions: {
            Button(action: {
                self.shouldPresentImagePicker = true
                self.isPresentCamera = true
            }, label: { Text("Take From Camera") })

            Button(action: {
                self.shouldPresentImagePicker = true
                self.isPresentCamera = false
            }, label: { Text("Select From Library") })
        }, message: { Text("Browse Your Photos") })
    }
}

// MARK: - UI Helpers
extension PicturesView {
    /// `pictures` view
    func picturesView() -> some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack {
                    LazyVGrid(columns: self.columns, spacing: 10) {
                        if let arrImage = self.$postToVM.arrImage.wrappedValue?.data {
                            ForEach(arrImage, id: \.self) { image in
                                NavigationLink(destination: {
                                    PictureDetailsView(postId: "\(image.postID)", postType: 1)
                                }, label: {
                                    WebImage(url: URL(string: image.postThumbnail))
                                        .resizable()
                                        .indicator(.activity)
                                        .aspectRatio(1, contentMode: .fill)
                                })
                            }
                        }
                    }
                    .padding(.horizontal, 5)
                    .padding(.top, 10)
                    
                    Spacer()
                }
            }
            
            VStack(alignment: .trailing) {
                HStack {
                    Spacer()
                    
                    Button {
                        self.isShowActionSheet = true
                    } label: {
                        Image(IdentifiableKeys.ImageName.kCameraBlack)
                    }
                }
                .padding([.trailing], 10)
            }
        }
    }
    
    /// `puctures for you` view
    func picturesForYou() -> some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack {
                    LazyVGrid(columns: self.columns, spacing: 10) {
                        if let arrImage = self.$postToVM.arrImage.wrappedValue?.data {
                            ForEach(arrImage, id: \.self) { image in
                                NavigationLink(destination: {
                                    PictureDetailsView(postId: "\(image.postID)", postType: 1)
                                }, label: {
                                    WebImage(url: URL(string: image.postThumbnail))
                                        .resizable()
                                        .indicator(.activity)
                                        .aspectRatio(1, contentMode: .fill)
                                })
                            }
                        }
                    }
                    .padding(.horizontal, 5)
                    .padding(.top, 10)
                    
                    Spacer()
                }
            }
            
            VStack(alignment: .trailing) {
                HStack {
                    Spacer()
                    
                    Button {
                        self.isShowActionSheet = true
                    } label: {
                        Image(IdentifiableKeys.ImageName.kCameraBlack)
                    }
                }
                .padding([.trailing], 10)
            }
        }
    }
}

// MARK: - Helper Methods
extension PicturesView{
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

                if self.sidebarVM.navigationLink == menuItemName.kSnippetsList {
                    /// `move to snippet list screen`
                    NavigationLink("", destination: SnippetsListView(), tag: menuItemName.kSnippetsList, selection: self.$sidebarVM.navigationLink)
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
struct PicturesView_Previews: PreviewProvider {
    static var previews: some View {
        PicturesView()
    }
}
