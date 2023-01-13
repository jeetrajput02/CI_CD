//
//  BreastCancerLegaciesView.swift
//  WhosNext
//
//  Created by differenz195 on 20/10/22.
//

import SwiftUI
import SDWebImageSwiftUI
import BottomSheet

struct BreastCancerLegaciesView: View {
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    @StateObject private var bclVM: BreastCancerLegaciesViewModel = BreastCancerLegaciesViewModel()
    @StateObject private var sidebarVM: SidebarViewModel = SidebarViewModel()
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            self.sideMenuNavigationLink()
            
            Group {
                NavigationLink(destination: CreateNewBCLView(legacyDetailsModel: self.bclVM.legacyDetailModel, isEdit: self.bclVM.editLegacy), isActive: self.$bclVM.moveToCreateLegacy, label: {})
                NavigationLink(destination: CommentsView(customColor: Color.CustomColor.AppBCLColor, postId: "\(self.bclVM.postID)"), isActive: self.$bclVM.moveToComments, label: {})
                NavigationLink(destination: ProfileView(userId: self.bclVM.userID, userFullName: self.bclVM.userFullName, isShowbackBtn: true), isActive: self.$bclVM.moveToProfile, label: {})
                NavigationLink(destination: BCLDetailsView(image: URL(string: self.bclVM.selectedLegacy?.postThumbnail ?? ""), postId: "\(self.bclVM.selectedLegacy?.postID ?? 0)"), isActive: self.$bclVM.moveToLegacyDetails, label: {})
            }
            
