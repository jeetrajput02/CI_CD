//
//  NotificationView.swift
//  WhosNext
//
//  Created by differenz195 on 13/10/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct NotificationView: View {
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @StateObject private var shareToVM: ShareToViewModel = ShareToViewModel()
    
    @StateObject private var notificationVM: NotificationViewModel = NotificationViewModel()
    @State var notificationGroupVideoData: NotificationData = NotificationData()
    
    @State private var text: String?
    @State private var selectedUsers = [AllUserListData]()
    @State var maxPeoples: Int = 1
    @State var isActive: Bool = false

    var body: some View {
        ZStack {
            Group {
                if let selectedNotification = self.notificationVM.selectedNotification {
                    NavigationLink(destination:  PictureDetailsView(postId: "\(selectedNotification.notificationValue ?? "0")", postType: selectedNotification.post?.postType ?? 0),
                                   isActive: self.$notificationVM.moveToPictureDetails, label: {})
                }

                NavigationLink(destination: SelectGroupVideoPeopleView(shareToVM: self.shareToVM, selectedUsers: self.$selectedUsers, text: self.$text, selectedGroupVideo: self.notificationVM.selectedGroupVideo, maximumPeople: self.$maxPeoples), isActive: self.$isActive, label: {})

                NavigationLink(destination: UpdateGroupVideoView(groupData: self.$notificationGroupVideoData), isActive: self.$notificationVM.moveToUpdateGroupVideoView, label: {})
            }
            
            VStack {
                ScrollView(showsIndicators: false) {
                    LazyVStack {
                        ForEach(self.$notificationVM.notificationList, id: \.self) { $notification in
                            switch (notification.notificationType ?? 0) {
                                case NotificationType.simplePostCreated.rawValue: // 1
                                    LikeAndTagNotificationView(notification: $notification, notificationVM: self.notificationVM)
                                    
                                case NotificationType.groupVideoPostCreated.rawValue: // 2
                                    LikeAndTagNotificationView(notification: $notification, notificationVM: self.notificationVM)
                                    
                                case NotificationType.taggedInPost.rawValue: // 3
                                    LikeAndTagNotificationView(notification: $notification, notificationVM: self.notificationVM)

                                case NotificationType.taggedInGroupVideo.rawValue: // 4
                                    GroupVideoNotificationView(notificationGroupVideoData: self.$notificationGroupVideoData, notification: $notification, notificationVM: self.notificationVM, isActive: self.$isActive)

                                /* case NotificationType.groupVideoResponseUploadRequest.rawValue: // 5
                                    EmptyView() */

                                case NotificationType.commentOnPost.rawValue: // 6
                                    CommentNotificationView(notification: $notification, notificationVM: self.notificationVM)

                                case NotificationType.likePost.rawValue: // 7
                                    LikeAndTagNotificationView(notification: $notification, notificationVM: self.notificationVM)

                                case NotificationType.sendFollowingRequest.rawValue: // 8
                                    SendFollowingView(notification: $notification, notificationVM: self.notificationVM, isFollow: true)
                                    
                                case NotificationType.acceptFollowingRequest.rawValue: // 9
                                    EmptyView()

                                case NotificationType.directFollow.rawValue: // 10
                                    SendFollowingView(notification: $notification, notificationVM: self.notificationVM, isFollow: false)

                                /* case NotificationType.chat.rawValue: // 11
                                    EmptyView() */

                                default:
                                    EmptyView()
                            }
                        }
                    }
                }
                .padding(EdgeInsets(top: 8.0, leading: 8.0, bottom: 0.0, trailing: 8.0))
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(IdentifiableKeys.ImageName.kBackArrowBlack)
                    })
                    
                    Text(IdentifiableKeys.NavigationbarTitles.kNotification)
                        .font(.custom(Constant.FontStyle.Heavy.rawValue, size: Constant.FontSize._28FontSize))
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: {
                        self.notificationVM.getNotificationList()
                    }, label: {
                        Image(IdentifiableKeys.ImageName.kBlackRefresh)
                    })
                }
            }
        }
        .onAppear {
            self.notificationVM.selectedNotification = nil
            self.notificationVM.selectedGroupVideo = nil
         
            self.notificationVM.getNotificationList()
        }
    }
}

