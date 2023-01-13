//
//  ProfileView.swift
//  WhosNext
//
//  Created by differenz195 on 11/10/22.
//

import SwiftUI
import AVKit
import SDWebImageSwiftUI

struct ProfileView: View {
    // MARK: - Variables
    @Environment(\.dismiss) private var dismiss: DismissAction
    @EnvironmentObject private var viewRouter: ViewRouter
    
    @StateObject  var sidebarVM: SidebarViewModel = SidebarViewModel()
    @StateObject var profileVM: ProfileViewModel = ProfileViewModel()
    
    @State var postHeight: Double = 0

    private let columns = Array(repeating: GridItem(.flexible()), count: 3)
    
    var userId: Int? = nil
    var userFullName: String? = nil
    var isShowbackBtn: Bool? = false

    var body: some View {
        ZStack {
            self.sideMenuNavigationLink()
            
            Group {
                NavigationLink(destination: EditProfileView().environmentObject(self.profileVM), isActive: self.$profileVM.moveToEditProfile , label: {})
                NavigationLink(destination: FollowersView(userId: self.userId), isActive: self.$profileVM.moveToFollowers, label: {})
                NavigationLink(destination: FollowingView(userId: self.userId), isActive: self.$profileVM.moveToFollowing, label: {})
                NavigationLink(destination: PostView(userId: self.userId), isActive: self.$profileVM.moveToPosts, label: {})
            }
            
            VStack {
                ScrollView(showsIndicators: false) {
                    VStack {
                        if let model = self.profileVM.profileModel {
                            self.topView()
                            self.followerSection()

                            if let currentUser = UserDefaults.getData(UserDefaultsKey.kLoginUser, data: UserModel.self) {
                                if model.data.isPrivate == false || model.data.isFollowing == 2 {
                                    if model.data.introductionVideo != "" {
                                        self.videoSection()
                                    } else {
                                        Spacer().frame(height: 8.0)
                                    }
                                    
                                    self.aboutSelfSection()
                                    
                                    if model.data.groupVideos?.count != 0 {
                                        self.groupVideo()
                                    }
                                } else {
                                    if currentUser.userId == model.data.userID {
                                        if model.data.introductionVideo != "" {
                                            self.videoSection()
                                        } else {
                                            Spacer().frame(height: 8.0)
                                        }
                                        
                                        self.aboutSelfSection()
                                        
                                        if model.data.groupVideos?.count != 0 {
                                            self.groupVideo()
                                        }
                                    } else {
                                        Spacer(minLength: 20.0)

                                        VStack {
                                            Image(systemName: "person.circle")
                                                .resizable()
                                                .frame(width: 40.0, height: 40.0, alignment: .center)
                                                .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._20FontSize))
                                            
                                            Text("This user is private")
                                                .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._20FontSize))
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 10.0)
                }
            }
            .padding(.bottom, 10)
            .gesture(DragGesture(minimumDistance: 10, coordinateSpace: .global)
                .onEnded({ value in
                    withAnimation {
                        if value.translation.width > 0 {
                            self.profileVM.isSideBarOpened.toggle()
                        }
                    }
                })
            )

            if self.profileVM.isSideBarOpened {
                SideMenuView(sidebarVM: self.sidebarVM, isSidebarVisible: self.$profileVM.isSideBarOpened)
                    .environment(\.moveToOtherView, self.sidebarVM.moveToView)
            }
        }
        .navigationBarBackButtonHidden(true)
        .hideNavigationBar(isSideBarMenuOpen: self.profileVM.isSideBarOpened)
        .navigationBarColor(backgroundColor: UIColor(named: "uniColor"))
        .onAppear {
            guard let currentUser = UserDefaults.getData(UserDefaultsKey.kLoginUser, data: UserModel.self) else { return }
            
            if self.profileVM.videoURL != nil && self.profileVM.videoThumbnailURL != nil {
                self.profileVM.videoURL = nil
                self.profileVM.videoThumbnailURL = nil
            }
            
            if self.userId == nil {
                self.profileVM.userId = currentUser.userId
            } else {
                self.profileVM.userId = self.userId ?? -1
            }
            
            self.profileVM.profileViewCount(userId: "\(self.profileVM.userId)", viewType: "1") {
                self.getUserProfile()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button {
                        if self.isShowbackBtn == false {
                            self.profileVM.isSideBarOpened.toggle()
                        } else {
                            self.dismiss()
                        }
                    } label: {
                        Image(self.isShowbackBtn == false ? IdentifiableKeys.ImageName.kMenuBar : IdentifiableKeys.ImageName.kBackArrowBlack)
                    }
                    
                    Text(self.isShowbackBtn == false ? IdentifiableKeys.NavigationbarTitles.kMyProfile : "\(self.userFullName ?? "")")
                        .foregroundColor(Color.myDarkCustomColor)
                        .font(.custom(Constant.FontStyle.Heavy.rawValue, size: Constant.FontSize._28FontSize))
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button {
                        guard let currentUser = UserDefaults.getData(UserDefaultsKey.kLoginUser, data: UserModel.self) else { return }
                        
                        if self.profileVM.videoURL != nil && self.profileVM.videoThumbnailURL != nil {
                            self.profileVM.videoURL = nil
                            self.profileVM.videoThumbnailURL = nil
                        }
                        
                        if self.userId == nil {
                            self.profileVM.userId = currentUser.userId
                        } else {
                            self.profileVM.userId = self.userId ?? -1
                        }
                        
                        self.getUserProfile()
                    } label: {
                        Image(IdentifiableKeys.ImageName.kBlackRefresh)
                            .resizable()
                            .frame(width: 20, height: 20, alignment: .center)
                    }
                }
            }
        }
        .onChange(of: self.profileVM.isSideBarOpened, perform: { isSideBarOpened in
            if isSideBarOpened == true {
                NotificationCenter.default.post(name: .pauseVideo, object: nil)
            } else {
                NotificationCenter.default.post(name: .playVideo, object: nil)
            }
        })
        .alert(isPresented: self.$profileVM.isOpenDeactivateAlert) {
            Alert(
                title: Text(""),
                message: Text(IdentifiableKeys.AlertMessages.kDeactivateAccount),
                primaryButton: .default(Text(IdentifiableKeys.Buttons.kNo)) {},
                secondaryButton: .default(Text(IdentifiableKeys.Buttons.kYes)) {
                    self.profileVM.deactivateAccount { message in
                        Indicator.hide()

                        self.viewRouter.currentView = .Login
                        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.kLoginUser)
                        
                        NavigationUtil.popToRootView()

                        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: UInt64(1.0))) {
                            Alert.show(title: "", message: message)
                        }
                    }
                }
            )
        }
    }
}

