//
//  AddNewSnippetView.swift
//  WhosNext
//
//  Created by differenz195 on 11/10/22.
//
import SwiftUI
import AVKit

struct AddNewSnippetView: View {
    // MARK: - Variables
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    @StateObject var sidebarVM: SidebarViewModel = SidebarViewModel()
    @StateObject private var snippetVM: SnippetViewModel = SnippetViewModel()
    
    @State var selection: Int? = nil
    @State var isSideBarOpened = false
    @State var navigate: Bool = false
    @State var isShowActionSheet: Bool = false
    @State var isPresentCamera = false
    @State var isShowVideos: Bool = false
    @State var shouldPresentImage: URL?
    @State var arrImage: [UIImage] = []
    
    var body: some View {
        ZStack {
            self.sideMenuNavigationLink()
            NavigationLink("", isActive: $navigate) {
                RecordAudioView()
            }
            ScrollView(showsIndicators: false) {
                VStack {
                    VStack {
                        if self.snippetVM.image == nil && self.snippetVM.videoURL == nil {
                            Image(IdentifiableKeys.ImageName.kAppTitleText)
                                .frame(width: UIScreen.main.bounds.width - 10,height: 300, alignment: .center)
                                .padding(.top, 30)
                                .background(Color.myCustomColor)
                        } else if self.snippetVM.image != nil {
                            if let image = self.snippetVM.image {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: UIScreen.main.bounds.width - 10,height: 300, alignment: .center)
                                    .padding(.top, 30)
                            }
                        } else if self.snippetVM.videoURL != nil {
                            if let url = self.snippetVM.videoURL {
                                if let image = self.snippetVM.getThumbnailImage(forUrl: url) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: UIScreen.main.bounds.width - 10,height: 300, alignment: .center)
                                        .padding(.top, 30)
                                }
                            }
                        } else if self.snippetVM.mediaPickerType == .audio {
                            Image(IdentifiableKeys.ImageName.kAppTitleText)
                                .frame(width: UIScreen.main.bounds.width - 10,height: 300, alignment: .center)
                                .padding(.top, 30)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.myCustomColor)
                    .onTapGesture {
                        self.isShowActionSheet = true
                        self.snippetVM.mediaPickerType = .main
                        self.snippetVM.snippetMediaType = -1
                    }
                    
                    Text(IdentifiableKeys.Labels.kPleaseTapIconToSelect)
                        .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
                    
                    self.bottomView()
                    
                    CommonButton(title: IdentifiableKeys.Buttons.kSave, cornerradius: 0) {
                        if self.snippetVM.snippetMediaType == 1 {
                            self.snippetVM.createSnippetWithImage {
                                print("=================================== Done ===================================")
                                self.dismiss()
                            }
                            
                        } else if self.snippetVM.snippetMediaType == 2 {
                            self.snippetVM.createSnippetWithVideo {
                                print("=================================== Done ===================================")
                                self.dismiss()
                            }
                        } else if self.snippetVM.snippetMediaType == 3 {
                            print("AudioSelected")
                        }
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                }
                .background(Color.myCustomColor)
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: HStack {
                    Button {
                        self.isSideBarOpened.toggle()
                    } label: {
                        Image(IdentifiableKeys.ImageName.kMenuBar)
                    }
                    
                    Text(IdentifiableKeys.NavigationbarTitles.kAddNewSnippets)
                        .font(.custom(Constant.FontStyle.Heavy.rawValue, size: Constant.FontSize._28FontSize))
                    
                })
                .alert( Text(""), isPresented: self.$snippetVM.showValidationAlert, actions: {}, message: {
                    Text(self.snippetVM.validationMsg)
                })
                
                
                .sheet(isPresented: self.$snippetVM.shouldOpenMediaPicker,
                       onDismiss: {
                            self.snippetVM.resetMediaPickerType()
                        },
                       content: {
                            if self.snippetVM.mediaPickerType == .image || self.snippetVM.mediaPickerType == .video {
                                CustomImagePickerView(sourceType: self.isPresentCamera ? (UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary) : .photoLibrary, isVideoAllow: isShowVideos, arrImage: self.$arrImage, image: self.$snippetVM.image, isPresented: self.$snippetVM.shouldOpenMediaPicker, videoURL: self.$snippetVM.videoURL)
                    } else {
                        CustomAudioPickerView(isPresented: self.$snippetVM.shouldOpenMediaPicker, audioURL: self.$snippetVM.audioURL)
                    }
                })
                .actionSheet(isPresented: self.$isShowActionSheet) {
                    if self.snippetVM.mediaPickerType == .main {
                        return ActionSheet(title: Text(""), message: Text("Browse Your Image , Videos and Audio"),
                                           buttons: [
                                            .default(Text("Image"), action: {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                                                    self.snippetVM.mediaPickerType = .image
                                                    self.snippetVM.snippetMediaType = 1
                                                    self.isShowActionSheet = true
                                                })
                                            }),
                                            .default(Text("Video"), action: {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                                                    self.snippetVM.mediaPickerType = .video
                                                    self.snippetVM.snippetMediaType = 2
                                                    self.isShowActionSheet = true
                                                })
                                            }),
                                            .default(Text("Audio"), action: {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                                                    self.snippetVM.mediaPickerType = .audio
                                                    self.snippetVM.snippetMediaType = 3
                                                    self.isShowActionSheet = true
                                                })
                                            }),
                                            .cancel()
                                           ])
                    } else if self.snippetVM.mediaPickerType == .image {
                        return  ActionSheet(title: Text(""), message: Text("Browse Your Image"),
                                            buttons: [
                                                .default(Text("Camera"), action: {
                                                    self.isPresentCamera = true
                                                    self.snippetVM.shouldOpenMediaPicker = true
                                                }),
                                                .default(Text("Gallery"), action: {
                                                    self.snippetVM.shouldOpenMediaPicker = true
                                                    self.isPresentCamera = false
                                                    self.isShowVideos = false
                                                }),
                                                .cancel()
                                            ])
                    } else if self.snippetVM.mediaPickerType == .video {
                        return  ActionSheet(title: Text(""), message: Text("Browse Your Video"), buttons: [
                            .default(Text("Camera"), action: {
                                self.isPresentCamera = true
                                self.isShowVideos = true
                                self.snippetVM.shouldOpenMediaPicker = true
                            }),
                            .default(Text("Gallery"), action: {
                                self.isPresentCamera = false
                                self.snippetVM.shouldOpenMediaPicker = true
                                self.isShowVideos = true
                            }),
                            .cancel()
                        ])
                    } else {
                        return  ActionSheet(title: Text(""), message: Text("Browse Your Audio"), buttons: [
                            .default(Text("Record"), action: {
                                self.navigate = true
                                // self.isShowActionSheet = false
                            }),
                            .default(Text("Pick From Library"), action: {
                                self.snippetVM.shouldOpenMediaPicker = true
                            }),
                            .cancel()
                        ])
                    }
                }
                .gesture(DragGesture(minimumDistance: 10, coordinateSpace: .global)
                    .onEnded({ value in
                        withAnimation {
                            if value.translation.width > 0 {
                                self.isSideBarOpened.toggle()
                            }
                        }
                    }))
                .navigationBarColor(backgroundColor: UIColor(named: "uniColor"))
            }
            if isSideBarOpened {
                SideMenuView(sidebarVM: self.sidebarVM, isSidebarVisible: self.$isSideBarOpened)
                    .environment(\.moveToOtherView, self.sidebarVM.moveToView)
            }
        }
        .hideNavigationBar(isSideBarMenuOpen: self.isSideBarOpened)
    }
}