// MARK: - Custom Views
private extension NotificationView {
    /// `like and tag notification view`
    private struct LikeAndTagNotificationView: View {
        @Binding var notification: NotificationData
        @StateObject var notificationVM: NotificationViewModel
        var tagPost = false
        
        var body: some View {
            LazyVStack {
                HStack {
                    WebImage(url: URL(string: self.notification.introductionVideoThumb ?? ""))
                        .placeholder(Image(IdentifiableKeys.ImageName.kAvatar).resizable())
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 45.0, height: 45.0)
                    
                    Spacer().frame(width: 12.0)

                    VStack(alignment: .leading, spacing: 4.0) {
                        Text(self.notification.username ?? "")
                            .font(.custom(Constant.FontStyle.Bold.rawValue, size: Constant.FontSize._16FontSize))
                        
                        Text(self.notification.body ?? "")
                            .font(.custom(Constant.FontStyle.Regular.rawValue, size: Constant.FontSize._16FontSize))
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text(notification.timeDisplayStr ?? "")
                            .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._14FontSize))
                        
                        WebImage(url: URL(string: self.notification.post?.postThumbnail ?? ""))
                            .placeholder(Image(IdentifiableKeys.ImageName.kAvatar).resizable())
                            .resizable()
                            .frame(width: 35.0, height: 35.0)
                    }
                }
                
