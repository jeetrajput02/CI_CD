//
//  SelectGroupVideoPeopleView.swift
//  WhosNext
//
//  Created by differenz240 on 04/01/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct SelectGroupVideoPeopleView: View {
    // MARK: - Variables
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @EnvironmentObject private var viewRouter: ViewRouter

    @StateObject private var discoverVM: DiscoverViewModel = DiscoverViewModel()
    @StateObject private var notificationVM: NotificationViewModel = NotificationViewModel()

    
    @StateObject var shareToVM: ShareToViewModel
    @Binding var selectedUsers: [AllUserListData]
    @Binding var text: String?

    var postDetailsModel: PostDetailModel?
    var selectedGroupVideo: GroupVideoUserArr?
    
    @State var userID: Int = 0
    @State var userFullName: String = ""
    @Binding var maximumPeople: Int
    @State private var selectedPeopleForGroupVideo: [GetUsersByCategoryData] = []

    var body: some View {
        ZStack {
            NavigationLink(destination: ProfileView(userId: self.userID, userFullName: self.userFullName, isShowbackBtn: true), isActive: self.$discoverVM.moveToProfile, label: {})
            
            VStack {
                if self.shareToVM.isUploading {
                    LinearProgressBar(title: "Loading...", progress: self.$shareToVM.progress)
                        .onChange(of: self.notificationVM.progress, perform: { progress in
                            self.shareToVM.progress = progress
                        })
                        .onChange(of: self.shareToVM.progress, perform: { progress in
                            if progress == 100.0 {
                                self.self.shareToVM.isUploading = false
                                self.shareToVM.progress = 0.0
                            }
                        })
                }

                self.categoryTextfield
                
                ZStack {
                    VStack {
                        HStack {
                            self.searchTextField

                            Button(action: {
                                self.discoverVM.selectedCategory = nil
                                self.discoverVM.searchedCategory = ""
                            }, label: {
                                Text("Cancel")
                                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._14FontSize))
                            })
                        }
                        .padding(.trailing, 10.0)
                        
                        if self.discoverVM.selectedCategory != nil || self.discoverVM.searchedCategory != "" {
                            if let usersByCategoryData = self.discoverVM.userListByCategory?.data, usersByCategoryData.count > 0 {
                                self.userListByCategory
                            } else {
                                VStack {
                                    Text("No Users Found")
                                        .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._18FontSize))
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }

                        Spacer()

                        VStack(alignment: .leading) {
                            HStack(spacing: 12.0) {
                                ForEach(self.selectedPeopleForGroupVideo, id: \.self) { people in
                                    ZStack(alignment: .topTrailing) {
                                        WebImage(url: URL(string: people.introductionVideoThumb ?? ""))
                                            .placeholder(Image(IdentifiableKeys.ImageName.kAvatar).resizable())
                                            .resizable()
                                            .indicator(.activity)
                                            .clipShape(Circle())
                                            .frame(width: 50.0, height: 50.0)

                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(Color.gray)
                                            .frame(width: 25.0, height: 25.0)
                                            .offset(x: 6.0, y: -6.0)
                                    }
                                    .onTapGesture {
                                        self.selectedPeopleForGroupVideo.removeAll(where: { $0 == people })
                                    }
                                }

                                Spacer()
                            }
                            .frame(height: 70.0)
                            .padding(.horizontal, 8.0)
                        }

                        CommonButton(title: IdentifiableKeys.Buttons.kSubmit, cornerradius: 0) {
                            if self.selectedPeopleForGroupVideo.count > self.maximumPeople {
                                Alert.show(message: "You must invite \(self.maximumPeople) friends.")
                            } else {
                                if self.shareToVM.isUploading == false {
                                    var postId = ""
                                    
                                    let tagPeople = self.selectedUsers.map({ "\($0.userID ?? 0)" }).joined(separator: ",")
                                    let taggedPeopleInGroupVideo = self.selectedPeopleForGroupVideo.map({ "\($0.userID ?? 0)" }).joined(separator: ",")
                                    
                                    if self.maximumPeople == 4 {
                                        if self.postDetailsModel != nil {
                                            postId = "\(self.postDetailsModel?.data?.postID ?? 0)"
                                        } else {
                                            postId = ""
                                        }
                                        
                                        self.shareToVM.isUploading = true
                                        
                                        self.shareToVM.createPostWithVideo(postID: postId, postType: 2, postSubType: 3, postCaption: self.text ?? "",
                                                                           taggedSelectedPeople: tagPeople, taggedSelectedPeopleInGroupVideo: taggedPeopleInGroupVideo) {
                                            self.viewRouter.currentView = .Home
                                            NavigationUtil.popToRootView()
                                        }
                                    } else if self.maximumPeople == 1 {
                                        self.shareToVM.isUploading = true

                                        let post_id = "\(self.selectedGroupVideo?.postID ?? 0)"
                                        let user_id =  "\(self.selectedPeopleForGroupVideo.first?.userID ?? 0)"
                                        let invited_user_id = "\(self.selectedGroupVideo?.invitedUserID ?? 0)"
                                        let user_group_id = "\(self.selectedGroupVideo?.userGroupID ?? 0)"

                                        self.notificationVM.updateGroupUserAPI(postID: post_id, userID: user_id, invitedUserID: invited_user_id, userGroupID: user_group_id) {
                                            self.presentationMode.wrappedValue.dismiss()
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    if self.discoverVM.shouldShowCategoryDropDown {
                        self.categoryList
                    }
                }
            }
            .onAppear {
                self.discoverVM.getCategoryList(completion: { _ in
                    self.discoverVM.getUsersByCategory()
                })
            }
            .onDisappear {
                self.shareToVM.isUploading = false
                self.shareToVM.progress = 0.0
                self.notificationVM.progress = 0.0
            }
            .onChange(of: self.discoverVM.searchedCategory, perform: { searchedCategory in
                if self.discoverVM.searchedCategory.trimWhiteSpace == "" {
                    if searchedCategory.last == " " {
                        self.discoverVM.searchedCategory.removeLast()
                    }
                } else {
                    self.discoverVM.getUsersByCategory()
                }
            })
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Button {
                            self.presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(IdentifiableKeys.ImageName.kBackArrowBlack)
                        }
                        
                        Text(IdentifiableKeys.NavigationbarTitles.kVideos)
                            .font(.custom(Constant.FontStyle.Heavy.rawValue, size: Constant.FontSize._28FontSize))
                    }
                }
            }
        }
        .navigationBarColor(backgroundColor: UIColor(named: "uniColor"))
    }
}

