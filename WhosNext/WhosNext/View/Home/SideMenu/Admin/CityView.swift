//
//  CityView.swift
//  WhosNext
//
//  Created by differenz240 on 17/11/22.
//

import SwiftUI
import AVKit

struct CityView: View {
    @StateObject private var sidebarVM: SidebarViewModel = SidebarViewModel()
    @StateObject private var cityVM: CityViewModel = CityViewModel()
    
    var body: some View {
        ZStack {
            self.sideMenuNavigationLink()
            
            VStack {
                self.searchTextfield
                self.cityList
            }
            .onAppear {
                self.cityVM.getCities()
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: HStack {
                Button {
                    self.cityVM.openSideMenu()
                } label: {
                    Image(IdentifiableKeys.ImageName.kMenuBar)
                }
                
                Text(IdentifiableKeys.NavigationbarTitles.kCity)
                    .font(.custom(Constant.FontStyle.Heavy.rawValue, size: Constant.FontSize._28FontSize))
            })
            .navigationBarColor(backgroundColor: UIColor(named: "uniColor"))
            .alert(isPresented: self.$cityVM.showAlert) {
                if self.cityVM.alertType == .validation {
                    return Alert(title: Text(""), message: Text(self.cityVM.alertMsg))
                } else if self.cityVM.alertType == .deleteConfirmation {
                    return Alert(
                        title: Text(""), message: Text(self.cityVM.alertMsg),
                        primaryButton: .default(Text("No"), action: {}),
                        secondaryButton: .destructive(Text("Yes"), action: {
                            self.cityVM.deleteCityApi()
                        })
                    )
                } else {
                    return Alert(title: Text(""))
                }
            }
            
            if self.cityVM.isSideBarOpened {
                SideMenuView(sidebarVM: self.sidebarVM, isSidebarVisible: self.$cityVM.isSideBarOpened)
                    .environment(\.moveToOtherView, self.sidebarVM.moveToView)
            }
        }
        .hideNavigationBar(isSideBarMenuOpen: self.cityVM.isSideBarOpened)
    }
}

// MARK: - UI Helpers
extension CityView {
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
                    
                    TextField("Search city here", text: self.$cityVM.searchedCity)
                    
                    if let cityArr = self.cityVM.cityModel?.data.filter({ $0.city.hasPrefix(self.cityVM.searchedCity) || self.cityVM.searchedCity == "" }) {
                        if self.cityVM.searchedCity.count > 0 && cityArr.count == 0  && self.cityVM.searchedCity.trimWhiteSpace != "" {
                            Button(action: {
                                self.cityVM.addCityApi()
                            }, label: { Text("Add").foregroundColor(Color.myDarkCustomColor) })
                        }
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

    /// `city` list
    private var cityList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading) {
                if let cityArr = self.cityVM.cityModel?.data.filter({ $0.city.hasPrefix(self.cityVM.searchedCity) || self.cityVM.searchedCity == "" }) {
                    ForEach(cityArr, id: \.self) { city in
                        HStack(alignment: .center) {
                            if self.cityVM.selectedCity?.cityID == city.cityID && self.cityVM.cityOperation == .edit {
                                TextField("Update the city here", text: self.$cityVM.city)
                                    .lineLimit(3)
                                    .padding(.vertical, 8.0)
                                    .textFieldStyle(.roundedBorder)
                            } else {
                                Text(city.city)
                                    .lineLimit(3)
                            }

                            Spacer()

                            HStack(spacing: 16.0) {
                                Button(action: {
                                    if self.cityVM.selectedCity?.cityID == city.cityID {
                                        self.cityVM.btnEditClicked(city: city, operation: .clear)
                                    } else {
                                        self.cityVM.btnEditClicked(city: city, operation: .edit)
                                    }
                                }, label: {
                                    Image(systemName: self.cityVM.selectedCity?.cityID == city.cityID && self.cityVM.cityOperation == .edit ? "xmark.circle" : "square.and.pencil")
                                })
                                .tint(.blue)

                                if self.cityVM.selectedCity?.cityID == city.cityID && self.cityVM.cityOperation == .edit {
                                    Button(action: {
                                        self.cityVM.updateCityApi()
                                    }, label: {
                                        Image(systemName: "checkmark")
                                    })
                                    .tint(.blue)
                                } else {
                                    Button(action: {
                                        self.cityVM.openDeleteCityConfirmation(city: city)
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
        }
        .padding()
    }
}

// MARK: - Side Menu Navigation Links
extension CityView {
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
struct CityView_Previews: PreviewProvider {
    static var previews: some View {
        CityView()
    }
}
