//
//  GroupVideosView.swift
//  WhosNext
//
//  Created by differenz240 on 04/01/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct GroupVideosView: View {
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @StateObject private var shareToVM: ShareToViewModel = ShareToViewModel()

    @State private var text: String?
    @State private var placeholderText: String = "Write Caption"
    @State private var currentTab: Int = 0
    @State private var tagSheetOpen = false
    @State private var isTagPeople = false
    @State private var isShowPeopleList = false
    @State private var rawValue: String = ""
    @State private var addedTagArray : [String] = []
    @State private var listValues : [String] = []
    @State private var selectedUsers = [AllUserListData]()
    @State private var tagCount: Int = 1
    @State private var searchText: String = ""
    @State private var isSearchBarVisible = false
    @State private var maxPeoples: Int = 4
    @FocusState private var focusState: Bool
    
    var isVideo: Bool? = false
    var postImage: UIImage? = nil
    var videoUrl: URL? = nil
    var postDetailsModel: PostDetailModel?

    var body: some View {
        ZStack {
            Group {
                NavigationLink(destination: SelectGroupVideoPeopleView(shareToVM: self.shareToVM, selectedUsers: self.$selectedUsers, text: self.$text, maximumPeople: self.$maxPeoples), isActive: self.$shareToVM.moveToSelectPeople, label: {})
            }

            VStack {
                if self.postDetailsModel != nil {
                    CustomTabBarView(currentTab: self.$currentTab, tabBarOptions: ["FOLLOWERS", "MESSAGE"])
                }

                TabView(selection: self.$currentTab) {
                    self.followersView().tag(0)

                    if self.postDetailsModel != nil {
                        self.MessageView().tag(1)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
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
            .onAppear {
                self.shareToVM.getAllUserList { _ in }
                self.shareToVM.image = self.postImage
                self.shareToVM.videoUrl = self.videoUrl
                self.shareToVM.postType = self.postDetailsModel?.data?.postType ?? 0
                
                self.focusState = true
                
                if self.postDetailsModel != nil {
                    self.text = self.postDetailsModel?.data?.postCaption
                    
                    if let taggedPeople = self.postDetailsModel?.data?.taggedSelectedPeopleArr {
                        for taggedPerson in taggedPeople {
                            self.selectedUsers.append(taggedPerson)
                            self.addedTagArray.append(taggedPerson.username ?? "")
                        }
                        
                        self.isTagPeople = true
                    }
                }
            }
            .onDisappear {
                self.focusState = false

                self.shareToVM.isUploading = false
                self.shareToVM.progress = 0.0
            }
            .sheet(isPresented: self.$tagSheetOpen) {
                self.tagPeopleView()
            }
            .confirmationDialog("", isPresented: self.$shareToVM.showPicker, actions: {
                if self.shareToVM.pickerType == .none {
                    Button(action: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                            self.shareToVM.pickerType = .image
                            self.shareToVM.showPicker = true
                        })
                    }, label: { Text("Image") })
                    
                    Button(action: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                            self.shareToVM.pickerType = .video
                            self.shareToVM.showPicker = true
                        })
                    }, label: { Text("Video") })
                } else if self.shareToVM.pickerType == .image {
                    Button(action: {
                        self.shareToVM.shouldPresentImagePicker = true
                        self.shareToVM.isPresentCamera = true
                    }, label: { Text("Take From Camera") })
                    
                    Button(action: {
                        self.shareToVM.shouldPresentImagePicker = true
                        self.shareToVM.isPresentCamera = false
                    }, label: { Text("Select From Library") })
                } else if self.shareToVM.pickerType == .video {
                    Button(action: {
                        self.shareToVM.isShowVideos = true
                        self.shareToVM.shouldPresentImagePicker = true
                        self.shareToVM.isPresentCamera = true
                    }, label: { Text("Capture Video") })
                    
                    Button(action: {
                        self.shareToVM.shouldPresentImagePicker = true
                        self.shareToVM.isPresentCamera = false
                        self.shareToVM.isShowVideos = true
                    }, label: { Text("Pick Video From Gallery") })
                }
            }, message: { Text("Perform some action") })
            .fullScreenCover(isPresented: self.$shareToVM.shouldPresentImagePicker) {
                CustomImagePickerView(sourceType: self.shareToVM.isPresentCamera ? (UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary) : .photoLibrary, isVideoAllow: self.shareToVM.isShowVideos, arrImage: self.$shareToVM.arrImage, image: self.$shareToVM.image, isPresented: self.$shareToVM.shouldPresentImagePicker, videoURL: self.$shareToVM.videoURL)
            }
            .onChange(of: self.shareToVM.image) { newValue in
                self.shareToVM.postType = 1
                self.shareToVM.mediaSelected = true
                
                self.shareToVM.pickerType = .none
            }
            .onChange(of: self.shareToVM.videoURL) { newValue in
                self.shareToVM.postType = 2
                self.shareToVM.mediaSelected = true
                
                self.shareToVM.pickerType = .none
            }
        }
    }
}

