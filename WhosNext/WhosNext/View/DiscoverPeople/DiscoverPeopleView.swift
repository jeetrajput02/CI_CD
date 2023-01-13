//
//  DiscoverPeopleView.swift
//  WhosNext
//
//  Created by differenz195 on 21/10/22.
//

import SwiftUI
import AVKit
import SDWebImageSwiftUI

struct DiscoverPeopleView: View {
    // MARK: - Variables
    @StateObject private var sidebarVM: SidebarViewModel = SidebarViewModel()
    @StateObject private var discoverVM: DiscoverViewModel = DiscoverViewModel()

    @State var userID: Int = 0
    @State var userFullName: String = ""
    @State private var isSideBarOpened = false
    
    var body: some View {
        ZStack {
            self.sideMenuNavigationLink()
            NavigationLink(destination: ProfileView(userId: self.userID, userFullName: self.userFullName, isShowbackBtn: true), isActive: self.$discoverVM.moveToProfile, label: {})
            
            VStack {
                self.categoryTextfield
                
                ZStack {
                    VStack {
                        self.searchTextField

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
                        } else {
                            Image(IdentifiableKeys.ImageName.kDiscoverBackgroundImage)
                                .resizable()
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
            .navigationBarItems(leading: HStack {
                Button {
                    self.isSideBarOpened = true
                } label: {
                    Image(IdentifiableKeys.ImageName.kMenuBar)
                }
                
                Text(IdentifiableKeys.NavigationbarTitles.kDiscoverPeople)
                    .font(.custom(Constant.FontStyle.Heavy.rawValue, size: Constant.FontSize._28FontSize))
            })

            SideMenuView(sidebarVM: self.sidebarVM, isSidebarVisible: self.$isSideBarOpened)
                .environment(\.moveToOtherView, self.sidebarVM.moveToView)
        }
        .hideNavigationBar(isSideBarMenuOpen: self.isSideBarOpened)
        .navigationBarColor(backgroundColor: UIColor(named: "uniColor"))
    }
}

// MARK: - UI Helpers
extension DiscoverPeopleView {
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
                    VStack(alignment: .leading) {
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

// MARK: - Helper Methods
extension DiscoverPeopleView {
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
                
                if self.sidebarVM.navigationLink == menuItemName.kBreastCancerLegacies {
                    /// `move to breast cancerlegacies screen`
                    NavigationLink("", destination: BreastCancerLegaciesView(), tag: menuItemName.kBreastCancerLegacies, selection: self.$sidebarVM.navigationLink)
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
                        if self.sidebarVM.navigationLink == menuItemName.kSnippetsList {
                            /// `move to snippet list screen`
                            NavigationLink("", destination: SnippetsListView(), tag: menuItemName.kSnippetsList, selection: self.$sidebarVM.navigationLink)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Previews
struct DiscoverPeopleView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverPeopleView()
    }
}
