//
//  MediaCell.swift
//  WhosNext
//
//  Created by differenz240 on 08/11/22.
//

import SwiftUI
import AVKit
import SDWebImageSwiftUI

struct MediaCell: View {
    @Environment(\.dismiss) private var dismiss: DismissAction
    @EnvironmentObject private var postVM: PostViewModel

    @State var postHeight: Double = 0
    @State var postWidth: Double = 0

    var isVideo: Bool
    var postId: String?

    var body: some View {
        ZStack {
            Group {
                NavigationLink(destination: ProfileView(userId: self.postVM.userID, userFullName: self.postVM.userFullName, isShowbackBtn: true), isActive: self.$postVM.moveToProfile, label: {})
                NavigationLink(destination: CommentsView(postId: "\(self.postVM.postId)"), isActive: self.$postVM.moveToComments, label: {})
                NavigationLink(destination: ShareToView(postDetailsModel: self.postVM.postDetailModel), isActive: self.$postVM.moveToShareScreen, label: {})
            }

            VStack {
                if self.isVideo {
                    if self.postVM.postDetailModel?.data?.postSubType == 3 {
                        self.groupVideoView
                    } else {
                        self.videoView
                    }
                } else {
                    self.imageView
                }
            }
        }
        .onAppear {
            self.postVM.postDetails(postID: self.postId ?? "") {
                self.postHeight = self.postVM.postDetailModel?.data?.postHeight ?? 400.0
                self.postWidth = self.postVM.postDetailModel?.data?.postWidth ?? UIScreen.main.bounds.width

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

                if self.postVM.postDetailModel?.data?.isOwnView == 0 {
                    self.postVM.postViewCountApi(postID: self.postId ?? "", viewType: "2") {
                        self.postVM.postDetailModel?.data?.postViewCount = (self.postVM.postDetailModel?.data?.postViewCount ?? 0) + 1
                    }
                }

                if self.postVM.postDetailModel?.data?.postType == 2 {
                    DispatchQueue.main.async {
                        self.postVM.postDetailModel?.data?.isVideoPlaying = true
                        
                        if self.postVM.postDetailModel?.data?.isVideoPlaying == true && self.postVM.postDetailModel?.data?.isNotificationFired == false {
                            NotificationCenter.default.post(name: .playVideo, object: nil)
                            self.postVM.postDetailModel?.data?.isNotificationFired = true
                        }
                    }
                }
            }
        }
        .onDisappear {
            DispatchQueue.main.async {
                if self.postVM.postDetailModel?.data?.isVideoPlaying == true && self.postVM.postDetailModel?.data?.isNotificationFired == true {
                    NotificationCenter.default.post(name: .pauseVideo, object: nil)
                    self.postVM.postDetailModel?.data?.isVideoPlaying = false
                    self.postVM.postDetailModel?.data?.isNotificationFired = false
                }
            }
        }
        .confirmationDialog("", isPresented: self.$postVM.isMoreBtnSheet, actions: {
            Button(action: {
                self.postVM.postDetails(postID: self.postId ?? "") {
                    self.postVM.moveToShareScreen.toggle()
                }
            }, label: { Text("Edit") })
            
            Button(role: .destructive, action: {
                self.postVM.postDelete(postID: self.postId ?? "") {
                    self.dismiss()
                }
            }, label: { Text("Delete") })
        }, message: { Text("Perform some action") })
    }
}

// MARK: - UI Helpers
extension MediaCell {
    /// `video` view
    private var videoView: some View {
        ScrollView {
            Spacer().frame(height: 8.0)

            VStack {
                self.topView
                
                ZStack(alignment: .bottomTrailing) {
                    if let post = self.postVM.postDetailModel?.data {
                        if post.isVideoPlaying == true {
                            if let postUrl = URL(string: post.postURL ?? "") {
                                CustomVideoPlayer(videoURL: postUrl, isAutoPlay: true)
                                    .frame(width: ScreenSize.SCREEN_WIDTH, height: self.postHeight)
                                    .onTapGesture {
                                        self.postVM.isShowMuteBtn.toggle()
                                        NotificationCenter.default.post(name: self.postVM.isShowMuteBtn == true ? .unMutePlayer : .mutePlayer, object: nil)
                                    }
                            }
                        } else {
                            if let url = URL(string: post.postThumbnail ?? "") {
                                WebImage(url: url)
                                    .placeholder(Image(IdentifiableKeys.ImageName.kAppBanner).resizable())
                                    .resizable()
                                    .indicator(.activity)
                                    .frame(width: ScreenSize.SCREEN_WIDTH, height: self.postHeight)
                                    .aspectRatio(contentMode: .fit)
                            }
                        }
                    }
                    
                    Button(action: {
                        self.postVM.isShowMuteBtn.toggle()
                        NotificationCenter.default.post(name: self.postVM.isShowMuteBtn == true ? .unMutePlayer : .mutePlayer, object: nil)
                    }, label: {
                        Image(self.postVM.isShowMuteBtn ? IdentifiableKeys.ImageName.kUnMute : IdentifiableKeys.ImageName.kMute)
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding([.trailing,.bottom], 5)
                            .opacity(self.postVM.isShowMuteBtn ? 1 : 0)
                    })
                }
                
                self.bottomView.padding(.top , 5)
                self.commentSection.padding(.top , 5)
            }
        }
    }
    
