//
//  PostView.swift
//  WhosNext
//
//  Created by differenz195 on 17/10/22.
//

import SwiftUI
import AVKit
import SDWebImageSwiftUI

struct PostView: View {
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    @State var currentTab: Int = 0
    
    var userId: Int?
    
    @StateObject private var shareToVM: ShareToViewModel = ShareToViewModel()
    @StateObject private var postVM: PostViewModel = PostViewModel()
    
    var body: some View {
        ZStack {
            Group {
                NavigationLink(destination: CommentsView(postId: "\(self.postVM.postId)"), isActive: self.$postVM.moveToComments, label: {})
                NavigationLink(destination: ProfileView(userId: self.postVM.userID, userFullName: self.postVM.userFullName, isShowbackBtn: true), isActive: self.$postVM.moveToProfile, label: {})
                NavigationLink(destination: ShareToView(postDetailsModel: self.postVM.postDetailModel), isActive: self.$shareToVM.moveToShareScreen, label: {})
            }
            
            VStack {
                CustomTabBarView(currentTab: self.$currentTab, tabBarOptions: ["MEDIA", "FEED"])
                
                if self.currentTab == 0 {
                    MediaView(postVM: self.postVM).tag(0)
                } else {
                    FeedView(postVM: self.postVM).tag(1)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button {
                        self.presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(IdentifiableKeys.ImageName.kBackArrowBlack)
                    }
                    
                    Text(IdentifiableKeys.NavigationbarTitles.kPosts)
                        .font(.custom(Constant.FontStyle.Heavy.rawValue, size: Constant.FontSize._28FontSize))
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button {
                        print("tap notification")
                    } label: {
                        Image(IdentifiableKeys.ImageName.kNotification)
                    }
                    Button {
                        print("tap refresh ")
                        self.postVM.getPostListForUsers()
                    } label: {
                        Image(IdentifiableKeys.ImageName.kBlackRefresh)
                    }
                }
            }
        }
        .confirmationDialog("", isPresented: self.$postVM.isMoreBtnSheet, actions: {
            Button(action: {
                self.postVM.postDetails(postID: "\(self.postVM.selectedPost?.postID ?? 0)") {
                    self.shareToVM.moveToShareScreen.toggle()
                }
            }, label: { Text("Edit") })
            
            Button(role: .destructive, action: {
                self.postVM.postDelete(postID: "\(self.postVM.postId)") {
                    var posts = self.postVM.posts

                    posts.removeAll(where: { $0.postID == self.postVM.selectedPost?.postID })
                    self.postVM.posts = posts
                    
                    self.postVM.postId = 0
                    self.postVM.selectedPost = nil
                }
            }, label: { Text("Delete") })
        }, message: { Text("Perform some action") })
        .fullScreenCover(isPresented: self.$postVM.videoSheet) {
            if self.postVM.videoUrl != "" {
                if let url = URL(string: self.postVM.videoUrl) {
                    PlayerViewController(videoURL: url)
                        .edgesIgnoringSafeArea(.all)
                }
            }
        }
        .onAppear {
            if self.userId == nil {
                guard let currentUser = UserDefaults.getData(UserDefaultsKey.kLoginUser, data: UserModel.self) else { return }
                self.postVM.userId = currentUser.userId
            } else {
                self.postVM.userId = self.userId ?? -1
            }
            
            self.postVM.getPostListForUsers()
        }
    }
}

// MARK: - UI Helpers
private extension PostView {
    /// `media view`
    private struct MediaView: View {
        @StateObject var postVM: PostViewModel
        private let columns = Array(repeating: GridItem(.flexible()), count: 3)

