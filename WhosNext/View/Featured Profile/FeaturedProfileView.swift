//
//  FeaturedProfileView.swift
//  WhosNext
//
//  Created by differenz195 on 18/10/22.
//

import SwiftUI
import AVKit
import SDWebImageSwiftUI
import BottomSheet

struct FeaturedProfileView: View {
    @StateObject private var featuredProfileVM: FeaturedProfileViewModel = FeaturedProfileViewModel()
    @StateObject private var sidebarVM: SidebarViewModel = SidebarViewModel()
    
    @State var counter: Int = 0
    @State var groupIsPlaying = false
    
    var body: some View {
        ZStack {
            self.sideMenuNavigationLink()
            
            Group {
                NavigationLink(destination: NotificationView(), isActive: self.$featuredProfileVM.moveToNotification, label: {})
                
                NavigationLink(destination: CommentsView(postId: "\(self.featuredProfileVM.postId)"), isActive: self.$featuredProfileVM.moveToComments, label: {})
                NavigationLink(destination: ProfileView(userId: self.featuredProfileVM.userID, userFullName: self.featuredProfileVM.userFullName, isShowbackBtn: true),
                               isActive: self.$featuredProfileVM.moveToProfile, label: {})
                NavigationLink(destination: ShareToView(postDetailsModel: self.featuredProfileVM.postDetailModel), isActive: self.$featuredProfileVM.moveToShareScreen, label: {})
            }
            
            if let profileArr = self.featuredProfileVM.featuredProfileModel?.data {
                if profileArr.count == 0 {
                    VStack {
                        Image(IdentifiableKeys.ImageName.kNoPostUserLogo)
                            .resizable()
                            .frame(width: 40,height: 40)
                        
                        Text("No feed found.")
                    }
                } else {
                    VStack {
                        GeometryReader { scrollProxy in
                            ScrollView(showsIndicators: false) {
                                
                                LazyVStack {
                                    ForEach(self.$featuredProfileVM.featuredProfiles, id: \.self) { $post in
                                        if post.postSubType != 3 {
                                            
                                            if post.postType == 1 {
                                                ImageView(scrollProxy: scrollProxy, profile: $post, featuredProfileVM: self.featuredProfileVM)
                                                    .onAppear {
                                                        self.featuredProfileVM.loadMoreFeaturedProfiles(currentProfile: post)
                                                    }
                                            } else {
                                                VideoView(scrollProxy: scrollProxy, profile: $post, featuredProfileVM: self.featuredProfileVM, groupIsPlaying: self.groupIsPlaying, isSideBarOpened: self.$featuredProfileVM.isSideBarOpened)
                                                    .onAppear {
                                                        self.featuredProfileVM.loadMoreFeaturedProfiles(currentProfile: post)
                                                    }
                                            }
                                        } else {
                                            GroupVideoView(geoProxy: scrollProxy, arrayUrl: post.postGroup!, groupIsPlaying: groupIsPlaying, isSideBarOpened: self.$featuredProfileVM.isSideBarOpened, profile: $post, featuredProfileVM: self.featuredProfileVM)
                                        }
                                    }
                                }
                                .padding(.top, 10)
                                
                                Spacer()
                                
                            }
                            .coordinateSpace(name: "featured_profile_scroll_view")
                        }
                    }
                }
            } else {
                VStack {
                    Image(IdentifiableKeys.ImageName.kNoPostUserLogo)
                        .resizable()
                        .frame(width: 40, height: 40)
                    
                    Text("No feed found.")
                }
            }
            
            if self.featuredProfileVM.isSideBarOpened {
                SideMenuView(sidebarVM: self.sidebarVM, isSidebarVisible: self.$featuredProfileVM.isSideBarOpened)
                    .environment(\.moveToOtherView, self.sidebarVM.moveToView)
            }
        }
        .hideNavigationBar(isSideBarMenuOpen: self.featuredProfileVM.isSideBarOpened)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading: HStack {
            Button {
                self.featuredProfileVM.isSideBarOpened.toggle()
            } label: {
                Image(IdentifiableKeys.ImageName.kMenuBar)
            }
            .padding(.leading,20)
            
            Text(IdentifiableKeys.NavigationbarTitles.kFeaturedProfiles)
                .font(.custom(Constant.FontStyle.Heavy.rawValue, size: Constant.FontSize._28FontSize))
            
            Spacer()
            Spacer()
            
            HStack(spacing: 2) {
                Button {
                    // self.notificationVM.onBtnNotification_Click()
                    print("******** tap notification ********")
                    Alert.show(message: "coming soon!")
                } label: {
                    Image(IdentifiableKeys.ImageName.kNotification)
                        .resizable()
                        .frame(width: 20, height: 20, alignment: .center)
                }
                
                Button {
                    print("******** tap search ********")
                    Alert.show(message: "coming soon!")
                } label: {
                    Image(IdentifiableKeys.ImageName.kBlackSearch)
                        .resizable()
                        .frame(width: 20, height: 20, alignment: .center)
                }
                
                Button {
                    print("******** tap refresh ********")
                    self.featuredProfileVM.currentPage = 1
                    self.featuredProfileVM.getFeaturedProfile()
                } label: {
                    Image(IdentifiableKeys.ImageName.kBlackRefresh)
                        .resizable()
                        .frame(width: 20, height: 20, alignment: .center)
                }
            }
            .padding(.trailing,5)
        }.frame(width: UIScreen.main.bounds.width))
        .fullScreenCover(isPresented: self.$featuredProfileVM.videoSheet) {
            if let url = URL(string: self.featuredProfileVM.videoUrl) {
                PlayerViewController(videoURL: url)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .confirmationDialog("", isPresented: self.$featuredProfileVM.isMoreBtnSheet, actions: {
            if self.featuredProfileVM.selectedPost?.isOwnPost == 1 {
                Button(action: {
                    // Alert.show(message: "coming soon!")
                    self.featuredProfileVM.postDetails(postID: "\(self.featuredProfileVM.selectedPost?.postID ?? 0)") {
                        self.featuredProfileVM.moveToShareScreen = true
                    }
                }, label: { Text("Edit") })
                
                Button(role: .destructive, action: {
                    // Alert.show(message: "coming soon!")
                    self.featuredProfileVM.postDelete(postID: "\(self.featuredProfileVM.selectedPost?.postID ?? 0)") {
                        var featuredProfiles = self.featuredProfileVM.featuredProfiles
                        featuredProfiles.removeAll(where: { $0.postID == self.featuredProfileVM.selectedPost?.postID })
                        
                        self.featuredProfileVM.featuredProfiles = featuredProfiles
                        self.featuredProfileVM.selectedPost = nil
                    }
                }, label: { Text("Delete") })
            } else {
                Button(role: .destructive, action: {
                    self.featuredProfileVM.showReportSheet.toggle()
                    // Alert.show(message: "coming soon!")
                }, label: { Text("Report") })
                
                Button(action: {
                    // self.homeVM.showReportSheet.toggle()
                    Alert.show(message: "coming soon!")
                }, label: { Text("Turn on Post Notification") })
            }
        }, message: { Text("Perform some action") })
        .bottomSheet(isPresented: self.$featuredProfileVM.showReportSheet, height: CGFloat(self.featuredProfileVM.reportReasonsModel?.data?.count ?? 0) * 80.0, topBarCornerRadius: 10.0, showTopIndicator: false) {
            SelectReportReasonSheet(reportReasonsModel: self.$featuredProfileVM.reportReasonsModel, selectedReportReason: self.$featuredProfileVM.selectedReportReason, doneAction: {
                self.featuredProfileVM.postReport(postID: "\(self.featuredProfileVM.selectedPost?.postID ?? 0)", reasonID: "\(self.featuredProfileVM.selectedReportReason?.reasonID ?? 0)") {
                    self.featuredProfileVM.selectedReportReason = nil
                    self.featuredProfileVM.showReportSheet = false
                }
            }, cancelAction: {
                self.featuredProfileVM.selectedReportReason = nil
                self.featuredProfileVM.showReportSheet = false
            })
        }
        .onAppear {
            if self.featuredProfileVM.featuredProfileModel == nil {
                self.featuredProfileVM.getFeaturedProfile()
            }

            self.featuredProfileVM.getReportReasons()
        }
        .onChange(of: self.featuredProfileVM.isSideBarOpened, perform: { isSideBarOpened in
            if isSideBarOpened == true {
                NotificationCenter.default.post(name: .pauseVideo, object: nil)
            } else {
                NotificationCenter.default.post(name: .playVideo, object: nil)
            }
        })
    }
}

// MARK: - Custom Views
private extension FeaturedProfileView {
    /// `image view`
    private struct ImageView: View {
        @State var scrollProxy: GeometryProxy
        @Binding var profile: FeaturedProfileData
        @StateObject var featuredProfileVM: FeaturedProfileViewModel
        @State var postHeight: Double = 0
        @State var postWidth: Double = 0
        