    /// `video` view
    private var groupVideoView: some View {
        ScrollView {
            Spacer().frame(height: 8.0)
            
            VStack {
                self.topView
                
                ZStack(alignment: .bottomTrailing) {
                    if self.postVM.groupURLArray.count > 0 {
                        if self.postVM.groupShow == true {
                            GroupVideoPlayer(initArray: self.postVM.groupURLArray, counter: self.$postVM.groupCounter)
                                .isPlaying(self.$postVM.groupIsPlaying)
                                .isMuted(self.$postVM.groupIsMuted)
                                .playbackControls(self.postVM.groupShowsControls)
                                .loop(self.$postVM.groupLoop)
                                .videoGravity(self.postVM.groupVideoGravity)
                                .lastPlayInSeconds(self.$postVM.groupLastPlayInSeconds)
                                .backInSeconds(self.$postVM.groupBackInSeconds)
                                .forwardInSeconds(self.$postVM.groupForwardInSeconds)
                                .incrementCounter(self.$postVM.groupCounter)
                            
                            Image(self.postVM.isShowMuteBtn ? IdentifiableKeys.ImageName.kUnMute : IdentifiableKeys.ImageName.kMute)
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding([.trailing, .bottom], 5)
                                .opacity(Double(self.postVM.muteBtnOpacity))
                        }
                    }
                }
                .frame(width: nil, height: CGFloat(exactly: 300), alignment: .center)
                
                if self.postVM.groupThumbnailURL.count > 0 {
                    HStack(spacing: 10) {
                        Spacer()
                        
                        ForEach(0 ..< self.postVM.groupThumbnailURL.count, id: \.self) { i in
                            ZStack {
                                if self.postVM.groupCounter == i {
                                    Rectangle().fill(Color.blue)
                                        .frame(width: 55, height: 55, alignment: .center)
                                }
                                
                                Button {
                                    print("Tapped")
                                    self.postVM.groupCounter = i
                                    self.postVM.groupIsPlaying = true
                                } label: {
                                    WebImage(url: self.postVM.groupThumbnailURL[i])
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

                self.bottomView.padding(.top , 5)
                self.commentSection.padding(.top , 5)
            }
            .onTapGesture {
                self.postVM.isShowMuteBtn.toggle()
                self.postVM.muteBtnOpacity = 1
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeIn(duration: 0.5)) {
                        self.postVM.muteBtnOpacity = 0
                        self.postVM.groupIsMuted.toggle()
                    }
                }
            }
            .onAppear {
                if self.postVM.groupURLArray.count != 5 {
                    for i in 0 ..< (self.postVM.postDetailModel?.data?.postGroup?.count ?? 0) {
                        self.postVM.groupURLArray.append(URL(string: self.postVM.postDetailModel?.data?.postGroup![i].invitedUserVideoURL ?? "")!)
                    }
                    
                    for i in 0 ..< (self.postVM.postDetailModel?.data?.postGroup?.count ?? 0) {
                        self.postVM.groupThumbnailURL.append(URL(string: self.postVM.postDetailModel?.data?.postGroup![i].invitedUserVideoThumbnailURL ?? "")!)
                    }
                }

                self.postVM.groupShow = true
                self.postVM.groupIsPlaying = true
                self.postVM.groupIsMuted = false
            }
            .onDisappear {
                self.postVM.groupShow = false
                self.postVM.groupIsPlaying = false
                self.postVM.groupIsMuted = true
            }
        }
    }

    /// `image` view
    private var imageView: some View {
        ScrollView {
            Spacer().frame(height: 8.0)
            
            VStack {
                self.topView

                WebImage(url: URL(string: self.postVM.postDetailModel?.data?.postThumbnail ?? ""))
                    .placeholder(Image(IdentifiableKeys.ImageName.kAppBanner).resizable())
                    .resizable()
                    .indicator(.activity)
                    .frame(width: ScreenSize.SCREEN_WIDTH, height: self.postHeight)

                self.bottomView
                    .padding(.top , 5)

                self.commentSection
                    .padding(.top , 5)
            }
        }
    }
}

// MARK: - UI Helpers
extension MediaCell {
    /// `top` view
    private var topView: some View {
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
                                        WebImage(url: URL(string: self.postVM.postDetailModel?.data?.introductionVideoThumb ?? ""))
                                            .placeholder(Image(systemName: "person.fill"))
                                            .resizable()
                                            .indicator(.activity)
                                            .clipShape(Circle())
                                            .frame(width: 30.0, height: 30.0)
                                    )
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    )
                    .frame(width: 30, height: 30)
            }
            .fullScreenCover(isPresented: self.$postVM.videoSheet) {
                if self.postVM.videoUrl != "" {
                    PlayerViewController(videoURL: URL(string: self.postVM.videoUrl))
                        .edgesIgnoringSafeArea(.all)
                }
            }
            .onTapGesture {
                self.postVM.videoUrl = self.postVM.postDetailModel?.data?.introductionVideo ?? ""
                self.postVM.videoSheet.toggle()
            }
            
            Text(self.postVM.postDetailModel?.data?.username ?? "")
                .font(.custom(Constant.FontStyle.Bold.rawValue, size: Constant.FontSize._14FontSize))
                .onTapGesture {
                    self.postVM.userID = self.postVM.postDetailModel?.data?.userID ?? 0
                    self.postVM.userFullName = self.postVM.postDetailModel?.data?.fullName ?? ""
                    self.postVM.moveToProfile.toggle()
                }
            
            if self.postVM.postDetailModel?.data?.postSubType == 3 {
                Spacer()

                Text("Group Video")
                    .font(.custom(Constant.FontStyle.Blowbrush.rawValue, size: Constant.FontSize._20FontSize))
 
                Spacer()
            }
            
            Spacer()

            Text(self.postVM.postDetailModel?.data?.timeDisplayStr ?? "")
                .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 10)
    }
    
    /// `bottom` view
    private var bottomView: some View {
        HStack(spacing: 10) {
            Button(action: {
                self.postVM.postLike(postID: self.postId ?? "") {}

                if self.postVM.postDetailModel?.data?.isOwnLike == 1 {
                    self.postVM.postDetailModel?.data?.isOwnLike = 0
                    self.postVM.postDetailModel?.data?.postLikeCount = (self.postVM.postDetailModel?.data?.postLikeCount ?? 0) - 1
                } else {
                    self.postVM.postDetailModel?.data?.isOwnLike = 1
                    self.postVM.postDetailModel?.data?.postLikeCount = (self.postVM.postDetailModel?.data?.postLikeCount ?? 0) + 1
                }
            }) {
                Image(self.postVM.postDetailModel?.data?.isOwnLike == 1 ? IdentifiableKeys.ImageName.kLikehandblackselected : IdentifiableKeys.ImageName.kLikehandblack)
            }
            
            Text("\(self.postVM.postDetailModel?.data?.postLikeCount ?? 0) Likes")
                .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._14FontSize))
                .padding(.trailing, 5)
            
            Button(action: {
                self.postVM.postId = Int(self.postId ?? "0") ?? 0
                self.postVM.moveToComments.toggle()
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
            
            Text("\(self.postVM.postDetailModel?.data?.postViewCount ?? 0) Views")
                .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._14FontSize))
            
            Spacer()
            
            Button(action: {
                self.postVM.isMoreBtnSheet = true
            }) {
                Image(IdentifiableKeys.ImageName.kDotgray)
                    .frame(width: 14, height: 14)
            }
        }
        .padding(.horizontal, 10)
    }
    
    /// `comment` view
    private var commentSection: some View {
        VStack {
            if self.postVM.postDetailModel?.data?.postCaption != "" && self.postVM.postDetailModel?.data?.postCaption != nil {
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
                                                WebImage(url: URL(string: self.postVM.postDetailModel?.data?.introductionVideoThumb ?? ""))
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
                        self.postVM.videoUrl = self.postVM.postDetailModel?.data?.introductionVideo ?? ""
                        self.postVM.videoSheet.toggle()
                    } */

                    Text(self.postVM.postDetailModel?.data?.postCaption ?? "")
                        .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._12FontSize))

                    Spacer()
                }
                .padding(.horizontal, 10)
            }

            LazyVStack(alignment: .leading) {
                if let commentsArr = self.postVM.postDetailModel?.data?.postComments?.prefix(2) {
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
                                                        .frame(width: 30.0, height: 30.0)
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
                    self.postVM.postId = Int(self.postId ?? "0") ?? 0
                    self.postVM.moveToComments.toggle()
                    print("Add Comment")
                }, label: {
                    Text("Add a comment")
                        .font(.custom(Constant.FontStyle.TMedium.rawValue, size: Constant.FontSize._14FontSize))
                        .foregroundColor(Color.myDarkCustomColor)
                })
                .padding(.leading, 40)
            }
            .padding(.horizontal, 10)
        }
    }
}

// MARK: - Previews
struct MediaCell_Previews: PreviewProvider {
    static var previews: some View {
        MediaCell(isVideo: false)
    }
}