// MARK: - Helper Methods
extension GroupVideosView {
    /// `follower` view
    func followersView() -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                VStack {
                    if self.postDetailsModel != nil {
                        if self.shareToVM.mediaSelected {
                            if self.shareToVM.postType == 1 {
                                Image(uiImage: self.shareToVM.image ?? UIImage())
                                    .resizable()
                                    .frame(height: 300)
                            } else if self.shareToVM.postType == 2 {
                                if let url = self.shareToVM.videoURL {
                                    if let image = Utilities.getThumbnailImage(forUrl: url) {
                                        Image(uiImage: image)
                                            .resizable()
                                    }
                                }
                            }
                        } else {
                            if let url = URL(string: self.postDetailsModel?.data?.postThumbnail ?? "") {
                                WebImage(url: url)
                                    .resizable()
                                    .indicator(.activity)
                                    .frame(width: ScreenSize.SCREEN_WIDTH, height: 250)
                            }
                        }
                    } else {
                        if self.isVideo == true {
                            if let url = self.shareToVM.videoUrl {
                                if let image = Utilities.getThumbnailImage(forUrl: url) {
                                    Image(uiImage: image)
                                        .resizable()
                                }
                            }
                        } else {
                            Image(uiImage: self.postImage ?? UIImage())
                                .resizable()
                                .frame(height: 300)
                        }
                    }
                }
                .onTapGesture {
                    if self.postDetailsModel != nil {
                        self.shareToVM.showPicker.toggle()
                    }
                }
                
