//
//  CategoryView.swift
//  WhosNext
//
//  Created by differenz240 on 17/11/22.
//

import SwiftUI
import AVKit

struct CategoryView: View {
    @StateObject private var sidebarVM: SidebarViewModel = SidebarViewModel()
    @StateObject private var categoryVM: CategoryViewModel = CategoryViewModel()

    var body: some View {
        ZStack {
            self.sideMenuNavigationLink()
            
            VStack {
                self.searchTextfield
                    .background(Color.gray)
                self.categoryListView
            }
            .onAppear {
                self.categoryVM.getCategoryList()
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: HStack {
                Button {
                    self.categoryVM.openSideMenu()
                } label: {
                    Image(IdentifiableKeys.ImageName.kMenuBar)
                }
                
                Text(IdentifiableKeys.NavigationbarTitles.kCategory)
                    .font(.custom(Constant.FontStyle.Heavy.rawValue, size: Constant.FontSize._28FontSize))
            })
            .navigationBarColor(backgroundColor: UIColor(named: "uniColor"))
            .alert(isPresented: self.$categoryVM.showAlert) {
                if self.categoryVM.alertType == .validation {
                    return Alert(title: Text(""), message: Text(self.categoryVM.alertMsg))
                } else if self.categoryVM.alertType == .deleteConfirmation {
                    return Alert(
                        title: Text(""), message: Text(self.categoryVM.alertMsg),
                        primaryButton: .default(Text("No"), action: {}),
                        secondaryButton: .destructive(Text("Yes"), action: {
                            self.categoryVM.deleteCategoryApi()
                        })
                    )
                } else {
                    return Alert(title: Text(""))
                }
            }
            
            if self.categoryVM.isSideBarOpened {
                SideMenuView(sidebarVM: self.sidebarVM, isSidebarVisible: self.$categoryVM.isSideBarOpened)
                    .environment(\.moveToOtherView, self.sidebarVM.moveToView)
            }
        }
        .hideNavigationBar(isSideBarMenuOpen: self.categoryVM.isSideBarOpened)
    }
}

// MARK: - UI Helpers
extension CategoryView {
    /// `search` textfield
    private var searchTextfield: some View {
        ZStack {
            Color.myDarkCustomColor.frame(height: 80.0)
            
            HStack {
                Spacer().frame(width: 8.0)
                
                HStack (alignment: .center, spacing: 10.0) {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .frame(width: 20.0, height: 20.0, alignment: .center)
                        .foregroundColor(Color.myDarkCustomColor)
                    
                    TextField("Search city here", text: self.$categoryVM.searchedCategory)
                    
                    let categoryArr = self.categoryVM.categoryList.filter({ $0.category.hasPrefix(self.categoryVM.searchedCategory) || self.categoryVM.searchedCategory == "" })

                    if self.categoryVM.searchedCategory.count > 0 && categoryArr.count == 0  && self.categoryVM.searchedCategory.trimWhiteSpace != "" {
                        Button(action: {
                            self.categoryVM.addCategoryApi()
                        }, label: { Text("Add").foregroundColor(Color.myDarkCustomColor) })
                    }
                    
                }
                .font(.body)
                .padding([.top, .bottom], 4.0)
                .padding(EdgeInsets(top: 8.0, leading: 8.0, bottom: 8.0, trailing: 8.0))
                .overlay(RoundedRectangle(cornerRadius: 10.0).stroke(.black.opacity(0.7), lineWidth: 2))
                .background(Color.myCustomColor, alignment: .center)
                .cornerRadius(10.0)
                
                Spacer().frame(width: 8.0)
            }
        }
    }

    /// `category` list
    private var categoryListView: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading) {
                let categoryArr = self.categoryVM.categoryList.filter({ $0.category.hasPrefix(self.categoryVM.searchedCategory) || self.categoryVM.searchedCategory == "" })
                
                ForEach(categoryArr, id: \.self) { category in
                    HStack(alignment: .center) {
                        if self.categoryVM.selectedCateory?.categoryId == category.categoryId && self.categoryVM.categoryOperation == .edit {
                            TextField("Update the category here", text: self.$categoryVM.category)
                                .lineLimit(3)
                                .padding(.vertical, 8.0)
                                .textFieldStyle(.roundedBorder)
                        } else {
                            Text(category.category)
                                .lineLimit(3)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 16.0) {
                            Button(action: {
                                if self.categoryVM.selectedCateory?.categoryId == category.categoryId {
                                    self.categoryVM.btnEditClicked(category: category, operation: .clear)
                                } else {
                                    self.categoryVM.btnEditClicked(category: category, operation: .edit)
                                }
                            }, label: {
                                Image(systemName: self.categoryVM.selectedCateory?.categoryId == category.categoryId && self.categoryVM.categoryOperation == .edit ? "xmark.circle" : "square.and.pencil")
                            })
                            .tint(.blue)
                            
                            if self.categoryVM.selectedCateory?.categoryId == category.categoryId && self.categoryVM.categoryOperation == .edit {
                                Button(action: {
                                    self.categoryVM.updateCategoryApi()
                                }, label: {
                                    Image(systemName: "checkmark")
                                })
                                .tint(.blue)
                            } else {
                                Button(action: {
                                    self.categoryVM.openDeleteCategoryConfirmation(category: category)
                                }, label: {
                                    Image(systemName: "trash")
                                })
                                .tint(.red)
                            }
                        }
                    }
                    
                    RoundedRectangle(cornerRadius: 0)
                        .frame(height: 1.5)
                        .foregroundColor(Color.CustomColor.AppSnippetsColor)
                }
            }
        }
        .padding()
    }
}

// MARK: - Side Menu Navigation Links
extension CategoryView {
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
struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryView()
    }
}