            VStack {
                VStack {
                    CustomNavigationBar(title: IdentifiableKeys.NavigationbarTitles.kBreastCancerLegacies, isVisibleNotification: false, isVisibleReferesh: true, isVisibleBackBtn: false, isVisibleMenuBtn: true, backButtonAction: {}, menuButtonAction: {
                        self.bclVM.isSideBarOpened.toggle()
                    }, refereshAction: {
                        self.bclVM.currentpage = 1
                        self.bclVM.getLegaciesData()
                    })

                    GeometryReader { scrollProxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack(pinnedViews: [.sectionHeaders]) {
                                ForEach(self.$bclVM.legacies) { $legacy in
                                    Section(content: {
                                        ImageView(scrollProxy: scrollProxy, legacy: $legacy, bclVM: self.bclVM)
                                            .onAppear {
                                                self.bclVM.loadMoreLegaciesData(currentLegacy: legacy)
                                            }
                                    }, header: {
                                        TopView(legacy: $legacy, bclVM: self.bclVM)
                                    })
                                }
                                
                                Spacer(minLength: 50.0)
                            }
                            .onAppear {
                                self.bclVM.getLegaciesData()
                            }
                        }
                        .coordinateSpace(name: "bcl_scroll_view")
                    }
                }
            }
            .offset(y: ScreenSize.SCREEN_HEIGHT > 700.0 ? 0 : -8)
            
            VStack(alignment: .trailing) {
                HStack {
                    Spacer()
                    Button {
                        self.bclVM.moveToCreateLegacy = true
                        self.bclVM.editLegacy = false
                    } label: {
                        VStack {
                            Image(IdentifiableKeys.ImageName.kPlus)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .scaledToFit()
                        }
                        .cornerRadius(45)
                    }
                    
                    Spacer()
                        .frame(width: 10.0)
                }
            }
            .padding(.vertical, 0)
            
            if self.bclVM.isSideBarOpened {
                SideMenuView(sidebarVM: self.sidebarVM, isSidebarVisible: self.$bclVM.isSideBarOpened)
                    .environment(\.moveToOtherView, self.sidebarVM.moveToView)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .hideNavigationBar(isSideBarMenuOpen: self.bclVM.isSideBarOpened)
        .navigationBarHidden(true)
        .onAppear {
            if self.bclVM.legaciesHomeScreenModel == nil {
                self.bclVM.currentpage = 1
                self.bclVM.getLegaciesData()
            }

            self.bclVM.getReportReasons()
        }
        .fullScreenCover(isPresented: self.$bclVM.videoSheet) {
            if let videoUrl = URL(string: self.bclVM.videoUrl) {
                PlayerViewController(videoURL: videoUrl, showControls: self.bclVM.isShowControls)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .bottomSheet(isPresented: self.$bclVM.showReportSheet, height: CGFloat(self.bclVM.reportReasonsModel?.data?.count ?? 0) * 80.0, topBarCornerRadius: 10.0, showTopIndicator: false) {
            SelectReportReasonSheet(reportReasonsModel: self.$bclVM.reportReasonsModel, selectedReportReason: self.$bclVM.selectedReportReason, doneAction: {
                self.bclVM.legacyReport(postID: "\(self.bclVM.selectedLegacy?.postID ?? 0)", reasonID: "\(self.bclVM.selectedReportReason?.reasonID ?? 0)") {
                    self.bclVM.selectedReportReason = nil
                    self.bclVM.showReportSheet = false
                }
            }, cancelAction: {
                self.bclVM.selectedReportReason = nil
                self.bclVM.showReportSheet = false
            })
        }
        .confirmationDialog("", isPresented: self.$bclVM.isMoreBtnSheet, actions: {
            if self.bclVM.selectedLegacy?.isOwnPost == 1 {
                Button(action: {
                    self.bclVM.legacyDetails(postID: "\(self.bclVM.selectedLegacy?.postID ?? 0)") {
                        self.bclVM.moveToCreateLegacy.toggle()
                        self.bclVM.editLegacy = true
                    }
                }, label: { Text("Edit") })
                
                Button(role: .destructive, action: {
                    self.bclVM.legacyDelete(postID: "\(self.bclVM.selectedLegacy?.postID ?? 0)") {
                    }
                }, label: { Text("Delete") })
            } else {
                Button(role: .destructive, action: {
                    self.bclVM.showReportSheet.toggle()
                }, label: { Text("Report") })
            }
        }, message: { Text("Perform some action") })
    }
}

// MARK: - UI Helpers
private extension BreastCancerLegaciesView {
    /// `image view`
    private struct ImageView: View {
        @State var scrollProxy: GeometryProxy
        @Binding var legacy: LegaciesHomeScreenData
        @StateObject var bclVM: BreastCancerLegaciesViewModel
        @State var postHeight: Double = 0
        @State var postWidth: Double = 0
        
        var body: some View {
            VStack {
                WebImage(url: URL(string: self.legacy.postThumbnail ?? ""))
                    .placeholder(Image(IdentifiableKeys.ImageName.kAppBanner).resizable())
                    .resizable()
                    .indicator(.activity)
                    .frame(width: ScreenSize.SCREEN_WIDTH, height: self.postHeight)
                
                BottomView(legacy: self.$legacy, bclVM: self.bclVM)
                    .padding(.top , 5)
                
                DescriptionView(legacy: self.$legacy, bclVM: self.bclVM)
                    .padding(.top , 5)
                
                PostCommentsView(legacy: self.$legacy, bclVM: self.bclVM)
                    .padding(.top , 5)
                
            }
            .padding(10)
            .coordinateSpace(name: "bcl_image_view")
            .onAppear {
                self.postHeight = self.legacy.postHeight ?? 400.0
                self.postWidth = self.legacy.postWidth ?? UIScreen.main.bounds.width
                
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
            .onTapGesture {
                self.bclVM.selectedLegacy = self.legacy
                self.bclVM.moveToLegacyDetails.toggle()
            }
            .background(
                GeometryReader { imageProxy -> Color in
                    let geoScroll = self.scrollProxy.frame(in: .named("bcl_scroll_view"))
                    let geoImage = imageProxy.frame(in: .named("bcl_image_view"))
                    
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
                        if legacy.isOwnView ?? 0 != 1 {
                            self.legacy.callCountApiCall = true
                            
                            if self.legacy.callCountApiCall == true {
                                if self.legacy.isOwnView == 0 || self.legacy.isOwnView == nil {
                                    self.bclVM.legacyViewCountApi(postID: "\(self.legacy.postID ?? 0)", viewType: "2") {
                                        self.legacy.postViewCount = (self.legacy.postViewCount ?? 0) + 1
                                    }
                                }
                            }


                            self.legacy.isOwnView = 1
                        }
                    }
                    
                    return Color.clear
                }
            )
        }
    }
    
    /// `top view`
    private struct TopView: View {
        @Binding var legacy: LegaciesHomeScreenData
        @StateObject var bclVM: BreastCancerLegaciesViewModel
        
        var body: some View {
            HStack {
                Text("Created By")
                    .font(.custom(Constant.FontStyle.Heavy.rawValue, size: Constant.FontSize._16FontSize))
                    .padding(1)
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
                                            WebImage(url: URL(string: self.legacy.introductionVideoThumb ?? ""))
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
                    self.bclVM.videoUrl = legacy.introductionVideo ?? ""
                    self.bclVM.videoSheet.toggle()
                }
                
                Text(self.legacy.username ?? "")
                    .font(.custom(Constant.FontStyle.Bold.rawValue, size: Constant.FontSize._14FontSize))
                    .onTapGesture {
                        self.bclVM.userID = legacy.userID ?? 0
                        self.bclVM.userFullName = legacy.fullName ?? ""
                        self.bclVM.moveToProfile = true
                    }
                
                Spacer()
                
                Text(self.legacy.timeDisplayStr ?? "")
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
                    .padding(10)
            }
            .background(Color.myCustomColor)
            .padding(.all, 0)
        }
    }
    
    /// `bottom view`
    private struct BottomView: View {
        @Binding var legacy: LegaciesHomeScreenData
        @StateObject var bclVM: BreastCancerLegaciesViewModel
        
        var body: some View {
            HStack(spacing: 10) {
                Button(action: {
                    self.bclVM.legacyLike(postID: "\(self.legacy.postID ?? 0)") {}

                    if self.legacy.isOwnLike == 1 {
                        self.legacy.isOwnLike = 0
                        self.legacy.postLikeCount = (self.legacy.postLikeCount ?? 0) - 1
                    } else {
                        self.legacy.isOwnLike = 1
                        self.legacy.postLikeCount = (self.legacy.postLikeCount ?? 0) + 1
                    }
                }) {
                    Image(self.legacy.isOwnLike == 1 ? IdentifiableKeys.ImageName.kRibbonSelected : IdentifiableKeys.ImageName.kRibbon)
                }
                
                Text("\(self.legacy.postLikeCount ?? 0) Likes")
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._14FontSize))
                    .padding(.trailing, 5)
                
                Button(action: {
                    self.bclVM.postID = self.legacy.postID ?? 0
                    self.bclVM.updatedCommentPostId = self.legacy.postID ?? 0
                    self.bclVM.isCommentUpdated = true
                    self.bclVM.moveToComments = true
                }) {
                    Image(IdentifiableKeys.ImageName.kMikepink)
                        .frame(width: 14, height: 14)
                }
                .padding(.trailing, 10)
                
                Button(action: {
                    // self.shareToVM.onBtnShare_Click()
                    Alert.show(message: "coming soon!")
                }) {
                    Image(IdentifiableKeys.ImageName.kSharepink)
                        .frame(width: 14, height: 14)
                }
                .padding(.trailing, 10)
                
                Text("\(self.legacy.postViewCount ?? 0) Views")
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._14FontSize))
                
                Spacer()
                
                Button(action: {
                    self.bclVM.selectedLegacy = self.legacy
                    self.bclVM.isMoreBtnSheet.toggle()
                }) {
                    Image(IdentifiableKeys.ImageName.kDotpink)
                        .frame(width: 14, height: 14)
                }
            }
            .padding(.horizontal, 10)
        }
    }
    
    /// `description view`
    private struct DescriptionView: View {
        @Binding var legacy: LegaciesHomeScreenData
        @StateObject var bclVM: BreastCancerLegaciesViewModel
        
        var body: some View {
            
            LazyVStack(alignment: .leading) {
                Text(self.legacy.legaciesName ?? "")
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
                    .foregroundColor(Color.CustomColor.AppBCLColor)
                    .padding(.bottom, 1)
                
                Text(self.legacy.legaciesDescription ?? "")
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._14FontSize))
                    .foregroundColor(Color.myDarkCustomColor)
                    .padding(.bottom, 10)
                
            }
            .padding(.horizontal, 10)
            
        }
    }
    
    /// `comments view`
    private struct PostCommentsView: View {
        @Binding var legacy: LegaciesHomeScreenData
        @StateObject var bclVM: BreastCancerLegaciesViewModel
        
        var body: some View {
            LazyVStack(alignment: .leading) {
                Button(action: {
                    self.bclVM.postID = self.legacy.postID ?? 0
                    self.bclVM.moveToComments = true
                }, label: {
                    Text("View All \(self.legacy.postComments?.count ?? 0) comments")
                        .font(.custom(Constant.FontStyle.TMedium.rawValue, size: Constant.FontSize._14FontSize))
                        .foregroundColor(Color.CustomColor.AppBCLColor)
                })
                .padding(.bottom, 1)
                
                if let commentsArr = self.legacy.postComments?.prefix(2) {
                    ForEach(commentsArr, id: \.self) { comment in
                        HStack {
                            /* ZStack {
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
                                self.bclVM.videoUrl = comment.introductionVideo ?? ""
                                self.bclVM.videoSheet.toggle()
                            } */
                            
                            Text(comment.username ?? "")
                                .font(.custom(Constant.FontStyle.Bold.rawValue, size: Constant.FontSize._12FontSize))
                                .foregroundColor(Color.CustomColor.AppBCLColor)
                                .onTapGesture {
                                    self.bclVM.userID = comment.userID ?? -1
                                    self.bclVM.userFullName = comment.fullName ?? ""
                                    self.bclVM.moveToProfile.toggle()
                                }
                            
                            Text(comment.postComment ?? "")
                                .font(.custom(Constant.FontStyle.Regular.rawValue, size: Constant.FontSize._12FontSize))
                            
                            Spacer()
                        }
                        .padding(.bottom, 5)
                    }
                }
            }
            .padding(.horizontal, 10)
            .onAppear {
                if self.bclVM.isCommentUpdated && self.bclVM.updatedCommentPostId == self.legacy.postID ?? 0 {
                    self.bclVM.legacyDetails(postID: "\(self.legacy.postID ?? 0)") {
                        self.legacy.postComments = self.bclVM.legacyDetailModel?.data?.postComments
                        self.bclVM.updatedCommentPostId = 0
                        self.bclVM.isCommentUpdated = false
                    }
                }
            }
        }
    }
}

// MARK: - Helper Methods
extension BreastCancerLegaciesView {
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

// MARK: - Previews
struct BreastCancerLegaciesView_Previews: PreviewProvider {
    static var previews: some View {
        BreastCancerLegaciesView()
    }
}