        var body: some View {
            ScrollView(showsIndicators: false) {
                VStack {
                    LazyVGrid(columns: self.columns, spacing: 10) {
                        if let postArr = self.postVM.userProfilePostList?.data {
                            ForEach(postArr, id: \.self) { post in
                                NavigationLink(destination: {
                                    PictureDetailsView(postId: "\(post.postID ?? 0)", postType: post.postType ?? 0)
                                }, label: {
                                    WebImage(url: URL(string: post.postThumbnail ?? ""))
                                        .resizable()
                                        .placeholder(Image(IdentifiableKeys.ImageName.kAppBanner).resizable())
                                        .indicator(.activity)
                                        .aspectRatio(1, contentMode: .fill)
                                        .border(post.postSubType == 3 ? .blue : .clear, width: post.postSubType == 3 ? 4 : 0)
                                })
                                
                            }
                        }
                    }
                    .padding(.horizontal, 5.0)
                    .padding(.top, 10.0)
                    
                    Spacer()
                }
            }
        }
    }
    
    /// `feed view`
    private struct  FeedView: View {
        @StateObject var postVM: PostViewModel
        @State var groupIsPlaying: Bool = false
        
        var body: some View {
            VStack {
                GeometryReader { scrollProxy in
                    ScrollView(showsIndicators: false) {
                        VStack {
                            Spacer()

                            ForEach(self.$postVM.posts, id: \.self) { $post in
                                if post.postType == 1 {
                                    ImageView(scrollProxy: scrollProxy, post: $post, postVM: self.postVM)
                                } else {
                                    if post.postSubType == 3 {
                                        GroupVideoView(geoProxy: scrollProxy, arrayUrl: post.postGroup!, groupIsPlaying: self.groupIsPlaying, post: $post, isSideBarOpened: .constant(false), postVM: self.postVM)
                                    } else {
                                        VideoView(scrollProxy: scrollProxy, post: $post, postVM: self.postVM)
                                    }
                                }
                            }
                        }
                    }
                    .coordinateSpace(name: "post_feed_scroll_view")
                }
            }
        }
    }
    
    /// `image view`
    private struct ImageView: View {
        @State var scrollProxy: GeometryProxy
        @Binding var post: UserProfilePostListData
        @StateObject var postVM: PostViewModel
        @State var postHeight: Double = 0
        @State var postWidth: Double = 0
        