        var body: some View {
            VStack {
                TopView(profile: self.$profile, featuredProfileVM: self.featuredProfileVM, isGroupVideo: false)
                
                WebImage(url: URL(string: self.profile.postThumbnail ?? ""))
                    .placeholder(Image(IdentifiableKeys.ImageName.kAppBanner).resizable())
                    .resizable()
                    .indicator(.activity)
                    .frame(width: ScreenSize.SCREEN_WIDTH, height: self.postHeight)
                
                BottomView(profile: self.profile, featuredProfileVM: self.featuredProfileVM)
                    .padding(.top , 5)
                
                PostCommentsView(profile: self.$profile, featuredProfileVM: self.featuredProfileVM)
                    .padding(.top , 5)
                
                RoundedRectangle(cornerRadius: 0)
                    .frame(height: 1.5)
                    .foregroundColor(Color.appSnippetsColor)
            }
            .coordinateSpace(name: "featured_profile_image_view")
            .onAppear {
                self.postHeight = self.profile.postHeight ?? 400.0
                self.postWidth = self.profile.postWidth ?? UIScreen.main.bounds.width
                
                if self.postHeight == self.postWidth {
                    self.postHeight = ScreenSize.SCREEN_WIDTH
                    self.postWidth = ScreenSize.SCREEN_WIDTH
                } else if self.postWidth / self.postHeight > 1 {
                    if self.postHeight > 500 {
                        // self.postHeight = 500
                        self.postHeight = self.postHeight * 0.50
                    } else {
                        self.postHeight = self.postHeight + 0
                    }
                }  else {
                    if self.postHeight <= 250 {
                        // self.postHeight = self.postHeight * 1.75
                        self.postHeight = 350
                    } else if self.postHeight >= 250 && self.postHeight <= 450 {
                        // self.postHeight = self.postHeight * 1.5
                        self.postHeight = 400
                    } else if self.postHeight > 450 && self.postHeight <= 550 {
                        // self.postHeight = self.postHeight * 1.2
                        self.postHeight = 450
                    } else if self.postHeight > 550 && self.postHeight <= 750 {
                        // self.postHeight = self.postHeight * 0.8
                        self.postHeight = ScreenSize.SCREEN_HEIGHT * 0.6
                    } else if self.postHeight > 750 && self.postHeight < 1000 {
                        // self.postHeight = self.postHeight * 0.5
                        self.postHeight = ScreenSize.SCREEN_HEIGHT * 0.7
                    } else if self.postHeight >= 1000 {
                        // self.postHeight = self.postHeight * 0.5
                        self.postHeight = ScreenSize.SCREEN_HEIGHT * 0.7
                    }
                }
            }
            .background(
                GeometryReader { imageProxy -> Color in
                    let geoScroll = self.scrollProxy.frame(in: .named("featured_profile_scroll_view"))
                    let geoImage = imageProxy.frame(in: .named("featured_profile_image_view"))
                    
                    let scrollOffset = (geoScroll.maxY - geoImage.minY) / geoScroll.maxY
                    
                    let postHeight = self.postHeight
                    var scroll_fraction: Double = 0.0
                    
                    if postHeight <= 200 {
                        scroll_fraction = 0.40
                    } else if postHeight >= 201 && postHeight <= 400 {
                        scroll_fraction = 0.50
                    } else if postHeight >= 401 && postHeight <= 600 {
                        scroll_fraction = 0.65
                    } else if postHeight >= 601 {
                        scroll_fraction = 0.70
                    }
                    
                    if scrollOffset >= scroll_fraction && scrollOffset <= (scroll_fraction * 2) {
                        if self.profile.isOwnView ?? 0 != 1 {
                            self.profile.callCountApiCall = true
                            
                            if self.profile.callCountApiCall == true {
                                if self.profile.isOwnView == 0 || self.profile.isOwnView == nil {
                                    self.featuredProfileVM.postViewCountApi(postID: "\(self.profile.postID ?? 0)", viewType: "2") {
                                        self.profile.postViewCount = (self.profile.postViewCount ?? 0) + 1
                                    }
                                }
                            }
                            
                            self.profile.isOwnView = 1
                        }
                    }
                    
                    return Color.clear
                }
            )
        }
    }
    
