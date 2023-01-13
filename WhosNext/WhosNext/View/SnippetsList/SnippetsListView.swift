//
//  SnippetsListView.swift
//  WhosNext
//
//  Created by differenz195 on 08/11/22.
//

import SwiftUI
import AVKit
import SDWebImageSwiftUI

struct SnippetsListView: View {
    @StateObject private var sidebarVM: SidebarViewModel = SidebarViewModel()
    @StateObject private var snippetVM: SnippetViewModel = SnippetViewModel()
    
    @State private var showingAlert: Bool = false
    @State var isSideBarOpened: Bool = false
    @State private var selectedSnippet: Int = 0

    var body: some View {
        ZStack {
            self.sideMenuNavigationLink()
            ScrollView{
                
                LazyVStack(spacing: 0) {
                    
                    if let snippetArr = snippetVM.getSnippetListModel?.data {
                        ForEach(snippetArr, id: \.self) { snippet in
                            self.snippetCell(snippetArr: snippetArr, snippet: snippet)
                                .onAppear{
                                    self.snippetVM.loadMoreSnippetListData(currentSnippet: snippet)
                                }
                        }
                    }
                }
            }
            
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: HStack {
                Button {
                    self.isSideBarOpened.toggle()
                } label: {
                    Image(IdentifiableKeys.ImageName.kMenuBar)
                }
                
                Text(IdentifiableKeys.NavigationbarTitles.kSnippets)
                    .font(.custom(Constant.FontStyle.Heavy.rawValue, size: Constant.FontSize._28FontSize))
            })
            if self.isSideBarOpened {
                SideMenuView(sidebarVM: self.sidebarVM, isSidebarVisible: self.$isSideBarOpened)
                    .environment(\.moveToOtherView, self.sidebarVM.moveToView)
            }
        }
        .hideNavigationBar(isSideBarMenuOpen: self.isSideBarOpened)
        .onAppear {
            if self.snippetVM.getSnippetListModel == nil {
                self.snippetVM.currentpage = 1
                self.snippetVM.getSnippetListData()
            }
        }
    }
}

struct SnippetsListView_Previews: PreviewProvider {
    static var previews: some View {
        SnippetsListView()
    }
}
//MARK: - Helper Methods
extension SnippetsListView {
    
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
                        
                        if self.sidebarVM.navigationLink == menuItemName.kCity {
                            /// `move to city screen`
                            NavigationLink("", destination: CityView(), tag: menuItemName.kCity, selection: self.$sidebarVM.navigationLink)
                        }
                    }
                }
            }
        }
    }
    
    //Snippet Cell
    func snippetCell(snippetArr: [HomeSinppetData], snippet: HomeSinppetData) -> some View {
        ZStack(alignment: .topLeading) {
            VStack {
                WebImage(url: URL(string: snippet.snippetThumb ?? ""))
                    .resizable()
                    .clipped()
                    .innerShadow(color: .white, radius: 0.9)
                    .frame(height: 150)
                
                    .overlay(
                        
                        Button(action: {
                            self.showingAlert = true
                            deleteButtonTag(buttonTag: snippet.snippetID ?? 0)
                            print("Delete btn tap")
                            print("Delete Button Tag: \(snippet.snippetID ?? 0)")
                            print("selectedSnippetID: \(selectedSnippet)")
                            
                        } , label: {
                            Image(IdentifiableKeys.ImageName.kTrashblack)
                                .resizable()
                                .clipped()
                                .frame(width: 30, height: 30)
                                .padding(12)
                        })
                        ,alignment: .bottomTrailing
                        
                    )
            }
            .alert(isPresented: self.$showingAlert) { () -> Alert in
                Alert(title: Text("Are you sure?"), message: Text("You want to delete snippet permanently."), primaryButton: .default(Text("Yes"), action: {
                    self.snippetVM.deleteSnippet(selectedSnippetID: self.selectedSnippet)
                    print("Yes Button Clicked")
                }), secondaryButton: .default(Text("No"), action: {
                    print("No Button Clicked")
                }))
            }
            
            Text(snippet.username ?? "")
                .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
                .padding(.leading, 8)
            
        }
        
    }
    // Selected Delete Button Tag
    func deleteButtonTag(buttonTag: Int){
        self.selectedSnippet = buttonTag
    }

}

