//
//  HomeView.swift
//  WhosNext
//
//  Created by differenz195 on 03/10/22.
//

import SwiftUI
import AVKit
import SDWebImageSwiftUI
import BottomSheet

struct HomeView: View {
    // MARK: - Variables
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    @StateObject var viewRouter : ViewRouter = ViewRouter()
    @StateObject var homeVM: HomeViewModel = HomeViewModel()
    @StateObject var sidebarVM: SidebarViewModel = SidebarViewModel()
    
    @State var counter: Int = 0
    @State var offSet: Double = 0
    @State var groupIsPlaying: Bool = false
    
    var body: some View {
        ZStack {
            self.sideMenuNavigationLink()
            
            Group {
                NavigationLink(destination: NotificationView(), isActive: self.$homeVM.moveToNotification, label: {})
                NavigationLink(destination: CommentsView(postId: "\(self.homeVM.postId)"), isActive: self.$homeVM.moveToComments, label: {})
                NavigationLink(destination: ProfileView(userId: self.homeVM.userID, userFullName: self.homeVM.userFullName, isShowbackBtn: true), isActive: self.$homeVM.moveToProfile, label: {})
                NavigationLink(destination: ShareToView(postDetailsModel: self.homeVM.postDetailModel), isActive: self.$homeVM.moveToShareScreen, label: {})
                NavigationLink(destination: AllSnippetsDetailView(currentData: self.homeVM.currentSnippetData, navigateToRoot: self.$homeVM.navigateToAllSnippetView), isActive: self.$homeVM.navigateToAllSnippetView, label: {})
                NavigationLink(destination: ImageDetailView(snippetData: self.homeVM.currentSnippetData, navigateToRoot: self.$homeVM.navigateToImageView), isActive: self.$homeVM.navigateToImageView, label: {})
                NavigationLink(destination: AudioPlayerView(snippetData: self.homeVM.currentSnippetData, navigateToRoot: self.$homeVM.navigateToAudioView), isActive: self.$homeVM.navigateToAudioView, label: {})
            }
            
            VStack {
                ScrollViewReader { scrollReader in
                    GeometryReader { scrollProxy in
                        ScrollView(showsIndicators: false) {
                            PullToRefresh(coordinateSpaceName: "home_scroll_view") {
                                self.homeVM.currentpage = 1
                                self.homeVM.getHomeScreenData()
                            }
                            
                            LazyVStack {
                                ZStack {
                                    if self.homeVM.cPage < self.homeVM.mySnippetMultiArray.count && self.homeVM.mySnippetMultiArray[self.homeVM.cPage].count > 0 {
                                        if self.homeVM.mySnippetMultiArray.count != 0 && self.homeVM.mySnippetMultiArray[self.homeVM.cPage].count > 0 {
                                            Text("SNIPPETS")
                                                .font(.custom(Constant.FontStyle.Blowbrush.rawValue, size: Constant.FontSize._22FontSize))
                                                .padding(.bottom, 8.0)
                                                .frame(width: UIScreen.main.bounds.width, height: 260, alignment: .top)
                                            
                                            SnippetSliderView(homeVM: self.homeVM)
                                        }
                                    }
                                }
                                .background(Color.appSnippetsColor)
                                .id(-1)
                                
                                if self.homeVM.posts.count > 0 {
                                    LazyVStack {
                                        ForEach(self.$homeVM.posts, id: \.self) { $post in
                                            if post.postSubType != 3 {
                                                if post.postType == 1 {
                                                    ImageView(scrollProxy: scrollProxy, post: $post, homeVM: self.homeVM)
                                                        .id(post.postID ?? 0)
                                                        .onAppear {
                                                            self.homeVM.currentPostID = post.postID ?? 0
                                                        }
                                                } else {
                                                    VideoView(scrollProxy: scrollProxy, post: post, homeVM: self.homeVM, groupIsPlaying: self.groupIsPlaying, isSideBarOpened: self.$homeVM.isSideBarOpened)
                                                        .id(post.postID ?? 0)
                                                        .onAppear {
                                                            self.homeVM.currentPostID = post.postID ?? 0
                                                        }
                                                }
                                            } else {
                                                GroupVideoView(geoProxy: scrollProxy, arrayUrl: post.postGroup!, groupIsPlaying: groupIsPlaying, post: $post, isSideBarOpened: self.$homeVM.isSideBarOpened, homeVM: self.homeVM)
                                                    .id(post.postID ?? 0)
                                                    .onAppear {
                                                        self.homeVM.currentPostID = post.postID ?? 0
                                                    }
                                            }
                                            
                                            if self.homeVM.currentpage != self.homeVM.getCurrentPage() - 1 {
                                                if self.homeVM.postIDForSnippet.contains(post.postID ?? 0) {
                                                    ZStack {
                                                        if self.homeVM.cPage < self.homeVM.mySnippetMultiArray.count && self.homeVM.mySnippetMultiArray[self.homeVM.cPage].count > 0 {
                                                            if self.homeVM.mySnippetMultiArray.count != 0 && self.homeVM.mySnippetMultiArray[self.homeVM.cPage].count > 0 {
                                                                Text("SNIPPETS")
                                                                    .font(.custom(Constant.FontStyle.Blowbrush.rawValue, size: Constant.FontSize._22FontSize))
                                                                    .padding(.bottom, 8.0)
                                                                    .frame(width: UIScreen.main.bounds.width, height: 260, alignment: .top)
                                                                
                                                                SnippetSliderView(homeVM: self.homeVM)
                                                            }
                                                        }
                                                    }
                                                    .background(Color.appSnippetsColor)
                                                    .id(-2)
                                                }
                                            }
                                        }
                                    }
                                    .refreshable {}
                                    .padding(.top, 10)
                                    .onDisappear(perform: {
                                        print("DISAPPEARED  ==================== *************")
                                        scrollReader.scrollTo(-1, anchor: .top)

                                        if self.homeVM.scrollViewDisabled == false {
                                            Indicator.hide()
                                        }
                                    })
                                    .onAppear {
                                        scrollReader.scrollTo(self.homeVM.scrollPostId, anchor: .top)
                                    }
                                }
                                
                                if self.homeVM.posts.count < self.homeVM.homeScreenModel?.totalCount ?? 0 {
                                    ProgressView()
                                        .onAppear {
                                            self.homeVM.loadMoreHomeScreenData(currentPost: self.homeVM.posts.last ?? HomePostData())
                                        }
                                }
                            }
                        }
                        .coordinateSpace(name: "home_scroll_view")
                        .onDisappear(perform: {
                            if self.homeVM.scrollViewDisabled == false {
                                self.homeVM.scrollViewDisabled = true
                            }
                        })
                        .onChange(of: scrollProxy.size.height, perform: { height in
                            print("height ===== \(scrollProxy.size.height)")
                        })
                        .onChange(of: self.homeVM.isMoveToID) { i in
                            if self.homeVM.currentpage != 1 {
                                if self.homeVM.isMoveToID == true {
                                    scrollReader.scrollTo(self.homeVM.postIDToMove, anchor: .center)
                                }
                            }

                            self.homeVM.isMoveToID = false
                        }
                    }
                }
            }
            .gesture(
                DragGesture(minimumDistance: 10, coordinateSpace: .global)
                    .onEnded({ value in
                        withAnimation {
                            if value.translation.width > 0 {
                                self.homeVM.isSideBarOpened.toggle()
                            }
                        }
                    })
            )
            
            if self.homeVM.isSideBarOpened {
                SideMenuView(sidebarVM: self.sidebarVM, isSidebarVisible: self.$homeVM.isSideBarOpened)
                    .environment(\.moveToOtherView, self.sidebarVM.moveToView)
            }
        }
        .hideNavigationBar(isSideBarMenuOpen: self.homeVM.isSideBarOpened)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading: HStack {
            Button {
                self.homeVM.isSideBarOpened.toggle()
            } label: {
                Image(IdentifiableKeys.ImageName.kMenuBar)
            }
            .padding(.leading,20)
            
            Spacer()
            
            Image(IdentifiableKeys.ImageName.kAppTitleText)
                .frame(width: 170, height: 40, alignment: .center)
                .scaleEffect(self.homeVM.scale)
                .animation(.linear(duration: 1.0).repeatForever(autoreverses: true), value: self.homeVM.scale)
                .onChange(of: self.homeVM.scale, perform: { i in
                    if self.homeVM.isSideBarOpened == false {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1 , execute: {
                            self.homeVM.scale = self.homeVM.scale == 0.6 ? 0.7 : 0.6
                        })
                    }
                })
                .onAppear {
                    if self.homeVM.isSideBarOpened == false {
                        if self.counter != 1 {
                            self.counter += 1
                            self.homeVM.scale = self.homeVM.scale == 0.6 ? 0.7 : 0.6
                        }
                    }
                }
            
            Spacer()
            Spacer()
            
            HStack(spacing: 2) {
                Button {
                    self.homeVM.moveToNotification.toggle()
                    print("******** tap notification ********")
                    // Alert.show(message: "coming soon!")
                } label: {
                    Image(IdentifiableKeys.ImageName.kNotification)
                        .resizable()
                        .frame(width: 20, height: 20, alignment: .center)
                        .overlay(Badge(count: self.homeVM.badgeCount))
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
                    /* self.homeVM.currentpage = 1
                     self.homeVM.getHomeScreenData() */

                    Alert.show(message: "coming soon!")
                    // self.homeVM.scrollPostId = -1
                } label: {
                    Image(IdentifiableKeys.ImageName.kBlackRefresh)
                        .resizable()
                        .frame(width: 20, height: 20, alignment: .center)
                }
            }
            .padding(.trailing,5)
        }.frame(width: UIScreen.main.bounds.width))
        .fullScreenCover(isPresented: self.$homeVM.videoSheet) {
            ZStack {
                if self.homeVM.videoUrl != "" && self.homeVM.showDetailVideo == false {
                    PlayerViewController(videoURL: URL(string: self.homeVM.videoUrl)!, showControls: self.homeVM.isShowControls)
                        .edgesIgnoringSafeArea(.all)
                }
                
                if self.homeVM.videoUrl != "" && self.homeVM.showDetailVideo == true {
                    DetailVideoViewController(videoURL: URL(string: self.homeVM.videoUrl)!, showControls: self.homeVM.isShowControls, remainingTimeSeconds: self.$homeVM.remainingTimeSeconds, remainingTimeMinutes: self.$homeVM.remainingTimeMinutes)
                        .edgesIgnoringSafeArea(.all)
                        .onChange(of: self.homeVM.remainingTimeMinutes) { time in }
                }
                
                if self.homeVM.isShowControls == false {
                    VStack {
                        HStack {
                            Spacer()
                            
                            Text("\(self.homeVM.remainingTimeMinutes):\(self.homeVM.remainingTimeSeconds)")
                                .foregroundColor(Color.white)
                                .padding(.top , 35)
                                .padding(.trailing, -33)
                                .frame(alignment: .center)
                            Spacer()
                            
                            Button {
                                print("Tapped")
                                self.homeVM.videoSheet = false
                                self.homeVM.navigateToAllSnippetView = true
                            } label: {
                                Image(IdentifiableKeys.ImageName.kCloseDark)
                                    .resizable()
                                    .frame(width: 22, height: 22, alignment: .center)
                                    .padding(.top, 35)
                                    .padding(.trailing, 25)
                            }
                        }
                        
                        Spacer()
                    }
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .bottomSheet(isPresented: self.$homeVM.showReportSheet, height: CGFloat(self.homeVM.reportReasonsModel?.data?.count ?? 0) * 80.0, topBarCornerRadius: 10.0, showTopIndicator: false) {
            SelectReportReasonSheet(reportReasonsModel: self.$homeVM.reportReasonsModel, selectedReportReason: self.$homeVM.selectedReportReason, doneAction: {
                self.homeVM.postReport(postID: "\(self.homeVM.selectedPost?.postID ?? 0)", reasonID: "\(self.homeVM.selectedReportReason?.reasonID ?? 0)") {
                    self.homeVM.selectedReportReason = nil
                    self.homeVM.showReportSheet = false
                }
            }, cancelAction: {
                self.homeVM.selectedReportReason = nil
                self.homeVM.showReportSheet = false
            })
        }
        .onChange(of: self.homeVM.isSideBarOpened, perform: { isSideBarOpened in
            if isSideBarOpened == true {
                NotificationCenter.default.post(name: .pauseVideo, object: nil)
            } else {
                NotificationCenter.default.post(name: .playVideo, object: nil)
            }
        })
        .onAppear {
            UIScrollView.appearance().bounces = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                self.homeVM.currentpage = 1
                self.homeVM.getHomeScreenData()
                
                self.homeVM.getReportReasons()

                self.homeVM.notificationBadgeCountApi { model in
                    self.homeVM.badgeCount = model.data?.badge ?? 0
                }
            })
        }
        .confirmationDialog("", isPresented: self.$homeVM.isMoreBtnSheet, actions: {
            if self.homeVM.selectedPost?.isOwnPost == 1 {
                Button(action: {
                    // Alert.show(message: "coming soon!")
                    self.homeVM.scrollPostId = self.homeVM.selectedPost?.postID ?? 0

                    self.homeVM.postDetails(postID: "\(self.homeVM.selectedPost?.postID ?? 0)") {
                        self.homeVM.moveToShareScreen = true
                    }
                }, label: { Text("Edit") })
                
                Button(role: .destructive, action: {
                    // Alert.show(message: "coming soon!")
                    self.homeVM.postDelete(postID: "\(self.homeVM.selectedPost?.postID ?? 0)") {
                        var posts = self.homeVM.posts
                        posts.removeAll(where: { $0.postID == self.homeVM.selectedPost?.postID })
                        
                        self.homeVM.posts = posts
                        self.homeVM.selectedPost = nil
                    }
                }, label: { Text("Delete") })
            } else {
                Button(role: .destructive, action: {
                    self.homeVM.showReportSheet.toggle()
                    // Alert.show(message: "coming soon!")
                }, label: { Text("Report") })
                
                Button(action: {
                    // self.homeVM.showReportSheet.toggle()
                    Alert.show(message: "coming soon!")
                }, label: { Text("Turn on Post Notification") })
            }
        }, message: { Text("Perform some action") })
    }
    
    /// `UIPageControl` appearance
    func setupAppearance() -> Void {
        UIPageControl.appearance().currentPageIndicatorTintColor = .black
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
    }
}