        var body: some View {
            VStack {
                TopView(post: self.$post, postVM: self.postVM)
                
                WebImage(url: URL(string: post.postThumbnail ?? ""))
                    .placeholder(Image(IdentifiableKeys.ImageName.kAppBanner).resizable())
                    .resizable()
                    .indicator(.activity)
                    .frame(width: ScreenSize.SCREEN_WIDTH, height: self.postHeight)
                
                BottomView(post: self.post, postVM: self.postVM)
                    .padding(.top , 5)
                
                PostCommentsView(post: self.$post, postVM: self.postVM)
                    .padding(.top , 5)
                
                RoundedRectangle(cornerRadius: 0)
                    .frame(height: 1.5)
                    .foregroundColor(Color.appSnippetsColor)
            }
            .coordinateSpace(name: "post_feed_image_view")
            .onAppear {
                self.postHeight = self.post.postHeight ?? 400.0
                self.postWidth = self.post.postWidth ?? UIScreen.main.bounds.width
                
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
                    let geoScroll = self.scrollProxy.frame(in: .named("post_feed_scroll_view"))
                    let geoImage = imageProxy.frame(in: .named("post_feed_image_view"))
                    
                    let scrollOffset = (geoScroll.maxY - geoImage.minY) / geoScroll.maxY
                    
                    let postHeight = self.post.postHeight ?? 400.0
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
                        if self.post.isOwnView ?? 0 != 1 {
                            self.post.callCountApiCall = true
                            
                            if self.post.callCountApiCall == true {
                                if self.post.isOwnView == 0 || self.post.isOwnView == nil {
                                    self.postVM.postViewCountApi(postID: "\(self.post.postID ?? 0)", viewType: "2") {
                                        self.post.postViewCount = (self.post.postViewCount ?? 0) + 1
                                    }
                                }
                            }
                            
                            self.post.isOwnView = 1
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
        @Binding var post: UserProfilePostListData
        @StateObject var postVM: PostViewModel
        @State var postHeight: Double = 0
        @State var postWidth: Double = 0
        @State var isShowMuteBtn: Bool = true
        @State var muteBtnOpacity: Int = 1

        var body: some View {
            ZStack {
                VStack {
                    TopView(post: self.$post, postVM: self.postVM)
                    
                    ZStack(alignment: .bottomTrailing) {
                        if self.post.isVideoPlaying == true {
                            if let postUrl = URL(string: self.post.postURL ?? "") {
                                CustomVideoPlayer(videoURL: postUrl, isAutoPlay: true)
                            }
                        } else {
                            if let postUrl = URL(string: self.post.postThumbnail ?? "") {
                                WebImage(url: postUrl)
                                    .placeholder(Image(IdentifiableKeys.ImageName.kAppBanner).resizable())
                                    .resizable()
                            }
                        }
                        
                        Image(self.isShowMuteBtn ? IdentifiableKeys.ImageName.kUnMute : IdentifiableKeys.ImageName.kMute)
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding([.trailing, .bottom], 5)
                            .opacity(Double(self.muteBtnOpacity))
                    }
                    .frame(width: ScreenSize.SCREEN_WIDTH, height: self.postHeight)
                    .onAppear {
                        self.postHeight = self.post.postHeight ?? 400.0
                        self.postWidth = self.post.postWidth ?? UIScreen.main.bounds.width
                        
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
                    
                    BottomView(post: self.post, postVM: self.postVM)
                        .padding(.top , 5)
                    
                    PostCommentsView(post: self.$post, postVM: self.postVM)
                        .padding(.top , 5)
                    
                    RoundedRectangle(cornerRadius: 0)
                        .frame(height: 1.5)
                        .foregroundColor(Color.appSnippetsColor)
                }
            }
            .coordinateSpace(name: "post_feed_video_view")
            .onTapGesture {
                self.isShowMuteBtn.toggle()
                self.muteBtnOpacity = 1
                self.postVM.isMoreBtnSheet = false
                
                NotificationCenter.default.post(name: self.isShowMuteBtn == true ? .unMutePlayer : .mutePlayer, object: nil)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeIn(duration: 0.5)) {
                        self.muteBtnOpacity = 0
                    }
                }
            }
            .onAppear(perform: {
                self.muteBtnOpacity = 1
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeIn(duration: 0.5)) {
                        self.muteBtnOpacity = 0
                    }
                }
            })
            .background(
                GeometryReader { videoProxy -> Color in
                    let geoScroll = self.scrollProxy.frame(in: .named("post_feed_scroll_view"))
                    let geoVideo = videoProxy.frame(in: .named("post_feed_video_view"))
                    
                    let scrollOffset = (geoScroll.maxY - geoVideo.minY) / geoScroll.maxY
                    
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
                        if post.isOwnView ?? 0 != 1 {
                            post.callCountApiCall = true
                            
                            if post.callCountApiCall == true {
                                if post.isOwnView == 0 || post.isOwnView == nil {
                                    self.postVM.postViewCountApi(postID: "\(post.postID ?? 0)", viewType: "2") {
                                        post.postViewCount = (post.postViewCount ?? 0) + 1
                                    }
                                }
                            }
                            
                            post.isOwnView = 1
                        }
                        
                        DispatchQueue.main.async {
                            if post.isVideoPlaying == false || post.isVideoPlaying == nil {
                                post.isVideoPlaying = true
                                print("VIDEO PLAYING ============")
                                
                                if post.isVideoPlaying == true && post.isNotificationFired == false {
                                    NotificationCenter.default.post(name: .playVideo, object: nil)
                                    post.isNotificationFired = true
                                }
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            if post.isVideoPlaying == true {
                                print("VIDEO NOT PLAYING ============")
                                NotificationCenter.default.post(name: .pauseVideo, object: nil)
                                post.isVideoPlaying = false
                                post.isNotificationFired = false
                            }
                        }
                    }
                    
                    return Color.clear
                }
            )
        }
    }
    
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
        @Binding var post: UserProfilePostListData
        @Binding var isSideBarOpened: Bool
        @StateObject var postVM: PostViewModel
        