// MARK: - UI Helpers
extension SelectGroupVideoPeopleView {
    /// `category` textfield
    private var categoryTextfield: some View {
        VStack {
            HStack(spacing: 0) {
                Text(self.discoverVM.selectedCategory == nil ? "Select Category" : self.discoverVM.selectedCategory?.category ?? "")
                    .padding(.leading,10)
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
                    .padding(.leading, 10)
                    .foregroundColor(Color.myDarkCustomColor)
                
                Spacer()
                
                Image(IdentifiableKeys.ImageName.kDropdown)
                    .resizable()
                    .frame(width: 12, height: 12)
                    .padding(.trailing, 20)
            }
            .frame(width: ScreenSize.SCREEN_WIDTH - 20, height: 40, alignment: .center)
            .background(Color.appSnippetsColor)
            .cornerRadius(5)
            .padding(10)
        }
        .onTapGesture {
            self.discoverVM.shouldShowCategoryDropDown.toggle()
        }
    }
    
    /// `category` list view
    private var categoryList: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading) {
                    ForEach(self.discoverVM.categoryList, id: \.self) { category in
                        Text(category.category)
                            .onTapGesture {
                                self.discoverVM.searchedCategory = ""
                                
                                self.discoverVM.setSelectedCategory(category: category)
                                self.discoverVM.shouldShowCategoryDropDown.toggle()
                                
                                self.discoverVM.getUsersByCategory()
                            }
                        
                        RoundedRectangle(cornerRadius: 0)
                            .frame(height: 1)
                            .foregroundColor(Color.appSnippetsColor)
                    }
                }
                .padding([.horizontal, .top], 10)
            }
            .background(Color.myCustomColor)
            .frame(maxHeight: ScreenSize.SCREEN_HEIGHT / 2)
            
            Spacer()
        }
    }
    
    /// `user by category` list view
    private var userListByCategory: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading) {
                ForEach(self.discoverVM.userListByCategory?.data ?? [], id: \.self) { user in
                    if self.selectedPeopleForGroupVideo.contains(where: { $0 == user }) == false {
                        VStack(alignment: .leading) {
                            HStack {
                                HStack(alignment: .center, spacing: 12.0) {
                                    WebImage(url: URL(string: user.introductionVideoThumb ?? ""))
                                        .placeholder(Image(IdentifiableKeys.ImageName.kAvatar))
                                        .resizable()
                                        .indicator(.activity)
                                        .clipShape(Circle())
                                        .frame(width: 45, height: 45)
                                    
                                    VStack(alignment: .leading, spacing: 4.0) {
                                        Text(user.fullName ?? "Test User")
                                            .fontWeight(.bold)
                                        Text(user.username ?? "testuser")
                                    }
                                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._14FontSize))
                                    
                                    Spacer()
                                }
                                
                                Button(action: {
                                    if self.selectedPeopleForGroupVideo.count != self.maximumPeople {
                                        self.selectedPeopleForGroupVideo.append(user)
                                    } else {
                                        Alert.show(message: "You can only invite \(self.maximumPeople) friends.")
                                    }
                                }, label: {
                                    Text("Invite")
                                        .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._14FontSize))
                                        .padding()
                                })
                                .frame(height: 40.0)
                                .foregroundColor(Color.myCustomColor)
                                .background(Color.myDarkCustomColor)
                                .cornerRadius(10.0)
                            }
                            .onTapGesture {
                                self.userID = user.userID ?? 0
                                if user.fullName == nil {
                                    self.userFullName = "\(user.firstName ?? "") \(user.lastName ?? "")"
                                } else {
                                    self.userFullName = user.fullName ?? ""
                                }
                                
                                if self.userID != 0 {
                                    self.discoverVM.moveToProfile = true
                                }
                                print("================= \(user.userID ?? 0) =================")
                            }
                            .frame(maxWidth: .infinity)
                            
                            RoundedRectangle(cornerRadius: 0)
                                .frame(height: 1.5)
                                .foregroundColor(Color.CustomColor.AppSnippetsColor)
                        }
                    }
                }
            }
        }
        .padding(.all, 4.0)
    }
    
    /// `search` textfield
    private var searchTextField: some View {
        VStack {
            SearchBar(searchText: self.$discoverVM.searchedCategory)
        }
        .padding(.horizontal, 10)
    }
}

//// MARK: - Previews
//struct SelectGroupVideoPeopleView_Previews: PreviewProvider {
//    static var previews: some View {
//        SelectGroupVideoPeopleView(shareToVM: ShareToViewModel(), selectedUsers: .constant([]), text: .constant(nil))
//    }
//}