// MARK: - Custom Views
private extension HomeView {
    
    //MARK: - Badge Count
    struct Badge: View {
        let count: Int

        var body: some View {
            ZStack(alignment: .topTrailing) {
                Color.clear
                Text(self.count > 9 ? "9+" : "\(self.count)")
                    .foregroundColor(.white)
                    .font(.system(size: 10))
                    .padding(5)
                    .background(Color.red)
                    .clipShape(Circle())
                    .alignmentGuide(.top) { $0[.bottom] }
                    .alignmentGuide(.trailing) { $0[.trailing] - $0.width * 0.20 }
                    // .opacity(self.count > 0 ?? 1 : 0)
                    .opacity(self.count > 0 ? 1.0 : 0.0)
            }
        }
    }
    
    /// `snippet` slider view
    private struct SnippetSliderView: View {
        @StateObject var homeVM: HomeViewModel
        @State var x: CGFloat = 0
        @State var count: Double = 1
        @State var currentPage: Int =  1 // self.homeVM.cPage
        @State var movalble_X: CGFloat = 18
        @State var offset: CGFloat = 0
        
        var body: some View {
            VStack {
                ZStack {
                    HStack(spacing: self.movalble_X) {
                        if self.homeVM.mySnippetMultiArray.count > self.currentPage {
                            if let snippetArr = self.homeVM.mySnippetMultiArray[self.currentPage] {
                                ForEach(snippetArr, id: \.self) { snippet in
                                    CardView(snippet: snippet, homeVM: self.homeVM)
                                        .offset(x: self.x)
                                        .highPriorityGesture(
                                            DragGesture()
                                                .onChanged { value in
                                                    if value.translation.width > 0 {
                                                        withAnimation {
                                                            self.x = value.location.x
                                                        }
                                                    } else {
                                                        withAnimation {
                                                            self.x = value.location.x - self.homeVM.screen
                                                        }
                                                    }
                                                }
                                                .onEnded { value in
                                                    print("current count: \(self.count)")
                                                    
                                                    if self.count == Double(snippetArr.count - 2) && -value.translation.width > ((self.homeVM.screen - 80) / 2) {
                                                        if snippetArr.count > 2 {
                                                            self.count = 1
                                                            self.x = -((self.homeVM.screen + self.movalble_X) * self.count)
                                                        }
                                                    } else if self.count == 1 && value.translation.width > ((self.homeVM.screen - 80) / 2) {
                                                        if snippetArr.count > 2 {
                                                            self.count = Double(snippetArr.count - 2)
                                                            self.x = -((self.homeVM.screen + self.movalble_X) * self.count)
                                                        }
                                                    } else {
                                                        if value.translation.width > 0 {
                                                            if value.translation.width > ((self.homeVM.screen - 160) / 2) && Int(self.count) != 0{
                                                                if (self.count != 1) {
                                                                    withAnimation {
                                                                        print("before: \(self.count)")
                                                                        self.count = self.count - 1
                                                                        print("after: \(self.count)")
                                                                        self.x = -((self.homeVM.screen + self.movalble_X) * self.count)
                                                                    }
                                                                }
                                                            } else {
                                                                withAnimation {
                                                                    self.x = -((self.homeVM.screen + self.movalble_X) * self.count)
                                                                }
                                                            }
                                                        } else {
                                                            if -value.translation.width > ((self.homeVM.screen - 80) / 2) && Int(self.count) != (snippetArr.count - 1) {
                                                                withAnimation {
                                                                    self.count += 1
                                                                    self.x = -((self.homeVM.screen + self.movalble_X) * self.count)
                                                                }
                                                            } else {
                                                                withAnimation {
                                                                    self.x = -((self.homeVM.screen + self.movalble_X) * self.count)
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                        )
                                }
                            }
                        }
                    }
                    .onReceive(self.homeVM.timer, perform: { _ in
                        if self.currentPage < self.homeVM.mySnippetMultiArray.count && self.homeVM.mySnippetMultiArray[self.currentPage].count > 2 {
                            if self.count >= 1 && Int(self.count) < self.homeVM.mySnippetMultiArray[self.currentPage].count - 2 {
                                withAnimation {
                                    self.count += 1
                                    self.x = -((self.homeVM.screen + self.movalble_X) * self.count)
                                }
                            } else {
                                withAnimation {
                                    self.count = Double(self.homeVM.mySnippetMultiArray[self.currentPage].count - 1)
                                    self.x = -((self.homeVM.screen + self.movalble_X) * self.count)
                                }
                                
                                self.count = 1
                                self.x = -((self.homeVM.screen + self.movalble_X) * self.count)
                            }
                        }
                    })
                    .frame(width: UIScreen.main.bounds.width,height: 200)
                    .offset(x: self.offset)
                    
                    HStack(spacing: 8) {
                        if self.currentPage < self.homeVM.mySnippetMultiArray.count,let snippetArr = self.homeVM.mySnippetMultiArray[self.currentPage] {
                            if snippetArr.count > 2 || snippetArr.count == 1 {
                                if snippetArr.count >= 3 {
                                    ForEach(0 ..< (snippetArr.count - 2), id: \.self) { i in
                                        Button {
                                            self.count = Double(i + 1)
                                            self.x = -((self.homeVM.screen + self.movalble_X) * self.count)
                                        } label: {
                                            Circle()
                                                .frame(width: 8, height: 8, alignment: .center)
                                                .foregroundColor(Int(self.count - 1) == i ? Color.myDarkCustomColor : Color.myDarkCustomColor.opacity(0.3))
                                                .background(.clear)
                                                .padding(.bottom , 10)
                                        }
                                        .tag(i)
                                    }
                                } else if snippetArr.count == 1 {
                                    Button {
                                        self.x = -((self.homeVM.screen + self.movalble_X) * self.count)
                                    } label : {
                                        Circle()
                                            .frame(width: 8, height: 8, alignment: .center)
                                            .foregroundColor(Color.myDarkCustomColor)
                                            .background(.clear)
                                            .padding(.bottom , 10)
                                    }
                                    .tag(1)
                                }
                            }
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width, height: 260, alignment: .bottom)
                }
                
            }
            .padding(.bottom, 15)
            .onAppear {
                self.currentPage = self.homeVM.getCurrentPage() - 1
                
                if self.currentPage < self.homeVM.mySnippetMultiArray.count {
                    let snippetArr = self.homeVM.mySnippetMultiArray[self.currentPage]
                    
                    if snippetArr.count > 2 {
                        self.count = 1
                        self.offset = ((self.homeVM.screen + self.movalble_X) * CGFloat(snippetArr.count / 2)) - (snippetArr.count % 2 == 0 ? ((self.homeVM.screen + self.movalble_X) / 2) : 0) + 0
                        self.x = -((self.homeVM.screen + self.movalble_X) * self.count)
                    } else {
                        self.count = 0
                        self.offset = ((self.homeVM.screen + self.movalble_X) * CGFloat(snippetArr.count / 2)) - (snippetArr.count % 2 == 0 ? ((self.homeVM.screen + self.movalble_X) / 2) : 0) + 0
                    }
                    
                    print("CURRENT  PAGE  ====== \(self.currentPage)")
                }
            }
        }
    }
    
    /// `image view`
    private struct ImageView: View {
        @State var scrollProxy: GeometryProxy
        @Binding var post: HomePostData
        @StateObject var homeVM: HomeViewModel
        @State var postHeight: Double = 0
        @State var postWidth: Double = 0
        
        var body: some View {
            VStack {
                TopView(post: self.$post, homeVM: self.homeVM, isGroupVideo: false)
                
                WebImage(url: URL(string: self.post.postThumbnail ?? ""))
                    .placeholder(Image(IdentifiableKeys.ImageName.kAppBanner).resizable())
                    .resizable()
                    .indicator(.activity)
                    .frame(width: ScreenSize.SCREEN_WIDTH, height: self.postHeight)
                
                BottomView(post: self.post, homeVM: self.homeVM)
                    .padding(.top , 5)
                
                PostCommentsView(post: self.post, homeVM: self.homeVM)
                    .padding(.top , 5)
                
                RoundedRectangle(cornerRadius: 0)
                    .frame(height: 1.5)
                    .foregroundColor(Color.appSnippetsColor)
            }
            .coordinateSpace(name: "home_image_view")
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
                    let geoScroll = self.scrollProxy.frame(in: .named("home_scroll_view"))
                    let geoImage = imageProxy.frame(in: .named("home_image_view"))
                    
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
                        if self.post.isOwnView ?? 0 != 1 {
                            self.post.callCountApiCall = true
                            
                            if self.post.callCountApiCall == true {
                                if self.post.isOwnView == 0 || self.post.isOwnView == nil {
                                    self.homeVM.postViewCountApi(postID: "\(self.post.postID ?? 0)", viewType: "2") {
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
        @State var post: HomePostData
        @StateObject var homeVM: HomeViewModel
        @State var postHeight: Double = 0
        @State var postWidth: Double = 0
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
        
        var body: some View {
            ZStack {
                VStack {
                    TopView(post: self.$post, homeVM: self.homeVM, isGroupVideo: false)
                    
                    ZStack(alignment: .bottomTrailing) {
                        if self.groupShow == true {
                            if let postUrl = URL(string: self.post.postURL ?? "") {
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
                                    if let postUrl = URL(string: self.post.postThumbnail ?? "") {
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
                        self.postHeight = self.post.postHeight ?? 400.0
                        self.postWidth = self.post.postWidth ?? UIScreen.main.bounds.width
                        
                        if self.postHeight == self.postWidth {
                            self.postHeight = ScreenSize.SCREEN_WIDTH
                            self.postWidth = ScreenSize.SCREEN_WIDTH
                        } else if self.postWidth / self.postHeight > 1 {
                            if self.postHeight > 500 {
                                // self.postHeight = 500
                                self.postHeight = self.postHeight * 0.45
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
                    
                    BottomView(post: self.post, homeVM: self.homeVM)
                        .padding(.top , 5)
                    
                    PostCommentsView(post: self.post, homeVM: self.homeVM)
                        .padding(.top , 5)
                    
                    RoundedRectangle(cornerRadius: 0)
                        .frame(height: 1.5)
                        .foregroundColor(Color.appSnippetsColor)
                }
            }
            .coordinateSpace(name: "home_video_view")
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
                self.homeVM.videoViewAppeared = true
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
                self.homeVM.videoViewAppeared = false
                self.groupIsPlaying = false
                self.groupIsMuted = true
                self.groupShow = false
            })
            .onChange(of: self.homeVM.isSideBarOpened, perform: { i in
                if self.homeVM.isSideBarOpened == true {
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
                    let geoScroll = self.scrollProxy.frame(in: .named("home_scroll_view"))
                    let geoVideo = videoProxy.frame(in: .named("home_video_view"))
                    
                    let miny = geoVideo.minY
                    let halfPostHeight = self.postHeight / 2
                    
                    let upperLimit = 30 - halfPostHeight
                    let lowerLimit = geoScroll.maxY - halfPostHeight
                    
                    if miny > upperLimit && miny < lowerLimit {
                        if self.post.isOwnView ?? 0 != 1 {
                            DispatchQueue.main.async{
                                self.post.callCountApiCall = true
                                
                                if self.post.callCountApiCall == true {
                                    if self.post.isOwnView == 0 || self.post.isOwnView == nil {
                                        self.homeVM.postViewCountApi(postID: "\(self.post.postID ?? 0)", viewType: "2") {
                                            self.post.postViewCount = (self.post.postViewCount ?? 0) + 1
                                        }
                                    }
                                }
                                
                                self.post.isOwnView = 1
                            }
                        }
                        
                        DispatchQueue.main.async {
                            if self.groupIsPlaying == false {
                                if self.homeVM.counterOfVideoPlaying == 0 {
                                    self.groupIsPlaying = true
                                    self.homeVM.counterOfVideoPlaying = 1
                                }
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            if self.groupIsPlaying == true {
                                if self.homeVM.counterOfVideoPlaying == 1 {
                                    self.homeVM.counterOfVideoPlaying = 0
                                }
                                
                                self.groupIsPlaying = false
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
        @State var groupVideoGravity: AVLayerVideoGravity = .resizeAspect
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
        @Binding var post: HomePostData
        @Binding var isSideBarOpened: Bool
        @StateObject var homeVM: HomeViewModel
        
        var body: some View {
            VStack {
                TopView(post: self.$post, homeVM: self.homeVM, isGroupVideo: true)
                
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
                        if self.isSideBarOpened == false && self.homeVM.viewAppeared == true {
                            let geoScroll = geoProxy.frame(in: .named("home_scroll_view"))
                            let geoVideo = videoProxy.frame(in: .named("home_group_view"))
                            
                            let scrollOffset = (geoScroll.maxY - geoVideo.minY) / geoScroll.maxY
                            
                            if scrollOffset >= 0.45 && scrollOffset <= (0.45 * 2) {
                                if self.post.isOwnView ?? 0 != 1 {
                                    DispatchQueue.main.async(execute: {
                                        self.post.callCountApiCall = true
                                    })
                                    
                                    
                                    if self.post.callCountApiCall == true {
                                        if self.post.isOwnView == 0 || self.post.isOwnView == nil {
                                            self.homeVM.postViewCountApi(postID: "\(self.post.postID ?? 0)", viewType: "2") {
                                                self.post.postViewCount = (self.post.postViewCount ?? 0) + 1
                                            }
                                        }
                                    }

                                    DispatchQueue.main.async(execute: {
                                        self.post.isOwnView = 1
                                    })
                                    
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
                
                BottomView(post: self.post , homeVM: self.homeVM)
                    .padding(.top , 5)
                
                PostCommentsView(post: self.post, homeVM: self.homeVM)
                    .padding(.top , 5)
                
                RoundedRectangle(cornerRadius: 0)
                    .frame(height: 1.5)
                    .foregroundColor(Color.appSnippetsColor)
            }
            .onAppear(perform: {
                self.homeVM.viewAppeared = true
                print("Appeared")
            })
            .onDisappear(perform: {
                self.homeVM.viewAppeared = false
                print("DisAppeared")
            })
            .onChange(of: self.homeVM.isSideBarOpened, perform: { i in
                if self.homeVM.isSideBarOpened == true {
                    self.groupIsPlaying = false
                    print("Stopping")
                }
            })
            .onAppear {
                if self.groupURLArray.count != 5 {
                    for i in 0..<self.arrayUrl.count {
                        self.groupURLArray.append(URL(string: self.arrayUrl[i].invitedUserVideoURL!)!)
                    }
                    
//                    print("GROUPARRAY:::::::::===== \(self.groupURLArray)")
                    
                    for i in 0..<self.arrayUrl.count {
                        self.groupThumbnailURL.append(URL(string: self.arrayUrl[i].invitedUserVideoThumbnailURL!)!)
                    }
                    
//                    print("GROUPARRAY:::::::::===== \(self.groupThumbnailURL)")
                    self.groupShow = true
                }
            }
        }
    }
    
    /// `top view`
    struct TopView: View {
        @Binding var post: HomePostData
        @StateObject var homeVM: HomeViewModel
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
                    self.homeVM.videoUrl = self.post.introductionVideo ?? ""
                    self.homeVM.videoSheet.toggle()
                }
                
                Text(self.post.username ?? "")
                    .font(.custom(Constant.FontStyle.Bold.rawValue, size: Constant.FontSize._14FontSize))
                    .onTapGesture {
                        self.homeVM.userID = self.post.userID ?? 0
                        self.homeVM.userFullName = self.post.fullName ?? ""
                        self.homeVM.moveToProfile = true
                    }
                
                if isGroupVideo {
                    Spacer()
                    Text("Group Video")
                        .font(.custom(Constant.FontStyle.Blowbrush.rawValue, size: Constant.FontSize._20FontSize))
                    Spacer()
                }
                
                Spacer()
                
                Text(self.post.timeDisplayStr ?? "")
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
        }
    }
    
    /// `bottom view`
    struct BottomView: View {
        @State var post: HomePostData = HomePostData()
        @StateObject var homeVM: HomeViewModel
        @State var likes:Int = 0
        @State var isOwnLike: Int = 0
        
        var body: some View {
            HStack(spacing: 10) {
                Button(action: {
                    self.homeVM.postLike(postID: "\(self.post.postID ?? 0)") {}
                    
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
                    self.homeVM.postId = self.post.postID ?? 0
                    self.homeVM.updatedCommentPostId = self.post.postID ?? 0
                    self.homeVM.isCommentUpdated = true
                    self.homeVM.moveToComments = true
                    self.homeVM.scrollPostId = self.post.postID ?? 0
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
                    self.homeVM.selectedPost = self.post
                    self.homeVM.isMoreBtnSheet.toggle()
                }) {
                    Image(IdentifiableKeys.ImageName.kDotgray)
                        .frame(width: 14, height: 14)
                }
            }
            .padding(.horizontal, 10)
            .onAppear {
                // self.homeVM.updatePostData()
            }
        }
    }
    
    /// `comments view`
    struct PostCommentsView: View {
        @State var post: HomePostData
        @StateObject var homeVM: HomeViewModel
        
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
                        self.homeVM.videoUrl = self.post.introductionVideo ?? ""
                        self.homeVM.videoSheet.toggle()
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
                                self.homeVM.videoUrl = comment.introductionVideo ?? ""
                                self.homeVM.videoSheet.toggle()
                            }
                            
                            Text(comment.username ?? "")
                                .font(.custom(Constant.FontStyle.Bold.rawValue, size: Constant.FontSize._12FontSize))
                                .onTapGesture {
                                    self.homeVM.userID = comment.userID ?? -1
                                    self.homeVM.userFullName = comment.fullName ?? ""
                                    self.homeVM.moveToProfile.toggle()
                                }
                            
                            Text(comment.postComment ?? "")
                                .font(.custom(Constant.FontStyle.Regular.rawValue, size: Constant.FontSize._12FontSize))
                            
                            Spacer()
                        }
                        .padding(.bottom, 5)
                    }
                }
                
                Button(action: {
                    self.homeVM.postId = self.post.postID ?? 0
                    self.homeVM.updatedCommentPostId = self.post.postID ?? 0
                    self.homeVM.isCommentUpdated = true
                    self.homeVM.moveToComments = true
                    self.homeVM.scrollPostId = self.post.postID ?? 0
                }, label: {
                    Text("Add a comment")
                        .font(.custom(Constant.FontStyle.TMedium.rawValue, size: Constant.FontSize._14FontSize))
                        .foregroundColor(Color.myDarkCustomColor)
                })
                .padding(.leading, 40)
            }
            .padding(.horizontal, 10)
            .onAppear {
                if (self.homeVM.isCommentUpdated && self.homeVM.updatedCommentPostId == self.post.postID ?? 0) {
                    self.homeVM.postDetails(postID: "\(self.post.postID ?? 0)") {
                        DispatchQueue.main.async {
                            self.post.postComments = self.homeVM.postDetailModel?.data?.postComments
                            
                            self.homeVM.updatedCommentPostId = 0
                            self.homeVM.isCommentUpdated = false
                        }
                    }
                }
            }
        }
    }
    
    /// `card` view
    private struct CardView: View {
        @State var snippet : HomeSinppetData
        @StateObject var homeVM: HomeViewModel
        
        var body : some View {
            VStack(alignment: .leading, spacing: 0) {
                WebImage(url: URL(string: snippet.snippetThumb ?? ""))
                    .placeholder(Image(IdentifiableKeys.ImageName.kAppBanner).resizable())
                    .resizable()
                    .onTapGesture {
                        switch self.snippet.snippetType {
                            case 1:
                                print("Image Tapped")
                                self.homeVM.navigateToImageView =  true
                                self.homeVM.currentSnippetData = self.snippet
                                break
                            case 2:
                                self.homeVM.currentSnippetData = self.snippet
                                self.homeVM.videoUrl = self.homeVM.currentSnippetData.snippetFile ?? ""
                                self.homeVM.isShowControls = false
                                self.homeVM.videoSheet.toggle()
                                self.homeVM.showDetailVideo = true
                                
                                Indicator.show()
                                print("Video Tapped")
                                break
                            case 3:
                                self.homeVM.currentSnippetData = self.snippet
                                self.homeVM.navigateToAudioView = true
                                
                                Indicator.show()
                                print("Audio Tapped")
                                break
                            default:
                                print("Something Tapped")
                                break
                        }
                    }
                
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
                                                WebImage(url: URL(string: self.snippet.introductionVideoThumb ?? ""))
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
                        self.homeVM.videoUrl = self.snippet.introductionVideo ?? ""
                        self.homeVM.videoSheet.toggle()
                    }
                    
                    Text(self.snippet.username ?? "")
                        .font(.custom(Constant.FontStyle.Bold.rawValue, size: Constant.FontSize._14FontSize))
                        .onTapGesture {
                            self.homeVM.userID = self.snippet.userID ?? 0
                            self.homeVM.userFullName = self.snippet.fullName ?? ""
                            self.homeVM.moveToProfile = true
                        }
                    
                    Spacer()
                    
                    Text(self.snippet.timeDisplayStr ?? "")
                        .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
                }
                .padding(.all , 8)
            }
            .frame(width: UIScreen.main.bounds.width - 80, height: 200)
            
            .cornerRadius(0)
        }
    }
}


// MARK: -  Helper Methods
extension HomeView {
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

// MARK: - ActivityIndicator for Video
struct ActivityIndicator_Video: UIViewRepresentable {
    typealias UIView = UIActivityIndicatorView
    
    var isAnimating: Bool
    var configuration = { (indicator: UIView) in }
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIView { UIView() }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<Self>) {
        self.isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
        self.configuration(uiView)
    }
}

// MARK: - Previews
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