                Text("Write Caption")
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._18FontSize))
                    .padding(.leading,10)
                
                ZStack(alignment: .topLeading) {
                    TextEditor(text: Binding(self.$text, replacingNilWith: ""))
                        .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
                        .colorMultiply(Color.CustomColor.AppSnippetsColor)
                        .frame(alignment: .leading)
                        .focused(self.$focusState)
                    
                    Text(self.text ?? self.placeholderText)
                        .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
                        .foregroundColor(Color.secondary.opacity(0.5))
                        .opacity(text  == nil ? 1 : 0)
                        .padding([.horizontal], 4)
                        .padding(.vertical, 10)
                }
                .background(Color.CustomColor.AppSnippetsColor)
                .frame(height: 100)
                
                Text("Tag People")
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._18FontSize))
                    .padding(.leading, 10)
                
                let selctUser = self.selectedUsers.map({ $0.username ?? ""}).joined(separator: ",")
                
                Text(self.selectedUsers.count == 0 ? "Tap To Select People" : selctUser)
                    .padding(.leading, 5)
                    .frame(width: ScreenSize.SCREEN_WIDTH, height: 40, alignment: .leading)
                    .background(Color.appSnippetsColor)
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
                    .onTapGesture {
                        self.tagSheetOpen = true
                        self.isShowPeopleList = false
                    }
                
                CommonButton(title: IdentifiableKeys.Buttons.kSubmit, cornerradius: 0) {
                    var postId = ""
                    let tagPeople = self.selectedUsers.map({ "\($0.userID ?? 0)" }).joined(separator: ",")
                    
                    if self.postDetailsModel != nil {
                        postId = "\(self.postDetailsModel?.data?.postID ?? 0)"
                    } else {
                        postId = ""
                    }

                    if self.postDetailsModel != nil {
                        guard let post = self.postDetailsModel?.data, let deleteFileName = post.postURL?.split(separator: "?").first?.split(separator: "/").last,
                              let deleteFileThumbName = post.postThumbnail?.split(separator: "?").first?.split(separator: "/").last else { return }
                        
                        self.shareToVM.postHeight = post.postHeight ?? 0.0
                        self.shareToVM.postWidth = post.postWidth ?? 0.0
                        
                        self.shareToVM.updatePostWithVideo(postID: postId, postType: 2, postSubType: 3, postCaption: self.text ?? "", taggedSelectedPeople: tagPeople, deleteVideoName: String(deleteFileName), deleteVideoThumbName: String(deleteFileThumbName)) {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    } else {
                        self.shareToVM.moveToSelectPeople.toggle()
                    }
                }
                .padding(.top, 30)
                
                Spacer()
            }
        }
    }
    
    /// `message` view
    func MessageView() -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                VStack {
                    if self.postDetailsModel != nil {
                        if self.shareToVM.mediaSelected {
                            if self.shareToVM.postType == 1 {
                                Image(uiImage: self.shareToVM.image ?? UIImage())
                                    .resizable()
                                    .frame(height: 300)
                            } else if self.shareToVM.postType == 2 {
                                if let url = self.shareToVM.videoURL {
                                    if let image = Utilities.getThumbnailImage(forUrl: url) {
                                        Image(uiImage: image)
                                            .resizable()
                                    }
                                }
                            }
                        } else {
                            if let url = URL(string: self.postDetailsModel?.data?.postThumbnail ?? "") {
                                WebImage(url: url)
                                    .resizable()
                                    .indicator(.activity)
                                    .frame(width: ScreenSize.SCREEN_WIDTH, height: 250)
                            }
                        }
                    } else {
                        if self.isVideo == true {
                            if let url = self.shareToVM.videoUrl {
                                if let image = Utilities.getThumbnailImage(forUrl: url) {
                                    Image(uiImage: image)
                                        .resizable()
                                }
                            }
                        } else {
                            Image(uiImage: self.postImage ?? UIImage())
                                .resizable()
                                .frame(height: 300)
                        }
                    }
                }
                .onTapGesture {
                    if self.postDetailsModel != nil {
                        self.shareToVM.showPicker.toggle()
                    }
                }
                
                Text("Write Caption")
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._18FontSize))
                    .padding(.leading,10)
                
                ZStack(alignment: .topLeading) {
                    TextEditor(text: Binding(self.$text, replacingNilWith: ""))
                        .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
                        .colorMultiply(Color.CustomColor.AppSnippetsColor)
                        .frame(alignment: .leading)
                    
                    Text(self.text ?? self.placeholderText)
                        .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
                        .foregroundColor(Color.secondary.opacity(0.5))
                        .opacity(text  == nil ? 1 : 0)
                        .padding([.horizontal], 4)
                        .padding(.vertical, 10)
                }
                .background(Color.CustomColor.AppSnippetsColor)
                .frame(height: 100)
                
                Text("Tag People")
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._18FontSize))
                    .padding(.leading, 10)
                
                let selctUser = self.selectedUsers.map({ $0.username ?? ""}).joined(separator: ",")
                
                Text(self.selectedUsers.count == 0 ? "Tap To Select People" : selctUser)
                    .padding(.leading, 5)
                    .frame(width: ScreenSize.SCREEN_WIDTH, height: 40, alignment: .leading)
                    .background(Color.appSnippetsColor)
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
                    .onTapGesture {
                        self.tagSheetOpen = true
                    }
                
                CommonButton(title: IdentifiableKeys.Buttons.kSend, cornerradius: 0) {
                    Alert.show(message: "coming soon!")
                    //                    self.presentationMode.wrappedValue.dismiss()
                }
                .padding(.top, 30)
                
                Spacer()
            }
        }
    }

    /// `tag people` view
    func tagPeopleView() -> some View {
        VStack {
            HStack {
                Button(action: {
                    self.tagSheetOpen = false
                }, label: {
                    Text("Cancel")
                        .foregroundColor(Color.black)
                        .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._20FontSize ))
                        .padding(.leading, 5)
                })
                
                Spacer()
                
                Text("Tag People")
                    .font(.custom(Constant.FontStyle.Heavy.rawValue, size: Constant.FontSize._22FontSize))
                
                Spacer()
                
                Button(action: {
                    self.tagSheetOpen = false
                }, label: {
                    Text("Done")
                        .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._20FontSize))
                        .foregroundColor(Color.black)
                        .padding(.trailing, 5)
                })
            }
            .frame(height: 45)
            .background(Color.white)
            
            if self.isSearchBarVisible == true {
                SearchBar(searchText: self.$searchText)
                    .padding(.top, -8)
                    .onTapGesture {
                        self.isShowPeopleList = true
                    }
                    .onChange(of: self.searchText, perform: { searchText in
                        if self.searchText.trimWhiteSpace == "" {
                            if self.searchText.last == " " {
                                self.searchText.removeLast()
                            }
                        }
                    })
            }
            
            ScrollView(showsIndicators: false) {
                VStack {
                    ZStack {
                        VStack {
                            if self.postDetailsModel != nil {
                                if self.shareToVM.mediaSelected {
                                    if self.shareToVM.postType == 1 {
                                        Image(uiImage: self.shareToVM.image ?? UIImage())
                                            .resizable()
                                            .frame(height: 350)
                                    } else if self.shareToVM.postType == 2 {
                                        if let url = self.shareToVM.videoURL {
                                            if let image = Utilities.getThumbnailImage(forUrl: url) {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .frame(height: 350)
                                            }
                                        }
                                    }
                                } else {
                                    if let url = URL(string: self.postDetailsModel?.data?.postThumbnail ?? "") {
                                        WebImage(url: url)
                                            .resizable()
                                            .indicator(.activity)
                                            .frame(width: ScreenSize.SCREEN_WIDTH, height: 350)
                                        
                                    }
                                }
                            } else {
                                if self.isVideo == true {
                                    if let url = self.shareToVM.videoUrl {
                                        if let image = Utilities.getThumbnailImage(forUrl: url) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .frame(height: 350)
                                        }
                                    }
                                } else {
                                    Image(uiImage: self.postImage ?? UIImage())
                                        .resizable()
                                        .frame(height: 350)
                                }
                            }
                        }
                        .onTapGesture {
                            self.tagCount += 1
                            self.isTagPeople = true
                            self.isSearchBarVisible = true
                            
                            let model = AllUserListData(firstName: "", lastName: "", username: "Whos's this?", fullName: "", userID: -1)
                            self.addedTagArray.append(model.username ?? "")
                        }
                        
                        if self.isTagPeople == true {
                            ZStack {
                                ForEach(self.addedTagArray, id: \.self) { raw in
                                    VStack(spacing: 0) {
                                        Image(IdentifiableKeys.ImageName.kTriagleupArrowtag)
                                            .resizable()
                                            .frame(width: 20, height: 10)
                                            .padding(.bottom, -1)
                                            .padding(.leading, -30)
                                        
                                        HStack {
                                            Text(raw == "" ? "Whos's this?": raw)
                                                .font(.system(size: 15))
                                                .foregroundColor(.white)
                                            
                                            Button {
                                                self.selectedUsers.removeAll(where: { $0.username == raw })
                                                self.addedTagArray.removeAll(where: { $0 == raw })
                                                
                                                self.tagCount -= 1
                                                self.isSearchBarVisible = false
                                            } label: {
                                                Image(systemName: "xmark.circle")
                                            }
                                        }
                                        .padding(.all, 7)
                                        .foregroundColor(.white)
                                        .background(Color.black.opacity(0.8))
                                        .lineLimit(1)
                                        
                                    }
                                    .draggable()
                                }
                            }
                        }
                        
                        if self.isShowPeopleList == true {
                            ScrollView {
                                VStack(alignment: .leading) {
                                    if let userdata = self.shareToVM.allUserListModel?.data.filter({$0.fullName!.hasPrefix(self.searchText) || self.searchText == ""}) {
                                        ForEach(userdata  , id: \.self) { val in
                                            TagPeopleCell(index: val.userID ?? 0, fullName: val.fullName ?? "", name: val.username ?? "") { isSelected, fullName, name in
                                                self.isShowPeopleList = false
                                                
                                                if isSelected {
                                                    if self.selectedUsers.contains(where: { $0 == val}) == false {
                                                        self.selectedUsers.append(val)
                                                        
                                                        if self.addedTagArray.last == "Whos's this?" {
                                                            let index = self.addedTagArray.firstIndex(of: "Whos's this?") ?? 0
                                                            self.addedTagArray[index] = val.username ?? ""
                                                            
                                                            self.isSearchBarVisible = false
                                                        }
                                                    }
                                                } else {
                                                    self.selectedUsers.removeAll(where: { $0 == val})
                                                    self.addedTagArray.removeAll(where: { $0 == val.username ?? ""})
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .background(Color.black.opacity(0.4))
                            .frame(height: 350)
                        }
                    }
                    
                    Text("Tap photo to tag people")
                        .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._18FontSize))
                        .foregroundColor(.white)
                        .padding(.top, 30)
                }
            }
            
            Spacer()
        }
        .background(Color.black)
    }
}

// MARK: - Preview
struct GroupVideosView_Previews: PreviewProvider {
    static var previews: some View {
        GroupVideosView()
    }
}
