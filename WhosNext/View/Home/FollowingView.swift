//
//  FollowingView.swift
//  WhosNext
//
//  Created by differenz195 on 17/10/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct FollowingView: View {
    //MARK: - Variables
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    @StateObject private var followingVM: FollowingViewModel = FollowingViewModel()

    var userId: Int?

    var body: some View {
        ZStack {
            NavigationLink(destination: ProfileView(userId: self.followingVM.selectedUser?.userID ?? 0, userFullName: "\(self.followingVM.selectedUser?.firstName ?? "") \(self.followingVM.selectedUser?.lastName ?? "")", isShowbackBtn: true), isActive: self.$followingVM.moveToProfile, label: {})

            VStack {
                SearchBar(searchText: self.$followingVM.searchText)
                    .padding(.bottom, 12.0)
                
                self.followingUserList
            }
        }
        .padding(.horizontal, 10.0)
        .onAppear {
            self.followingVM.userId = self.userId ?? -1

            self.followingVM.getUserFollowingList()
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
                    
                    Text(IdentifiableKeys.NavigationbarTitles.kFollowing)
                        .font(.custom(Constant.FontStyle.Heavy.rawValue, size: Constant.FontSize._28FontSize))
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button {
                        self.followingVM.getUserFollowingList()
                    } label: {
                        Image(IdentifiableKeys.ImageName.kBlackRefresh)
                    }
                }
            }
        }
        .onChange(of: self.followingVM.searchText, perform: { searchText in
            if self.followingVM.searchText.trimWhiteSpace == "" {
                if self.followingVM.searchText.last == " " {
                    self.followingVM.searchText.removeLast()
                }
            }
        })
    }
}

// MARK: - UI Helpers
extension FollowingView {
    private var followingUserList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading) {
                if let followingArr = self.followingVM.followingModel?.data?.filter({ ($0.firstName ?? "").hasPrefix(self.followingVM.searchText) ||
                    ($0.lastName ?? "").hasPrefix(self.followingVM.searchText) || ($0.username ?? "").hasPrefix(self.followingVM.searchText) || self.followingVM.searchText == "" }) {
                    ForEach(followingArr, id: \.self) { user in
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
                                            self.followingVM.selectedUser = user
                                            self.followingVM.showFollowunFollowActionSheet.toggle()
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
                        .confirmationDialog("", isPresented: self.$followingVM.showFollowunFollowActionSheet, actions: {
                            Button(role: .destructive, action: {
                                self.followingVM.followUnfollowUser(userId: self.followingVM.selectedUser?.userID ?? 0) {
                                    self.followingVM.selectedUser = nil
                                    self.followingVM.getUserFollowingList()
                                }
                            }, label: {
                                Text(IdentifiableKeys.Buttons.kUnfollow)
                            })
                        }, message: {
                            Text("Unfollow '\(self.followingVM.selectedUser?.username ?? "")'?")
                        })
                        .onTapGesture {
                            self.followingVM.selectedUser = user
                            self.followingVM.moveToProfile = true
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
struct FollowingView_Previews: PreviewProvider {
    static var previews: some View {
        FollowingView()
    }
}