        var body: some View {
            VStack {
                TopView(post: self.$post, postVM: self.postVM, isGroupVideo: true)
                
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
                        if self.isSideBarOpened == false && self.postVM.viewAppeared == true {
                            let geoScroll = geoProxy.frame(in: .named("home_scroll_view"))
                            let geoVideo = videoProxy.frame(in: .named("home_group_view"))
                            
                            let scrollOffset = (geoScroll.maxY - geoVideo.minY) / geoScroll.maxY
                            
                            // Double(videoProxy.frame(in: .global).maxY) >= ScreenSize.SCREEN_HEIGHT * 0.2  && Double(videoProxy.frame(in: .global).maxY) <= ScreenSize.SCREEN_HEIGHT * 0.81
                            if scrollOffset >= 0.45 && scrollOffset <= (0.45 * 2) {
                                if self.post.isOwnView ?? 0 != 1 {
                                    self.post.callCountApiCall = true
                                    
                                    if self.post.callCountApiCall == true {
                                        if self.post.isOwnView == 0 || self.post.isOwnView == nil {
                                            self.postVM.postViewCountApi(postID: "\(self.post.postID ?? 0)", viewType: "2") {
                                                self.post.postViewCount = (self.post.postViewCount ?? 0) + 1
                                            }
                                        }
                                    }
                                    
                                    self.post.isOwnView = 1
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
                                        .placeholder(Image(IdentifiableKeys.ImageName.kAppBanner).resizable())
                                        .frame(width: 50, height: 50, alignment: .center)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal,10)
                }
                
                BottomView(post: self.post , postVM: self.postVM)
                    .padding(.top , 5)
                
                PostCommentsView(post: self.$post, postVM: self.postVM)
                    .padding(.top , 5)
                
                RoundedRectangle(cornerRadius: 0)
                    .frame(height: 1.5)
                    .foregroundColor(Color.appSnippetsColor)
            }
            .onAppear(perform: {
                self.postVM.viewAppeared = true
                print("Appeared")
            })
            .onDisappear(perform: {
                self.postVM.viewAppeared = false
                print("DisAppeared")
            })
            .onAppear {
                if self.groupURLArray.count != 5 {
                    for i in 0..<self.arrayUrl.count {
                        self.groupURLArray.append(URL(string: self.arrayUrl[i].invitedUserVideoURL ?? "")!)
                    }

                    for i in 0..<self.arrayUrl.count {
                        self.groupThumbnailURL.append(URL(string: self.arrayUrl[i].invitedUserVideoThumbnailURL ?? "")!)
                    }

                    self.groupShow = true
                }
            }
        }
    }

    /// `top view`
    private struct TopView: View {
        @Binding var post: UserProfilePostListData
        @StateObject var postVM: PostViewModel
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
                                            WebImage(url: URL(string: self.post.introductionVideoThumb ?? ""))
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
                    self.postVM.videoUrl = post.introductionVideo ?? ""
                    self.postVM.videoSheet.toggle()
                }
                
                Text(self.post.username ?? "")
                    .font(.custom(Constant.FontStyle.Bold.rawValue, size: Constant.FontSize._14FontSize))
                    .onTapGesture {
                        self.postVM.userID = post.userID ?? 0
                        self.postVM.userFullName = post.fullName ?? ""
                        self.postVM.moveToProfile.toggle()
                    }
                
                if self.isGroupVideo {
                    Spacer()
                    Text("Group Video")
                        .font(.custom(Constant.FontStyle.Blowbrush.rawValue, size: Constant.FontSize._20FontSize))
                    Spacer()
                }

                Spacer()
                