// MARK: - Helper Methods
extension AddNewSnippetView {
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
                
                if self.sidebarVM.navigationLink == menuItemName.kVideos {
                    /// `move to videos screen`
                    NavigationLink("", destination: VideosView(), tag: menuItemName.kVideos, selection: self.$sidebarVM.navigationLink)
                }
                
                if self.sidebarVM.navigationLink == menuItemName.kPictures {
                    /// `move to pictures screen`
                    NavigationLink("", destination: PicturesView(), tag: menuItemName.kPictures, selection: self.$sidebarVM.navigationLink)
                }
            }
            
            VStack {
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
    
    /// `bottom` view
    func bottomView() -> some View {
        VStack(alignment: .leading) {
            Text(IdentifiableKeys.Labels.kWriteSnippetDetails)
                .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: self.$snippetVM.snippetDetails)
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
//                    .foregroundColor(Color.myDarkCustomColor)
                    .foregroundColor(Color.myDarkCustomColor)
                    .background(Color.appSnippetsColor)
                    .frame(alignment: .leading)
                Text("Please enter snippet details")
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
                    .foregroundColor(Color.myDarkCustomColor.opacity(0.7))
                    .opacity(self.snippetVM.snippetDetails == "" ? 1.0 : 0.0)
                    .padding([.horizontal], 2)
                    .padding(.vertical, 10)
            }
            .frame(height: 100)
        }
        .padding(.all, 10)
    }
}

// MARK: - Previews
struct AddNewSnippetView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewSnippetView()
    }
}
