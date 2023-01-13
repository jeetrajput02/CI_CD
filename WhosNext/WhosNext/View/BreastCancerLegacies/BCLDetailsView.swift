//
//  BCLDetailsView.swift
//  WhosNext
//
//  Created by differenz07 on 15/12/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct BCLDetailsView: View {
    @Environment(\.dismiss) private var dismiss: DismissAction
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @StateObject private var bclVM: BreastCancerLegaciesViewModel = BreastCancerLegaciesViewModel()
    
    @State var postHeight: Double = 0
    @State var postWidth: Double = 0

    var image: URL?
    var postId: String?
    
    var body: some View {
        ZStack {
            Group {
                NavigationLink(destination: CreateNewBCLView(legacyDetailsModel: self.bclVM.legacyDetailModel, isEdit: self.bclVM.editLegacy), isActive: self.$bclVM.moveToCreateLegacy, label: {})
                NavigationLink(destination: ProfileView(userId: self.bclVM.userID, userFullName: self.bclVM.userFullName, isShowbackBtn: true), isActive: self.$bclVM.moveToProfile, label: {})
                NavigationLink(destination: CommentsView(customColor: Color.CustomColor.AppBCLColor, postId: "\(self.bclVM.postID)"), isActive: self.$bclVM.moveToComments, label: {})
            }
            
            VStack {
                CustomNavigationBar(title: self.bclVM.legacyDetailModel?.data?.legaciesName ?? "", isVisibleNotification: false, isVisibleBackBtn: true, backButtonAction: {
                    self.presentationMode.wrappedValue.dismiss()
                }, menuButtonAction: {}, refereshAction: {})
                
                self.imageView
            }
            .offset(y: ScreenSize.SCREEN_HEIGHT > 700.0 ? 0 : -8)
        }
        .onAppear {
            self.bclVM.legacyDetails(postID: self.postId ?? "") {
                if self.bclVM.legacyDetailModel?.data?.isOwnView == 0 {
                    self.bclVM.legacyViewCountApi(postID: self.postId ?? "", viewType: "2") {
                        self.bclVM.legacyDetailModel?.data?.postViewCount = (self.bclVM.legacyDetailModel?.data?.postViewCount ?? 0) + 1
                    }
                }
            }
            
            self.bclVM.getLegaciesData()
            
        }
        .fullScreenCover(isPresented: self.$bclVM.videoSheet) {
            if let videoUrl = URL(string: self.bclVM.videoUrl) {
                PlayerViewController(videoURL: videoUrl, showControls: self.bclVM.isShowControls)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .confirmationDialog("", isPresented: self.$bclVM.isMoreBtnSheet, actions: {
            if self.bclVM.legacyDetailModel?.data?.isOwnPost == 1 {
                Button(action: {
                    self.bclVM.legacyDetails(postID: self.postId ?? "") {
                        self.bclVM.moveToCreateLegacy.toggle()
                        self.bclVM.editLegacy = true
                    }
                }, label: { Text("Edit") })
                
                Button(role: .destructive, action: {
                    self.bclVM.legacyDelete(postID: "\(self.bclVM.legacyDetailModel?.data?.postID ?? 0)") {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }, label: { Text("Delete") })
            } else {
                Button(role: .destructive, action: {
                    // self.homeVM.showReportSheet.toggle()
                    Alert.show(message: "coming soon!")
                }, label: { Text("Report") })
            }
        }, message: { Text("Perform some action") })
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .edgesIgnoringSafeArea(.top)
    }
}

// MARK: - UI Helpers
private extension BCLDetailsView {
    /// `image` view
    private var imageView: some View {
        ScrollView {
            VStack {
                if self.image == URL(string: self.bclVM.legacyDetailModel?.data?.postThumbnail ?? "") {
                    WebImage(url: self.image)
                        .placeholder(Image(IdentifiableKeys.ImageName.kAppBanner).resizable())
                        .resizable()
                        .indicator(.activity)
                        .frame(width: ScreenSize.SCREEN_WIDTH, height: self.postHeight)
                } else {
                    WebImage(url: URL(string: self.bclVM.legacyDetailModel?.data?.postThumbnail ?? ""))
                        .placeholder(Image(IdentifiableKeys.ImageName.kAppBanner).resizable())
                        .resizable()
                        .indicator(.activity)
                        .frame(width: ScreenSize.SCREEN_WIDTH, height: self.postHeight)
                }
                
                self.bottomView
                    .padding(.top, 5)
                
                self.descriptionView
                    .padding(.top, 5)
                
                self.commentSection
                    .padding(.top, 5)
            }
            .onAppear {
                self.postHeight = self.bclVM.legacyDetailModel?.data?.postHeight ?? 400.0
                self.postWidth = self.bclVM.legacyDetailModel?.data?.postWidth ?? UIScreen.main.bounds.width
                
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
        }
    }
    
    /// `description view`
    private var descriptionView: some View {
        
        LazyVStack(alignment: .leading) {
            Text(self.bclVM.legacyDetailModel?.data?.legaciesName ?? "")
                .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
                .foregroundColor(Color.CustomColor.AppBCLColor)
                .padding(.bottom, 1)
            
            Text(self.bclVM.legacyDetailModel?.data?.legaciesDescription ?? "")
                .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._14FontSize))
                .foregroundColor(Color.myDarkCustomColor)
                .padding(.bottom, 10)
            
        }
        .padding(.horizontal, 10)
        
    }
    
    /// `bottom` view
    private var bottomView: some View {
        HStack(spacing: 10) {
            Button(action: {
                self.bclVM.legacyLike(postID: self.postId ?? "") {}

                if self.bclVM.legacyDetailModel?.data?.isOwnLike == 1 {
                    self.bclVM.legacyDetailModel?.data?.isOwnLike = 0
                    self.bclVM.legacyDetailModel?.data?.postLikeCount = (self.bclVM.legacyDetailModel?.data?.postLikeCount ?? 0) - 1
                } else {
                    self.bclVM.legacyDetailModel?.data?.isOwnLike = 1
                    self.bclVM.legacyDetailModel?.data?.postLikeCount = (self.bclVM.legacyDetailModel?.data?.postLikeCount ?? 0) + 1
                }
            }) {
                Image(self.bclVM.legacyDetailModel?.data?.isOwnLike == 1 ? IdentifiableKeys.ImageName.kRibbonSelected : IdentifiableKeys.ImageName.kRibbon)
            }
            
            Text("\(self.bclVM.legacyDetailModel?.data?.postLikeCount ?? 0) Likes")
                .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._14FontSize))
                .padding(.trailing, 5)
            
            Button(action: {
                self.bclVM.postID = self.bclVM.legacyDetailModel?.data?.postID ?? 0
                self.bclVM.updatedCommentPostId = self.bclVM.legacyDetailModel?.data?.postID ?? 0
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
            
            Text("\(self.bclVM.legacyDetailModel?.data?.postViewCount ?? 0) Views")
                .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._14FontSize))
            
            Spacer()
            
            Button(action: {
                self.bclVM.isMoreBtnSheet.toggle()
            }) {
                Image(IdentifiableKeys.ImageName.kDotpink)
                    .frame(width: 14, height: 14)
            }
        }
        .padding(.horizontal, 10)
    }
    
    /// `comment` view
    private var commentSection: some View {
        LazyVStack(alignment: .leading) {
            
            Button(action: {
                self.bclVM.postID = self.bclVM.legacyDetailModel?.data?.postID ?? 0
                self.bclVM.moveToComments = true
            }, label: {
                Text("View All \(self.bclVM.legacyDetailModel?.data?.postComments?.count ?? 0) comments")
                    .font(.custom(Constant.FontStyle.TMedium.rawValue, size: Constant.FontSize._14FontSize))
                    .foregroundColor(Color.CustomColor.AppBCLColor)
            })
            
            .padding(.bottom, 1)
            
            if let commentsArr = self.bclVM.legacyDetailModel?.data?.postComments?.prefix(2) {
                ForEach(commentsArr, id: \.self) { comment in
                    HStack {
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
            
            Button(action: {
                self.bclVM.postID = self.bclVM.legacyDetailModel?.data?.postID ?? 0
                self.bclVM.updatedCommentPostId = self.bclVM.legacyDetailModel?.data?.postID ?? 0
                self.bclVM.isCommentUpdated = true
                self.bclVM.moveToComments = true
                print("Add Comment")
            }, label: {
                Text(" Add a comment")
                    .font(.custom(Constant.FontStyle.TMedium.rawValue, size: Constant.FontSize._14FontSize))
                    .foregroundColor(Color.CustomColor.AppBCLColor)
            })
            
        }
        .padding(.horizontal, 10)
        
    }
}

// MARK: - Previews
struct BCLDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        BCLDetailsView()
    }
}