    /// `video view`
    private struct VideoView: View {
        @State var scrollProxy: GeometryProxy
        @Binding var profile: FeaturedProfileData
        @StateObject var featuredProfileVM: FeaturedProfileViewModel
        @State var postHeight: Double = 0
        @State var postWidth: Double = 0
        
        @State var groupShowsControls = false
        @State var groupVideoGravity: AVLayerVideoGravity = .resize
        @State var groupLoop = true
        @State var groupIsMuted = false
        @State var groupIsPlaying: Bool
        @State var groupStartVideoSeconds:Double = 0.0
        @State var groupBackInSeconds:Double = 0.0
        @State var groupForwardInSeconds:Double = 0.0
        @State var groupLastPlayInSeconds:Double = 0.0
        @State var groupShow = false
        @State var groupCounter: Int = 0
        @State var groupURLArray: [URL] = []
        @State var groupThumbnailURL:[URL] = []
        @State var isShowMuteBtn: Bool = true
        @State var muteBtnOpacity: Int = 1
        @Binding var isSideBarOpened: Bool
        
        var body: some View {
            ZStack {
                VStack {
                    TopView(profile: self.$profile, featuredProfileVM: self.featuredProfileVM, isGroupVideo: false)
                    
                    ZStack(alignment: .bottomTrailing) {
                        if self.groupShow == true {
                            if let postUrl = URL(string: self.profile.postURL ?? "") {
                                if self.groupIsPlaying {
                                    GroupVideoPlayer(initArray: [postUrl], counter: self.$groupCounter)
                                        .isPlaying(self.$groupIsPlaying)
                                        .isMuted(self.$groupIsMuted)
                                        .playbackControls(self.groupShowsControls)
                                        .loop(self.$groupLoop)
                                        .videoGravity(self.groupVideoGravity)
                                        .lastPlayInSeconds(self.$groupLastPlayInSeconds)
                                        .backInSeconds(self.$groupBackInSeconds)
                                        .forwardInSeconds(self.$groupForwardInSeconds)
                                        .incrementCounter(self.$groupCounter)
                                    
                                    Image(self.isShowMuteBtn ? IdentifiableKeys.ImageName.kUnMute : IdentifiableKeys.ImageName.kMute)
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .padding([.trailing, .bottom], 5)
                                        .opacity(Double(self.muteBtnOpacity))
                                } else {
                                    if let postUrl = URL(string: self.profile.postThumbnail ?? "") {
                                        WebImage(url: postUrl)
                                            .placeholder(Image(IdentifiableKeys.ImageName.kAppBanner).resizable())
                                            .resizable()
                                    }
                                }
                            }
                        }
                    }
                    .frame(width: ScreenSize.SCREEN_WIDTH, height: self.postHeight)
                    .onAppear {
                        self.postHeight = self.profile.postHeight ?? 400.0
                        self.postWidth = self.profile.postWidth ?? UIScreen.main.bounds.width
                        
                        if self.postHeight == self.postWidth {
                            self.postHeight = ScreenSize.SCREEN_WIDTH
                            self.postWidth = ScreenSize.SCREEN_WIDTH
                        } else if self.postWidth / self.postHeight > 1 {
                            if self.postHeight > 500 {
                                // self.postHeight = 500
                                self.postHeight = self.postHeight * 0.50
                            } else {
                                self.postHeight = self.postHeight + 0
                            }
                        }  else {
                            if self.postHeight <= 250 {
                                // self.postHeight = self.postHeight * 1.75
                                self.postHeight = 350
                            } else if self.postHeight >= 250 && self.postHeight <= 450 {
                                // self.postHeight = self.postHeight * 1.5
                                self.postHeight = 400
                            } else if self.postHeight > 450 && self.postHeight <= 550 {
                                // self.postHeight = self.postHeight * 1.2
                                self.postHeight = 450
                            } else if self.postHeight > 550 && self.postHeight <= 750 {
                                // self.postHeight = self.postHeight * 0.8
                                self.postHeight = ScreenSize.SCREEN_HEIGHT * 0.6
                            } else if self.postHeight > 750 && self.postHeight < 1000 {
                                // self.postHeight = self.postHeight * 0.5
                                self.postHeight = ScreenSize.SCREEN_HEIGHT * 0.7
                            } else if self.postHeight >= 1000 {
                                // self.postHeight = self.postHeight * 0.5
                                self.postHeight = ScreenSize.SCREEN_HEIGHT * 0.7
                            }
                        }
                    }
                    
                    BottomView(profile: self.profile,featuredProfileVM: self.featuredProfileVM)
                        .padding(.top , 5)
                    
                    PostCommentsView(profile: self.$profile, featuredProfileVM: self.featuredProfileVM)
                        .padding(.top , 5)
                    
                    RoundedRectangle(cornerRadius: 0)
                        .frame(height: 1.5)
                        .foregroundColor(Color.appSnippetsColor)
                }
                .coordinateSpace(name: "featured_profile_video_view")
            }
            .onTapGesture {
                self.isShowMuteBtn.toggle()
                self.muteBtnOpacity = 1
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeIn(duration: 0.5)) {
                        self.muteBtnOpacity = 0
                        self.groupIsMuted.toggle()
                    }
                }
            }
            .onAppear(perform: {
                self.featuredProfileVM.videoViewAppeared = true
                self.groupIsPlaying = true
                self.groupIsMuted = false
                self.groupShow = true
                
                self.muteBtnOpacity = 1
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeIn(duration: 0.5)) {
                        self.muteBtnOpacity = 0
                        
                    }
                }
            })
            .onDisappear(perform: {
                self.featuredProfileVM.videoViewAppeared = false
                self.groupIsPlaying = false
                self.groupIsMuted = true
                self.groupShow = false
            })
            .onChange(of: self.featuredProfileVM.isSideBarOpened, perform: { i in
                if self.featuredProfileVM.isSideBarOpened == true {
                    self.groupIsPlaying = false
                    self.groupIsMuted = true
                    self.groupShow = false
                } else {
                    self.groupIsPlaying = true
                    // self.groupIsMuted = false
                    self.groupShow = true
                }
            })
            .background(
                GeometryReader { videoProxy -> Color in
                    let geoScroll = self.scrollProxy.frame(in: .named("featured_profile_scroll_view"))
                    let geoVideo = videoProxy.frame(in: .named("featured_profile_video_view"))

                    let miny = geoVideo.minY
                    let halfPostHeight = self.postHeight / 2
                    
                    let upperLimit = 30 - halfPostHeight
                    let lowerLimit = geoScroll.maxY - halfPostHeight
                    
                    if miny > upperLimit && miny < lowerLimit {
                        if self.profile.isOwnView ?? 0 != 1 {
                            DispatchQueue.main.async{
                                self.profile.callCountApiCall = true
                                
                                if self.profile.callCountApiCall == true {
                                    if self.profile.isOwnView == 0 || self.profile.isOwnView == nil {
                                        self.featuredProfileVM.postViewCountApi(postID: "\(self.profile.postID ?? 0)", viewType: "2") {
                                            self.profile.postViewCount = (self.profile.postViewCount ?? 0) + 1
                                        }
                                    }
                                }
                                
                                self.profile.isOwnView = 1
                            }
                        }
                        
                        DispatchQueue.main.async {
                            if self.groupIsPlaying == false {
                                self.groupIsPlaying = true
                                print("video playing ======")
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            if self.groupIsPlaying == true {
                                self.groupIsPlaying = false
                                print("video not playing ======")
                            }
                        }
                    }
                    
                    return Color.clear
                }
            )
        }
    }
    
    /// `group video view`
    private struct GroupVideoView: View {
        @State var geoProxy: GeometryProxy
        
        @State var arrayUrl: [PostGroup]
        @State var groupShowsControls = false
        @State var groupVideoGravity: AVLayerVideoGravity = .resizeAspectFill
        @State var groupLoop = true
        @State var groupIsMuted = false
        @State var groupIsPlaying: Bool
        @State var groupStartVideoSeconds:Double = 0.0
        @State var groupBackInSeconds:Double = 0.0
        @State var groupForwardInSeconds:Double = 0.0
        @State var groupLastPlayInSeconds:Double = 0.0
        @State var groupShow = false
        @State var groupCounter: Int = 0
        @State var groupURLArray: [URL] = []
        @State var groupThumbnailURL:[URL] = []
        @State var isShowMuteBtn: Bool = true
        @State var muteBtnOpacity: Int = 1
        @Binding var isSideBarOpened: Bool
        @Binding var profile: FeaturedProfileData
        @StateObject var featuredProfileVM: FeaturedProfileViewModel
        
        var body: some View {
            VStack {
                TopView(profile: self.$profile, featuredProfileVM: self.featuredProfileVM, isGroupVideo: true)
                
                ZStack(alignment: .bottomTrailing) {
                    if self.groupShow == true {
                        GroupVideoPlayer(initArray: self.groupURLArray, counter: self.$groupCounter)
                            .isPlaying(self.$groupIsPlaying)
                            .isMuted(self.$groupIsMuted)
                            .playbackControls(self.groupShowsControls)
                            .loop(self.$groupLoop)
                            .videoGravity(self.groupVideoGravity)
                            .lastPlayInSeconds(self.$groupLastPlayInSeconds)
                            .backInSeconds(self.$groupBackInSeconds)
                            .forwardInSeconds(self.$groupForwardInSeconds)
                            .incrementCounter(self.$groupCounter)
                            .frame(width: nil, height: CGFloat(exactly: 300), alignment: .center)
                        
                        Image(self.isShowMuteBtn ? IdentifiableKeys.ImageName.kUnMute : IdentifiableKeys.ImageName.kMute)
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding([.trailing, .bottom], 5)
                            .opacity(Double(self.muteBtnOpacity))
                    }
                }
                .coordinateSpace(name: "home_group_view")
                .background(
                    GeometryReader { videoProxy -> Color in
                        if self.isSideBarOpened == false && self.featuredProfileVM.viewAppeared == true {
                            let geoScroll = geoProxy.frame(in: .named("featured_profile_scroll_view"))
                            let geoVideo = videoProxy.frame(in: .named("home_group_view"))
                            
                            let scrollOffset = (geoScroll.maxY - geoVideo.minY) / geoScroll.maxY
                            
                            // Double(videoProxy.frame(in: .global).maxY) >= ScreenSize.SCREEN_HEIGHT * 0.2  && Double(videoProxy.frame(in: .global).maxY) <= ScreenSize.SCREEN_HEIGHT * 0.81
                            if scrollOffset >= 0.45 && scrollOffset <= (0.45 * 2) {
                                if self.profile.isOwnView ?? 0 != 1 {
                                    self.profile.callCountApiCall = true
                                    
                                    if self.profile.callCountApiCall == true {
                                        if self.profile.isOwnView == 0 || self.profile.isOwnView == nil {
                                            self.featuredProfileVM.postViewCountApi(postID: "\(self.profile.postID ?? 0)", viewType: "2") {
                                                self.profile.postViewCount = (self.profile.postViewCount ?? 0) + 1
                                            }
                                        }
                                    }
                                    
                                    self.profile.isOwnView = 1
                                }
                                
                                DispatchQueue.main.async(execute: {
                                    if self.groupIsPlaying == false {
                                        self.groupIsPlaying = true
                                        print("Playing ======")
                                    }
                                })
                            } else {
                                DispatchQueue.main.async(execute: {
                                    if self.groupIsPlaying == true {
                                        self.groupIsPlaying = false
                                        print("Not Playing ======")
                                        print(Double(videoProxy.frame(in: .global).maxY))
                                    }
                                    
                                })
                            }
                        } else {
                            if self.groupIsPlaying == true {
                                DispatchQueue.main.async(execute: {
                                    self.groupIsPlaying = false
                                })
                            }
                        }
                        
                        return Color.clear
                    }
                )
                .onTapGesture {
                    self.isShowMuteBtn.toggle()
                    self.muteBtnOpacity = 1
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeIn(duration: 0.5)) {
                            self.muteBtnOpacity = 0
                            self.groupIsMuted.toggle()
                        }
                    }
                }
                
                if self.groupThumbnailURL.count > 0 {
                    HStack(spacing: 10) {
                        Spacer()
                        
                        ForEach(0 ..< self.groupThumbnailURL.count, id: \.self) { i in
                            ZStack {
                                if self.groupCounter == i {
                                    Rectangle().fill(Color.blue)
                                        .frame(width: 55, height: 55, alignment: .center)
                                }
                                
                                Button {
                                    print("Tapped")
                                    self.groupCounter = i
                                    self.groupIsPlaying = true
                                } label: {
                                    WebImage(url: self.groupThumbnailURL[i])
                                        .resizable()
                                        .frame(width: 50, height: 50, alignment: .center)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal,10)
                }
                
                BottomView(profile: self.profile , featuredProfileVM: featuredProfileVM)
                    .padding(.top , 5)
                
                PostCommentsView(profile: self.$profile, featuredProfileVM: self.featuredProfileVM)
                    .padding(.top , 5)
                
                RoundedRectangle(cornerRadius: 0)
                    .frame(height: 1.5)
                    .foregroundColor(Color.appSnippetsColor)
            }
            .onAppear(perform: {
                self.featuredProfileVM.viewAppeared = true
                print("Appeared")
            })
            .onDisappear(perform: {
                self.featuredProfileVM.viewAppeared = false
                print("DisAppeared")
            })
            .onChange(of: self.featuredProfileVM.isSideBarOpened, perform: { i in
                if self.featuredProfileVM.isSideBarOpened == true{
                    self.groupIsPlaying = false
                    print("Stopping")
                }
            })
            .onAppear {
                if self.groupURLArray.count != 5 {
                    for i in 0..<self.arrayUrl.count {
                        self.groupURLArray.append(URL(string: self.arrayUrl[i].invitedUserVideoURL!)!)
                    }
                    
                    print("GROUPARRAY:::::::::===== \(self.groupURLArray)")
                    
                    for i in 0..<self.arrayUrl.count {
                        self.groupThumbnailURL.append(URL(string: self.arrayUrl[i].invitedUserVideoThumbnailURL!)!)
                    }
                    
                    print("GROUPARRAY:::::::::===== \(self.groupThumbnailURL)")
                    self.groupShow = true
                }
                
            }
        }
    }

    /// `top view`
    private struct TopView: View {
        @Binding var profile: FeaturedProfileData
        @StateObject var featuredProfileVM: FeaturedProfileViewModel
        @State var isGroupVideo: Bool = false
        
        var body: some View {
            HStack {
                ZStack {
                    Circle()
                        .fill(.orange)
                        .overlay(
                            GeometryReader {
                                let side = sqrt($0.size.width * $0.size.width / 2)
                                VStack {
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: side, height: side)
                                        .overlay(
                                            WebImage(url: URL(string: self.profile.introductionVideoThumb ?? ""))
                                                .placeholder(Image(systemName: "person.fill"))
                                                .resizable()
                                                .indicator(.activity)
                                                .clipShape(Circle())
                                                .frame(width: 30 ,height: 30)
                                        )
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        )
                        .frame(width: 30, height: 30)
                }
                .onTapGesture {
                    self.featuredProfileVM.videoUrl = self.profile.introductionVideo ?? ""
                    self.featuredProfileVM.videoSheet.toggle()
                }
                
                
                Text(self.profile.username ?? "")
                    .font(.custom(Constant.FontStyle.Bold.rawValue, size: Constant.FontSize._14FontSize))
                    .onTapGesture {
                        self.featuredProfileVM.userID = self.profile.userID ?? 0
                        self.featuredProfileVM.userFullName = self.profile.fullName ?? ""
                        self.featuredProfileVM.moveToProfile = true
                    }
                
                if isGroupVideo {
                    Spacer()
                    Text("Group Video")
                        .font(.custom(Constant.FontStyle.Blowbrush.rawValue, size: Constant.FontSize._20FontSize))
                    Spacer()
                }
                
                Spacer()
                
                Text(self.profile.timeDisplayStr ?? "")
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
        }
    }
    
    /// `bottom view`
    private struct BottomView: View {
        @State var likes:Int = 0
        @State var isOwnLike: Int = 0
        @State var profile: FeaturedProfileData = FeaturedProfileData()
        @StateObject var featuredProfileVM: FeaturedProfileViewModel
        
        var body: some View {
            HStack(spacing: 10) {
                Button(action: {
                    self.featuredProfileVM.postLike(postID: "\(self.profile.postID ?? 0)") {}
                    
                    if self.profile.isOwnLike == 0 {
                        self.profile.isOwnLike = 1
                        self.profile.postLikeCount = (self.profile.postLikeCount ?? 0) + 1
                    } else {
                        self.profile.isOwnLike = 0
                        self.profile.postLikeCount = (self.profile.postLikeCount ?? 0) - 1
                    }
                }) {
                    Image(self.profile.isOwnLike == 1 ? IdentifiableKeys.ImageName.kLikehandblackselected : IdentifiableKeys.ImageName.kLikehandblack)
                }
                
                Text("\(self.profile.postLikeCount ?? 0) Likes")
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._14FontSize))
                    .padding(.trailing, 5)
                
                Button(action: {
                    self.featuredProfileVM.postId = self.profile.postID ?? 0
                    self.featuredProfileVM.updatedCommentPostId = self.profile.postID ?? 0
                    
                    self.featuredProfileVM.isCommentUpdated = true
                    self.featuredProfileVM.moveToComments = true
                }) {
                    Image(IdentifiableKeys.ImageName.kMikegray)
                        .frame(width: 14, height: 14)
                }
                .padding(.trailing, 10)
                
                Button(action: {
                    // self.shareToVM.onBtnShare_Click()
                    Alert.show(message: "coming soon!")
                }) {
                    Image(IdentifiableKeys.ImageName.kSharegray)
                        .frame(width: 14, height: 14)
                }
                .padding(.trailing, 10)
                
                Text("\(self.profile.postViewCount ?? 0) Views")
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._14FontSize))
                
                Spacer()
                
                Button(action: {
                    self.featuredProfileVM.selectedPost = self.profile
                    self.featuredProfileVM.isMoreBtnSheet.toggle()
                }) {
                    Image(IdentifiableKeys.ImageName.kDotgray)
                        .frame(width: 14, height: 14)
                }
            }
            .padding(.horizontal, 10)
            .onAppear {
                self.featuredProfileVM.updatePostData()
            }
        }
    }
    
    /// `comments view`
    private struct PostCommentsView: View {
        @Binding var profile: FeaturedProfileData
        @StateObject var featuredProfileVM: FeaturedProfileViewModel
        
        var body: some View {
            if self.profile.postCaption != "" && self.profile.postCaption != nil {
                HStack {
                    Text(self.profile.postCaption ?? "")
                        .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._12FontSize))
                    
                    Spacer()
                }
                .padding(.horizontal, 10)
            }
            
            LazyVStack(alignment: .leading) {
                if let commentsArr = self.profile.postComments?.prefix(2) {
                    ForEach(commentsArr, id: \.self) { comment in
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(.orange)
                                    .overlay(GeometryReader {
                                        let side = sqrt($0.size.width * $0.size.width / 2)
                                        VStack {
                                            Rectangle().foregroundColor(.clear)
                                                .frame(width: side, height: side)
                                                .overlay(
                                                    
                                                    WebImage(url: URL(string: comment.introductionVideoThumb ?? ""))
                                                        .placeholder(Image(systemName: "person.fill"))
                                                        .resizable()
                                                        .indicator(.activity)
                                                        .clipShape(Circle())
                                                        .frame(width: 30 ,height: 30)
                                                )
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    })
                                    .frame(width: 30, height: 30)
                            }
                            .onTapGesture {
                                self.featuredProfileVM.videoUrl = comment.introductionVideo ?? ""
                                self.featuredProfileVM.videoSheet.toggle()
                            }
                            
                            Text(comment.username ?? "")
                                .font(.custom(Constant.FontStyle.Bold.rawValue, size: Constant.FontSize._12FontSize))
                                .onTapGesture {
                                    self.featuredProfileVM.userID = comment.userID ?? -1
                                    self.featuredProfileVM.userFullName = comment.fullName ?? ""
                                    self.featuredProfileVM.moveToProfile.toggle()
                                }
                            
                            Text(comment.postComment ?? "")
                                .font(.custom(Constant.FontStyle.Regular.rawValue, size: Constant.FontSize._12FontSize))
                            
                            Spacer()
                        }
                        .padding(.bottom, 5)
                    }
                }
                
                Button(action: {
                    self.featuredProfileVM.postId = self.profile.postID ?? 0
                    self.featuredProfileVM.updatedCommentPostId = self.profile.postID ?? 0
                    self.featuredProfileVM.isCommentUpdated = true
                    self.featuredProfileVM.moveToComments = true
                }, label: {
                    Text("Add a comment")
                        .font(.custom(Constant.FontStyle.TMedium.rawValue, size: Constant.FontSize._14FontSize))
                        .foregroundColor(Color.myDarkCustomColor)
                })
                .padding(.leading, 40)
            }
            .padding(.horizontal, 10)
            .onAppear {
                if self.featuredProfileVM.isCommentUpdated && self.featuredProfileVM.updatedCommentPostId == self.profile.postID ?? 0 {
                    self.featuredProfileVM.postDetails(postID: "\(self.profile.postID ?? 0)") {
                        self.profile.postComments = self.featuredProfileVM.postDetailModel?.data?.postComments
                        
                        self.featuredProfileVM.updatedCommentPostId = 0
                        self.featuredProfileVM.isCommentUpdated = false
                        
                        
                    }
                }
            }
        }
    }
}

// MARK: - Helper Methods
extension FeaturedProfileView {
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
                
                if self.sidebarVM.navigationLink == menuItemName.kSnippetsList {
                    /// `move to snippet list screen`
                    NavigationLink("", destination: SnippetsListView(), tag: menuItemName.kSnippetsList, selection: self.$sidebarVM.navigationLink)
                }
            }
            
            VStack {
                if self.sidebarVM.navigationLink == menuItemName.kPictures {
                    /// `move to pictures screen`
                    NavigationLink("", destination: PicturesView(), tag: menuItemName.kPictures, selection: self.$sidebarVM.navigationLink)
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
                    }
                }
            }
        }
    }
    
    struct ActivityIndicator_Video: UIViewRepresentable {
        
        typealias UIView = UIActivityIndicatorView
        var isAnimating: Bool
        fileprivate var configuration = { (indicator: UIView) in }
        
        func makeUIView(context: UIViewRepresentableContext<Self>) -> UIView { UIView() }
        func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<Self>) {
            isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
            configuration(uiView)
        }
    }
}

// MARK: - Previews
struct FeaturedProfileView_Previews: PreviewProvider {
    static var previews: some View {
        FeaturedProfileView()
    }
}

