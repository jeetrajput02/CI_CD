//
//  FollowersView.swift
//  WhosNext
//
//  Created by differenz195 on 14/10/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct FollowersView: View {
    //MARK: - Variables
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    @StateObject private var followersVM: FollowersViewModel = FollowersViewModel()
    
    var userId: Int?

    var body: some View {
        ZStack {
            NavigationLink(destination: ProfileView(userId: self.followersVM.selectedUser?.userID ?? 0, userFullName: "\(self.followersVM.selectedUser?.firstName ?? "") \(self.followersVM.selectedUser?.lastName ?? "")", isShowbackBtn: true), isActive: self.$followersVM.moveToProfile, label: {})

            VStack {
                SearchBar(searchText: self.$followersVM.searchText)
                    .padding(.bottom, 12.0)
                
                self.followersList
            }
        }
        .padding(.horizontal, 10.0)
        .onAppear {
            self.followersVM.userId = self.userId ?? -1

            self.followersVM.getUserFollowersList()
        }
        .padding(.horizontal, 5.0)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button {
                        self.presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(IdentifiableKeys.ImageName.kBackArrowBlack)
                    }
                    
                    Text(IdentifiableKeys.NavigationbarTitles.kFollowers)
                        .font(.custom(Constant.FontStyle.Heavy.rawValue, size: Constant.FontSize._28FontSize))
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button {
                        self.followersVM.getUserFollowersList()
                    } label: {
                        Image(IdentifiableKeys.ImageName.kBlackRefresh)
                    }
                }
            }
        }
        .onChange(of: self.followersVM.searchText, perform: { searchText in
            if self.followersVM.searchText.trimWhiteSpace == "" {
                if self.followersVM.searchText.last == " " {
                    self.followersVM.searchText.removeLast()
                }
            }
        })
    }
}

// MARK: - UI Helpers
extension FollowersView {
    private var followersList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading) {
                if let followersArr = self.followersVM.followerModel?.data?.filter({ ($0.firstName ?? "").hasPrefix(self.followersVM.searchText) ||
                    ($0.lastName ?? "").hasPrefix(self.followersVM.searchText) || ($0.username ?? "").hasPrefix(self.followersVM.searchText) || self.followersVM.searchText == "" }) {
                    ForEach(followersArr, id: \.self) { user in
                        HStack {
                            WebImage(url: URL(string: user.introductionVideoThumb ?? ""))
                                .placeholder(Image(IdentifiableKeys.ImageName.kAvatar))
                                .resizable()
                                .indicator(.activity)
                                .clipShape(Circle())
                                .frame(width: 45, height: 45)
                            
                            VStack(alignment: .leading) {
                                Text("\(user.firstName ?? "") \(user.lastName ?? "")").fontWeight(.semibold)
                            }
                            .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))

                            Spacer()

                            if let currentUser = UserDefaults.getData(UserDefaultsKey.kLoginUser, data: UserModel.self) {
                                if currentUser.userId != user.userID ?? 0 {
                                    VStack(alignment: .trailing) {
                                        Button(action: {
                                            self.followersVM.selectedUser = user
                                            self.followersVM.showFollowunFollowActionSheet.toggle()
                                        }, label: {
                                            Text(user.userFollowStatus == 0 ? "+ Follow" : (user.userFollowStatus == 1 ? "Requested" : "Following"))
                                                .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._14FontSize))
                                                .foregroundColor(Color.myCustomColor)
                                            
                                        })
                                        .padding(.horizontal, 14.0)
                                        .padding(.vertical, 10.0)
                                        .background(Color.myDarkCustomColor)
                                        .cornerRadius(5.0)
                                    }
                                    .padding(.trailing,15.0)
                                }
                            }
                        }
                        .confirmationDialog("", isPresented: self.$followersVM.showFollowunFollowActionSheet, actions: {
                            Button(role: .destructive, action: {
                                self.followersVM.followUnfollowUser(userId: self.followersVM.selectedUser?.userID ?? 0) {
                                    self.followersVM.selectedUser = nil
                                    self.followersVM.getUserFollowersList()
                                }
                            }, label: {
                                Text(self.followersVM.selectedUser?.userFollowStatus == 0 ? "Follow" : IdentifiableKeys.Buttons.kUnfollow)
                            })
                        }, message: {
                            if self.followersVM.selectedUser?.userFollowStatus == 0 {
                                Text("Follow '\(self.followersVM.selectedUser?.username ?? "")?'")
                            } else {
                                Text("If you change your mind, you'll have to request to follow '\(self.followersVM.selectedUser?.username ?? "")' again.")
                            }
                        })
                        .onTapGesture {
                            self.followersVM.selectedUser = user
                            self.followersVM.moveToProfile = true
                        }
                        
                        RoundedRectangle(cornerRadius: 0)
                            .frame(height: 1.0)
                            .foregroundColor(Color.CustomColor.AppSnippetsColor)
                            .padding(.leading, 5.0)
                    }
                }
            }
        }
    }
}

// MARK: - Previews
struct FollowersView_Previews: PreviewProvider {
    static var previews: some View {
        FollowersView()
    }
}
