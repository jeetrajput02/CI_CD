//
//  UpdateGroupVideoView.swift
//  WhosNext
//
//  Created by differenz08 on 09/01/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct UpdateGroupVideoView: View {
    @Environment(\.presentationMode) var presentation: Binding<PresentationMode>
    @StateObject var notificatiionVM: NotificationViewModel = NotificationViewModel()

    @State var image: UIImage?  = nil
    @State var snippetDetails: String  = ""
    @State var isShowActionSheet: Bool = false
    @State var isPresentCamera = false
    @State var arrImage: [UIImage] = []
    @State var mediaPickerType: SnippetMediaPickerType = .main
    @State var shouldOpenMediaPicker: Bool = false
    @State var videoURL: URL? = nil
    @State var isShowVideos: Bool = false
    @Binding var groupData: NotificationData
    @State var groupVideoThumbnails: [String] = []
    @State var groupVideoUserNames: [String] = []
    @State var defaultThumbnail: String = "https://d234fq55kjo26g.cloudfront.net/post_video/thumb/"
    @State private var maxPeoples: Int = 4
    
    var body: some View {
        VStack {
            if self.notificatiionVM.isUploading {
                LinearProgressBar(title: "Loading...", progress: self.$notificatiionVM.progress)
                    .onChange(of: self.notificatiionVM.progress, perform: { progress in
                        if progress == 100.0 {
                            self.self.notificatiionVM.isUploading = false
                            self.notificatiionVM.progress = 0.0
                        }
                    })
            }

            ScrollView {
                VStack(alignment: .leading) {
                    if self.image != nil {
                        if let image = self.image {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: UIScreen.main.bounds.width - 10,height: 200, alignment: .center)
                                .padding(.horizontal,5)
                                .onTapGesture {
                                    if self.notificatiionVM.isUploading == false {
                                        self.isShowActionSheet = true
                                        self.mediaPickerType = .main
                                    }
                                }
                        }
                    } else {
                        Image(IdentifiableKeys.ImageName.kGroupVideoBanner)
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width - 10,height: 200, alignment: .center)
                            .padding(.leading,5)
                            .padding(.trailing,4)
                            .onTapGesture {
                                self.isShowActionSheet = true
                                self.mediaPickerType = .main
                            }
                    }
                    
                    Text("WRITE VIDEO DETAILS")
                        .padding(.all , 10)
                        .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
                    
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: self.$snippetDetails)
                            .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
                            .foregroundColor(Color.myDarkCustomColor)
                            .background(Color.appSnippetsColor)
                            .frame(alignment: .leading)
                        
                        Text("Please enter video details")
                            .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
                            .foregroundColor(Color.myDarkCustomColor.opacity(0.7))
                            .opacity(self.snippetDetails == "" ? 1.0 : 0.0)
                            .padding([.horizontal], 2)
                            .padding(.vertical, 10)
                    }
                    .frame(height: 100)
                    .padding(.all,10)
                    
                    Text("VIDEO PREVIEW")
                        .padding(.all , 10)
                        .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))

                    VStack {
                        LazyHStack(alignment: .top, spacing: 10.0) {
                            ForEach(0 ..< self.groupVideoThumbnails.count ,  id: \.self) { i in
                                VStack {
                                    WebImage(url: URL(string: self.groupVideoThumbnails[i]))
                                        .placeholder(Image(IdentifiableKeys.ImageName.kAppBanner).resizable())
                                        .resizable()
                                        .indicator(.activity)
                                        .frame(width: 50.0, height: 50.0, alignment: .top)
                                        .border(Color.black)
                                    
                                    Text("\(self.groupVideoUserNames[i])")
                                        .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
                                        .lineLimit(2)
                                }
                                .frame(width: 50.0)
                            }
                        }
                        .frame(alignment: .top)
                        .padding(.horizontal, 10.0)
                    }
                    
                    CommonButton(title: IdentifiableKeys.Buttons.kSubmit, cornerradius: 0) {
                        if self.notificatiionVM.isUploading == false {
                            let validations = self.notificatiionVM.validations(image: self.image, videoURL: self.videoURL, description: self.snippetDetails)
                            
                            if validations == true {
                                self.notificatiionVM.isUploading = true
                                
                                self.notificatiionVM.updateGroupVideoRequestApi(postID: "\(self.groupData.post?.postID ?? 0)", video_url: self.videoURL) {
                                    print("Uploaded")
                                    self.presentation.wrappedValue.dismiss()
                                }
                            }
                        }
                    }
                    .padding(.top, 25)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: HStack {
            Button {
                if self.notificatiionVM.isUploading == false {
                    self.presentation.wrappedValue.dismiss()
                }
            } label: {
                Image(IdentifiableKeys.ImageName.kBackArrowBlack)
            }
            
            Text("Videos")
                .font(.custom(Constant.FontStyle.Heavy.rawValue, size: Constant.FontSize._28FontSize))
        })
        .alert(Text(""), isPresented: self.$notificatiionVM.showValidationAlert, actions: {}, message: {
            Text(self.notificatiionVM.validationMsg)
        })
        .sheet(isPresented: self.$shouldOpenMediaPicker,onDismiss: {
            if self.videoURL != URL(string: self.defaultThumbnail) && self.videoURL != nil {
                self.image = Utilities.getThumbnailImage(forUrl: self.videoURL!)
            }
        }, content: {
            if self.mediaPickerType == .video {
                CustomImagePickerView(sourceType: self.isPresentCamera ? (UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary) : .photoLibrary, isVideoAllow: self.isShowVideos , arrImage: self.$arrImage, image: self.$image, isPresented: self.$shouldOpenMediaPicker, videoURL: self.$videoURL)
            } else {
                // CustomAudioPickerView(isPresented: self.$recordVm.shouldOpenMediaPicker, audioURL: self.$recordVm.audioURL)
            }
        })
        .actionSheet(isPresented: self.$isShowActionSheet) {
            if self.mediaPickerType == .main {
                return ActionSheet(title: Text(""), message: Text("Browse Your Videos"),
                                   buttons: [
                                    .default(Text("Video"), action: {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                                            self.mediaPickerType = .video
                                            self.isShowActionSheet = true
                                        })
                                    }),
                                    .cancel()
                                   ])
            } else if self.mediaPickerType == .video {
                return  ActionSheet(title: Text(""), message: Text("Browse Your Image"),
                                    buttons: [
                                        .default(Text("Camera"), action: {
                                            self.isPresentCamera = true
                                            self.shouldOpenMediaPicker = true
                                            self.isShowVideos = true
                                        }),
                                        .default(Text("Gallery"), action: {
                                            self.shouldOpenMediaPicker = true
                                            self.isPresentCamera = false
                                            self.isShowVideos = true
                                        }),
                                        .cancel()
                                    ])
            }
            
            return ActionSheet(title: Text("Nothing to Show"))
        }
        .onAppear {
            UIScrollView.appearance().bounces = false
            if self.groupData.username != "" && self.groupData.groupVideoThumb != "" {
                self.groupVideoUserNames.append(self.groupData.username ?? "")
                self.groupVideoThumbnails.append(self.groupData.groupVideoThumb ?? "")
            }
            
            for i in 0 ..< (self.groupData.groupVideoUserArr?.count ?? 0) {
                
                if self.groupData.groupVideoUserArr?[i].showField ==  3 {
                    self.groupVideoThumbnails.append(self.groupData.groupVideoUserArr?[i].invitedUserVideoThumbnailURL ?? "" )
                    print(self.groupData.groupVideoUserArr?[i].invitedUserVideoURL ?? "" )
                    self.groupVideoUserNames.append(self.groupData.groupVideoUserArr?[i].username ?? "" )
                }
            }
        }
        .onDisappear {
            self.notificatiionVM.isUploading = false
            self.notificatiionVM.progress = 0.0
        }
    }
}

// MARK: - Previews
struct UpdateGroupVideoView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateGroupVideoView(groupData: .constant(NotificationData()))
    }
}