                Text(post.timeDisplayStr ?? "")
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
        }
    }
    
    /// `bottom view`
    private struct BottomView: View {
        @State var post: UserProfilePostListData = UserProfilePostListData()
        @StateObject var postVM: PostViewModel
        @State var likeCount:Int = 0
        @State var liked: Int = 0
        
        var body: some View {
            HStack(spacing: 10) {
                Button(action: {
                    self.postVM.postLike(postID: "\(post.postID ?? 0)") {}

                    if self.post.isOwnLike == 0 {
                        self.post.isOwnLike = 1
                        self.post.postLikeCount = (self.post.postLikeCount ?? 0) + 1
                    } else {
                        self.post.isOwnLike = 0
                        self.post.postLikeCount = (self.post.postLikeCount ?? 0) - 1
                    }
                }) {
                    Image(self.post.isOwnLike == 1 ? IdentifiableKeys.ImageName.kLikehandblackselected : IdentifiableKeys.ImageName.kLikehandblack)
                }
                
                Text("\(self.post.postLikeCount ?? 0) Likes")
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._14FontSize))
                    .padding(.trailing, 5)
                
                Button(action: {
                    self.postVM.postId = self.post.postID ?? 0
                    self.postVM.updatedCommentPostId = self.post.postID ?? 0
                    self.postVM.isCommentUpdated = true
                    self.postVM.moveToComments = true
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
                
                Text("\(self.post.postViewCount ?? 0) Views")
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._14FontSize))
                
                Spacer()
                
                Button(action: {
                    self.postVM.postId = self.post.postID ?? 0
                    self.postVM.selectedPost = self.post
                    self.postVM.isMoreBtnSheet = true
                }) {
                    Image(IdentifiableKeys.ImageName.kDotgray)
                        .frame(width: 14, height: 14)
                }
            }
            .onAppear(perform: {
                self.likeCount = self.post.postLikeCount ?? 0
                
                if self.post.isOwnLike == 1 {
                    self.liked = 1
                }
            })
            .padding(.horizontal, 10)
        }
    }
    
    /// `comments view`
    private struct PostCommentsView: View {
        @Binding var post: UserProfilePostListData
        @StateObject var postVM: PostViewModel
        
        var body: some View {
            if self.post.postCaption != "" && self.post.postCaption != nil {
                HStack {
                    /* ZStack {
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
                                                WebImage(url: URL(string: self.post.introductionVideoThumb ?? ""))
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
                        self.postVM.videoUrl = self.post.introductionVideo ?? ""
                        self.postVM.videoSheet.toggle()
                    } */
                    
                    Text(self.post.postCaption ?? "")
                        .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._12FontSize))
                    
                    Spacer()
                }
                .padding(.horizontal, 10)
            }

            LazyVStack(alignment: .leading) {
                if let commentsArr = self.post.postComments?.prefix(2) {
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
                                self.postVM.videoUrl = comment.introductionVideo ?? ""
                                self.postVM.videoSheet.toggle()
                            }
                            
                            Text(comment.username ?? "")
                                .font(.custom(Constant.FontStyle.Bold.rawValue, size: Constant.FontSize._12FontSize))
                                .onTapGesture {
                                    self.postVM.userID = comment.userID ?? -1
                                    self.postVM.userFullName = comment.fullName ?? ""
                                    self.postVM.moveToProfile.toggle()
                                }
                            
                            Text(comment.postComment ?? "")
                                .font(.custom(Constant.FontStyle.Regular.rawValue, size: Constant.FontSize._12FontSize))
                            
                            Spacer()
                        }
                        .padding(.bottom, 5)
                    }
                }
                
                Button(action: {
                    self.postVM.postId = self.post.postID ?? 0
                    self.postVM.updatedCommentPostId = self.post.postID ?? 0
                    self.postVM.isCommentUpdated = true
                    self.postVM.moveToComments = true
                }, label: {
                    Text("Add a comment")
                        .font(.custom(Constant.FontStyle.TMedium.rawValue, size: Constant.FontSize._14FontSize))
                        .foregroundColor(Color.myDarkCustomColor)
                })
                .padding(.leading, 40)
            }
            .padding(.horizontal, 10)
            .onAppear {
                if self.postVM.isCommentUpdated && self.postVM.updatedCommentPostId == self.post.postID ?? 0 {
                    self.postVM.postDetails(postID: "\(self.post.postID ?? 0)") {
                        self.post.postComments = self.postVM.postDetailModel?.data?.postComments

                        self.postVM.updatedCommentPostId = 0
                        self.postVM.isCommentUpdated = false
                    }
                }
            }
        }
    }
}

// MARK: - Previews
struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView()
    }
}