// MARK: - Functions
extension ProfileView {
    func getUserProfile() -> Void {
        self.profileVM.videoURL = URL(string: self.profileVM.profileModel?.data.introductionVideo ?? "")

        self.profileVM.getUserProfileApiCall { profileModel -> Void in
            guard let model = profileModel else { return }
            
            self.profileVM.videoURL = URL(string: model.data.introductionVideo ?? "")
            self.profileVM.videoThumbnailURL = URL(string: model.data.introductionVideoThumb ?? "")
            
            if let introVideo = model.data.introductionVideo, let introVideoFileName = introVideo.split(separator: "?").first?.split(separator: "/").last {
                self.profileVM.deleteVideoFileName = String(introVideoFileName)
            }
            
            if let introVideoThumb = model.data.introductionVideoThumb, let introVideoThumbFileName = introVideoThumb.split(separator: "?").first?.split(separator: "/").last {
                self.profileVM.deleteVideoThumbFileName = String(introVideoThumbFileName)
            }
            
            self.profileVM.website1 = model.data.websiteURL1
            self.profileVM.website2 = model.data.websiteURL2
            self.profileVM.website3 = model.data.websiteURL3
            self.profileVM.website4 = model.data.websiteURL4
            self.profileVM.website5 = model.data.websiteURL5
            self.profileVM.isPrivate = model.data.isPrivate
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeIn(duration: 0.3)) {
                    self.profileVM.muteBtnOpacity = 0
                }
            }
        }
    }
}