                RoundedRectangle(cornerRadius: 0)
                    .frame(height: 1)
                    .foregroundColor(Color.CustomColor.AppSnippetsColor)
            }
            .onTapGesture {
                self.notificationVM.selectedNotification = self.notification
                self.notificationVM.moveToPictureDetails = true
            }
        }
    }
    
    /// `group video notification view`
    struct GroupVideoNotificationView: View {
        @Binding var notificationGroupVideoData: NotificationData
        @Binding var notification: NotificationData
        @StateObject var notificationVM: NotificationViewModel
        @Binding var isActive: Bool

        var body: some View {
            VStack {
                VStack {
                    HStack {
                        WebImage(url: URL(string: self.notification.introductionVideoThumb ?? ""))
                            .resizable()
                            .clipShape(Circle())
                            .frame(width: 45.0, height: 45.0)
                        
                        Spacer().frame(width: 12.0)
                        
                        VStack(alignment: .leading, spacing: 4.0) {
                            Text(self.notification.username ?? "")
                                .font(.custom(Constant.FontStyle.Bold.rawValue, size: Constant.FontSize._16FontSize))
                            
                            Text(self.notification.body ?? "has invited you in the group Video")
                                .font(.custom(Constant.FontStyle.Regular.rawValue, size: Constant.FontSize._16FontSize))
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text(notification.timeDisplayStr ?? "")
                                .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._14FontSize))
                            
                            WebImage(url: URL(string: self.notification.post?.postThumbnail ?? ""))
                                .placeholder(Image(IdentifiableKeys.ImageName.kAvatar).resizable())
                                .resizable()
                                .frame(width: 35.0, height: 35.0)
                        }
                    }
                    
                    VStack {
                        ForEach(0 ..< (self.notification.groupVideoUserArr?.count ?? 0), id: \.self) { i in
                            HStack {
                                Spacer()
                                    .frame(width: 57)
                                
                                WebImage(url: URL(string: self.notification.groupVideoUserArr?[i].introductionVideoThumb ?? ""))
                                    .placeholder(Image(IdentifiableKeys.ImageName.kAvatar).resizable())
                                    .resizable()
                                    .clipShape(Circle())
                                    .frame(width: 35.0, height: 35.0)

                                Text(self.notification.groupVideoUserArr?[i].username ?? "")
                                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))

                                Spacer()

                                /// `custom actions on buttons`
                                switch self.notification.groupVideoUserArr?[i].showField {
                                    case ShowField.button.rawValue:
                                        HStack {
                                            Button(action: {
                                                self.notificationGroupVideoData = self.notification
                                                self.notificationVM.moveToUpdateGroupVideoView = true
                                            }, label: {
                                                Text("Accept ✓")
                                                    .font(.custom(Constant.FontStyle.Regular.rawValue, size: Constant.FontSize._16FontSize))
                                                .padding(.all, 5)
                                            })
                                            
                                            .frame(height: 25)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(10)
                                            .tint(.blue)
                                            
                                            Button(action: {
                                                notificationVM.rejectGroupVideoRequestApi(postID: "\(self.notification.post?.postID ?? 0)") {
                                                    self.notification.groupVideoUserArr?[i].showField = 4
                                                    print("Rejected")
                                                }
                                            }, label: {
                                                HStack(spacing: 0) {
                                                    Text("Reject")
                                                        .font(.custom(Constant.FontStyle.Regular.rawValue, size: Constant.FontSize._16FontSize))
                                                        .padding(.leading,5)
                                                        .layoutPriority(1)

                                                    Text("❌").padding(.trailing,5)
                                                        .frame(height: 10)
                                                        .scaleEffect(0.7)
                                                }
                                            })
                                            .frame(height: 25)
                                            .background(Color.red.opacity(0.1))
                                            .cornerRadius(10)
                                            .tint(.red)
                                        }
                                        .padding(.horizontal, 5)
                                        
                                    case ShowField.pending.rawValue:
                                        Text("Pending")
                                            .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._17FontSize))
                                            .foregroundColor(.gray)
                                        
                                    case ShowField.uploaded.rawValue:
                                        Text("Uploaded")
                                            .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._17FontSize))
                                            .foregroundColor(.gray)
                                        
                                    case ShowField.rejected.rawValue:
                                        Text("Rejected")
                                            .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._17FontSize))
                                            .foregroundColor(.gray)
                                        
                                    default:
                                        EmptyView()
                                }
                                
                                switch self.notification.groupVideoUserArr?[i].showField {
                                    case ShowField.rejected.rawValue:
                                        Image(IdentifiableKeys.ImageName.kCancel)
                                            .resizable()
                                            .frame(width: 35.0, height: 35.0)
                                        
                                    case ShowField.uploaded.rawValue:
                                        WebImage(url: URL(string: self.notification.groupVideoUserArr?[i].invitedUserVideoThumbnailURL ?? "")   )
                                            .placeholder(Image(IdentifiableKeys.ImageName.kQuestionMark).resizable())
                                            .resizable()
                                            .frame(width: 35.0, height: 35.0)
                                        
                                    case ShowField.pending.rawValue:
                                        ZStack(alignment: .topLeading) {
                                            WebImage(url: URL(string: self.notification.groupVideoUserArr?[i].invitedUserVideoThumbnailURL ?? "")   )
                                                .placeholder(Image(IdentifiableKeys.ImageName.kQuestionMark).resizable())
                                                .resizable()
                                                .frame(width: 35.0, height: 35.0)
                                            
                                            if self.notification.groupVideoUserArr?[i].replaceUserPermission == 1 {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(Color.gray)
                                                    .frame(width: 25.0, height: 25.0)
                                                    .offset(x: -6.0, y: -6.0)
                                                    .onTapGesture {
                                                        self.notificationVM.selectedGroupVideo = self.notification.groupVideoUserArr?[i]
                                                        self.isActive = true
                                                    }
                                            }
                                        }
                                        
                                    default:
                                        WebImage(url: URL(string: self.notification.groupVideoUserArr?[i].invitedUserVideoThumbnailURL ?? "")   )
                                            .placeholder(Image(IdentifiableKeys.ImageName.kQuestionMark).resizable())
                                            .resizable()
                                            .frame(width: 35.0, height: 35.0)
                                }
                            }
                            .padding(.vertical , 5)
                            
                        }
                    }

                    RoundedRectangle(cornerRadius: 0)
                        .frame(height: 1)
                        .foregroundColor(Color.CustomColor.AppSnippetsColor)
                }
                .background(Color.gray.opacity(0.05))
                
            }
            /* .onTapGesture {
                self.notificationVM.selectedNotification = self.notification
                self.notificationVM.moveToPictureDetails = true
            } */
        }
    }
    
    /// `comment notification view`
    private struct CommentNotificationView: View {
        @Binding var notification: NotificationData
        @StateObject var notificationVM: NotificationViewModel
        
        var body: some View {
            LazyVStack {
                HStack {
                    WebImage(url: URL(string: self.notification.introductionVideoThumb ?? ""))
                        .placeholder(Image(IdentifiableKeys.ImageName.kAvatar).resizable())
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 45.0, height: 45.0)
                    
                    Spacer().frame(width: 12.0)
                    
                    VStack(alignment: .leading, spacing: 4.0) {
                        Text(self.notification.username ?? "")
                            .font(.custom(Constant.FontStyle.Bold.rawValue, size: Constant.FontSize._16FontSize))
                        
                        Text(self.notification.body ?? "commented on your video")
                            .font(.custom(Constant.FontStyle.Regular.rawValue, size: Constant.FontSize._16FontSize))
                    }
                    
                    Spacer()
                    
                    VStack() {
                        Text(notification.timeDisplayStr ?? "")
                            .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._14FontSize))
                        
                        WebImage(url: URL(string: self.notification.post?.postThumbnail ?? ""))
                            .placeholder(Image(IdentifiableKeys.ImageName.kAvatar).resizable())
                            .resizable()
                            .frame(width: 35.0, height: 35.0)
                    }
                }
                
                RoundedRectangle(cornerRadius: 0)
                    .frame(height: 1)
                    .foregroundColor(Color.CustomColor.AppSnippetsColor)
            }
            .onTapGesture {
                self.notificationVM.selectedNotification = self.notification
                self.notificationVM.moveToPictureDetails = true
            }
        }
    }
    
    /// `send following request`
    private struct SendFollowingView: View {
        @Binding var notification: NotificationData
        @StateObject var notificationVM: NotificationViewModel
        var isFollow = false
        
        var body: some View {
            LazyVStack {
                HStack {
                    WebImage(url: URL(string: self.notification.introductionVideoThumb ?? ""))
                        .placeholder(Image(IdentifiableKeys.ImageName.kAvatar).resizable())
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 45.0, height: 45.0)
                    
                    Spacer().frame(width: 12.0)
                    
                    VStack(alignment: .leading, spacing: 4.0) {
                        Text(self.notification.username ?? "")
                            .font(.custom(Constant.FontStyle.Bold.rawValue, size: Constant.FontSize._16FontSize))
                        
                        Text(self.notification.body ?? "requested to follow you.")
                            .font(.custom(Constant.FontStyle.Regular.rawValue, size: Constant.FontSize._16FontSize))
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text(notification.timeDisplayStr ?? "")
                            .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._14FontSize))
                        
                        if isFollow {
                            HStack {
                                Button(action: {
                                    notificationVM.acceptRejectRequestApi(userID: "\(self.notification.senderID ?? 0 )", followType: "2") {
                                        notificationVM.getNotificationList()
                                    }
                                }, label: {
                                    Text("Accept ✓")
                                        .font(.custom(Constant.FontStyle.Regular.rawValue, size: Constant.FontSize._16FontSize))
                                        .padding(.all, 5)
                                })
                                .frame(height: 25)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                                .tint(.blue)
                                
                                Button(action: {
                                    notificationVM.acceptRejectRequestApi(userID: "\(self.notification.senderID ?? 0 )", followType: "3") {
                                        notificationVM.getNotificationList()
                                    }
                                }, label: { HStack(spacing: 0){
                                    Text("Reject")
                                        .font(.custom(Constant.FontStyle.Regular.rawValue, size: Constant.FontSize._16FontSize))
                                        .padding(.leading,3)
                                        .layoutPriority(1)
                                    Text("❌").padding(.trailing,5)
                                        .frame(height: 10)
                                        .scaleEffect(0.7)
                                } })
                                .frame(height: 25)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(10)
                                .tint(.red)
                            }
                            
                            .padding(.horizontal, 5)
                        } else {
                            Text("Following")
                                .font(.custom(Constant.FontStyle.Regular.rawValue, size: Constant.FontSize._16FontSize))
                                .foregroundColor(.gray)
                                .padding(.all,3)
                                .border(Color.myDarkCustomColor, width: 1)
                        }
                    }
                }
                
                RoundedRectangle(cornerRadius: 0)
                    .frame(height: 1)
                    .foregroundColor(Color.CustomColor.AppSnippetsColor)
            }
            .onAppear {
                if self.notification.introductionVideoThumb?.contains("http") == false {
                    self.notification.introductionVideoThumb = "https://d234fq55kjo26g.cloudfront.net/introduction_video/thumb/\(self.notification.introductionVideoThumb!)"
                }
            }
            .onTapGesture {
                self.notificationVM.selectedNotification = self.notification
                self.notificationVM.moveToProfile = true
            }
        }
    }
}

// MARK: - Previews
struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
    }
}