// MARK: - Helper Methods
extension ProfileView {
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
    
    /// `top` view
    func topView() -> some View {
        VStack {
            if let model = self.profileVM.profileModel {
                Text(model.data.firstName + " " + model.data.lastName)
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._32FontSize))
                    .fontWeight(.bold)

                Image(IdentifiableKeys.ImageName.kOneStar)
                    .resizable()
                    .frame(width: 25, height: 25)
                
                if let currentUser = UserDefaults.getData(UserDefaultsKey.kLoginUser, data: UserModel.self) {
                    if currentUser.userId != self.profileVM.userId {
                        Spacer().frame(height: 20.0)

                        Button(action: {
                            self.profileVM.followUnfollowUser {
                                self.getUserProfile()
                            }
                        }, label: {
                            return Text(model.data.isFollowing == 0 ? "+ Follow" : (model.data.isFollowing == 1 ? "Requested": "Folllowing"))
                                .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._20FontSize))
                                .foregroundColor(Color.myDarkCustomColor)
                        })
                        .frame(width: ScreenSize.SCREEN_WIDTH * 0.40)
                        .padding(.all, 8)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.myDarkCustomColor))
                        .padding(.leading, 14)
                    }
                }
            }
            
            Spacer().frame(height: 20.0)
        }
    }
    
    /// `posts, followers & following` Section
    func followerSection() -> some View {
        HStack {
            if let model = self.profileVM.profileModel {
                VStack(alignment: .center) {
                    Group {
                        Text("\(model.data.postCount)")
                        
                        Button {
                            if let currentUser = UserDefaults.getData(UserDefaultsKey.kLoginUser, data: UserModel.self) {
                                if model.data.isPrivate == false || model.data.isFollowing == 2 {
                                    self.profileVM.moveToPosts.toggle()
                                } else {
                                    if currentUser.userId == model.data.userID {
                                        self.profileVM.moveToPosts.toggle()
                                    }
                                }
                            }
                        } label: {
                            Text(IdentifiableKeys.Buttons.kPosts)
                                .foregroundColor(Color.myDarkCustomColor)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._20FontSize))
                }
                
                Spacer()

                VStack(alignment: .center) {
                    Group {
                        Text("\(model.data.followersCount)")
                        
                        Button {
                            if let currentUser = UserDefaults.getData(UserDefaultsKey.kLoginUser, data: UserModel.self) {
                                if model.data.isPrivate == false || model.data.isFollowing == 2 {
                                    self.profileVM.moveToFollowers.toggle()
                                } else {
                                    if currentUser.userId == model.data.userID {
                                        self.profileVM.moveToFollowers.toggle()
                                    }
                                }
                            }
                        } label: {
                            Text(IdentifiableKeys.Buttons.kFollowers)
                                .foregroundColor(Color.myDarkCustomColor)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._20FontSize))
                }
                
                Spacer()

                VStack(alignment: .center) {
                    Group {
                        Text("\(model.data.followingCount)")
                        
                        Button {
                            if let currentUser = UserDefaults.getData(UserDefaultsKey.kLoginUser, data: UserModel.self) {
                                if model.data.isPrivate == false || model.data.isFollowing == 2 {
                                    self.profileVM.moveToFollowing.toggle()
                                } else {
                                    if currentUser.userId == model.data.userID {
                                        self.profileVM.moveToFollowing.toggle()
                                    }
                                }
                            }
                        } label: {
                            Text(IdentifiableKeys.Buttons.kFollowing)
                                .foregroundColor(Color.myDarkCustomColor)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._20FontSize))
                }
            }
        }
    }
    
    /// `video` section
    func videoSection() -> some View {
        VStack(alignment: .leading) {
            Text(IdentifiableKeys.Labels.kIntroductionBioVideo)
                .padding(.leading, 5)
                .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._20FontSize))

            VStack {
                ZStack(alignment: .bottomTrailing) {
                    if self.profileVM.videoURL != nil && self.profileVM.videoThumbnailURL != nil {
                        if let videoUrl = self.profileVM.videoURL {
                            CustomVideoPlayer(videoURL: videoUrl, isAutoPlay: true)
                                .frame(width: ScreenSize.SCREEN_WIDTH, height: 550)
                            
                            Image(self.profileVM.isShowMuteBtn ? IdentifiableKeys.ImageName.kUnMute : IdentifiableKeys.ImageName.kMute)
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding([.trailing, .bottom], 5)
                                .opacity(Double(self.profileVM.muteBtnOpacity))
                        }
                    }
                }
            }
            .onAppear {
                self.postHeight = (self.profileVM.profileModel?.data.videoHeight ?? 400.0)
                
                if self.postHeight >= 1000 {
                    self.postHeight = self.postHeight * 0.36
                } else if self.postHeight <= 550 {
                    self.postHeight = self.postHeight + 0
                } else if self.postHeight > 550 && self.postHeight < 1000 {
                    self.postHeight = self.postHeight * 0.5
                }
            }
        }
        .padding(.top, 5)
        .onTapGesture {
            self.profileVM.isShowMuteBtn.toggle()
            self.profileVM.muteBtnOpacity = 1

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeIn(duration: 0.5)) {
                    self.profileVM.muteBtnOpacity = 0
                }
            }
            
            NotificationCenter.default.post(name: self.profileVM.isShowMuteBtn == true ? .unMutePlayer : .mutePlayer, object: nil)
        }
    }
    
    /// `about self` details
    func aboutSelfSection() -> some View {
        VStack {
            if let model = self.profileVM.profileModel {
                HStack {
                    Text(IdentifiableKeys.Labels.kAboutSelf)
                        .padding(.leading , 2)
                        .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._20FontSize))
                    Spacer()
                    Text("\(model.data.profileViewCount) Views")
                        .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._18FontSize))
                        .padding(.trailing, 120)
                }
                
                VStack {
                    Text(model.data.aboutSelf == "" ? "Describe yourself in 1 word" : model.data.aboutSelf)
                        .padding(.leading, 5)
                        .frame(width: ScreenSize.SCREEN_WIDTH, height: 40, alignment: .leading)
                        .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
                }
                .background(Color.appSnippetsColor)
                
                CommonProfileText(text: IdentifiableKeys.Labels.kCity)
                
                Text(model.data.city)
                    .padding(.leading, 5)
                    .frame(width: ScreenSize.SCREEN_WIDTH, height: 40, alignment: .leading)
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
                    .background(Color.appSnippetsColor)
                
                
                VStack {
                    CommonProfileText(text: IdentifiableKeys.Labels.kWebsite)
                    
                    CommonProfileTextField(placeholderText: IdentifiableKeys.Labels.kWebsite1, text: self.$profileVM.website1)
                    CommonProfileTextField(placeholderText: IdentifiableKeys.Labels.kWebsite2, text: self.$profileVM.website2)
                    CommonProfileTextField(placeholderText: IdentifiableKeys.Labels.kWebsite3, text: self.$profileVM.website3)
                    CommonProfileTextField(placeholderText: IdentifiableKeys.Labels.kWebsite4, text: self.$profileVM.website4)
                    CommonProfileTextField(placeholderText: IdentifiableKeys.Labels.kWebsite5, text: self.$profileVM.website5)
                }
                
                VStack {
                    CommonProfileText(text: IdentifiableKeys.Labels.kCategory)
                    
                    Text(model.data.categoryName)
                        .padding(.leading, 5)
                        .frame(width: ScreenSize.SCREEN_WIDTH, height: 40, alignment: .leading)
                        .background(Color.appSnippetsColor)
                        .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
                }
                
                if let currentUser = UserDefaults.getData(UserDefaultsKey.kLoginUser, data: UserModel.self) {
                    if currentUser.userId == self.profileVM.userId {
                        VStack {
                            CommonProfileText(text: IdentifiableKeys.Labels.kSubscriptionDetails)
                            
                            VStack(alignment: .leading, spacing: 8.0) {
                                HStack {
                                    Text("Ad Plan:").fontWeight(.semibold)
                                    Spacer().frame(width: 8.0)
                                    Text(model.data.isSubscribed == false ? "No Subscription is selected." : "Subscription is selected.")
                                }
                                
                                HStack {
                                    Text("Subscription Date:").fontWeight(.semibold)
                                    Spacer().frame(width: 8.0)
                                    Text(model.data.isSubscribed == false ? "No Subscription is selected." : "Subscription is selected.")
                                }
                            }
                            .padding(EdgeInsets(top: 8.0, leading: 8.0, bottom: 8.0, trailing: 8.0))
                            .frame(width: ScreenSize.SCREEN_WIDTH, alignment: .leading)
                            .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
                            .background(Color.appSnippetsColor)
                        }
                        
                        HStack {
                            Button(action: {
                                print("select checkbox Btn for private profile")
                                self.profileVM.isPrivate.toggle()
                                
                                self.profileVM.changeProfileVisibility(profileModel: model, isPrivate: self.profileVM.isPrivate)
                            }, label: {
                                Image(model.data.isPrivate ? IdentifiableKeys.ImageName.kCheked : IdentifiableKeys.ImageName.kUnchecked)
                                    .resizable()
                                    .frame(width: 22, height: 22, alignment: .center)
                            })
                            
                            VStack(alignment: .leading) {
                                Text(IdentifiableKeys.Labels.kMakethisprofileprivate)
                                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize ))
                                Text(IdentifiableKeys.Labels.kWhenyourprofileisprivate)
                                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._12FontSize ))
                            }
                            .padding(.leading, 5)
                        }
                        
                        HStack {
                            Button(action: {
                                self.profileVM.moveToEditProfile.toggle()
                                print("select Edit profile")
                            }, label: {
                                Text(IdentifiableKeys.Buttons.kEditProfile)
                                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
                                    .foregroundColor(Color.myDarkCustomColor)
                                
                            })
                            .padding(.all, 8)
                            .foregroundColor(Color.white)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.myDarkCustomColor))
                            .padding(.leading, 14)
                            
                            Spacer()
                        }
                        
                        HStack {
                            Button(action: {
                                print("deactive account")
                                self.profileVM.isOpenDeactivateAlert = true
                            }, label: {
                                Text(IdentifiableKeys.Buttons.kDeactiveAccount)
                                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._18FontSize))
                                    .foregroundColor(Color.myDarkCustomColor)
                            })
                            .padding(.leading, 5)
                            
                            Spacer()
                        }
                    }
                }
            }
        }
    }
    
    /// `group videos` section
    func groupVideo() -> some View {
        VStack {
            VStack(alignment: .center) {
                HStack(alignment: .center) {
                    Text(IdentifiableKeys.Labels.kGroupVideo)
                        .font(.custom(Constant.FontStyle.Blowbrush.rawValue, size: Constant.FontSize._22FontSize))
                        .frame(height: 45, alignment: .center)
                    
                    Rectangle()
                        .strokeBorder(.blue, lineWidth: 5)
                        .frame(width: 20.0, height: 20.0)
                }
            }
            .frame(width: ScreenSize.SCREEN_WIDTH, height: 45, alignment: .center)
            .background(Color.CustomColor.AppSnippetsColor)
            
            if let groupVideoArr = self.profileVM.profileModel?.data.groupVideos {
                LazyVGrid(columns: self.columns, spacing: 10.0) {
                    ForEach(groupVideoArr, id: \.self) { groupVideo in
                        NavigationLink(destination: {
                            PictureDetailsView(postId: "\(groupVideo.postID ?? 0)", postType: groupVideo.postType ?? 0)
                        }, label: {
                            WebImage(url: URL(string: groupVideo.postThumbnail ?? ""))
                                .resizable()
                                .aspectRatio(1, contentMode: .fill)
                                .border(.blue, width: 4)
                        })
                    }
                }
                .padding(.horizontal, 5)
            }
        }
    }
}

// MARK: - Previews
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
