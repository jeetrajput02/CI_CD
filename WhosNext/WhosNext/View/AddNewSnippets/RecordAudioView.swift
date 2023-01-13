//
//  RecordAudioView.swift
//  WhosNext
//
//  Created by differenz104 on 28/11/22.
//

import SwiftUI

struct RecordAudioView: View {
    // MARK: - Variables
    @Environment(\.presentationMode) var presentation: Binding<PresentationMode>
    @StateObject private var recordVm: RecordAudioViewModel = RecordAudioViewModel()
    
    @State private var snippetDetails : String = ""
    @State private var showingList = false
    @State private var showingAlert = false
    @State private var effect1 = false
    @State private var effect2 = false
    @State var isShowActionSheet: Bool = false
    @State var isPresentCamera = false
    @State var scale : Double = 1.0
    @State var recordCount: Int = 0
    @State var arrImage: [UIImage] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                 if self.recordVm.image != nil {
                    if let image = self.recordVm.image {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width - 10,height: 200, alignment: .center)
                            .padding(.leading,5)
                            .padding(.trailing,5)
                            .onTapGesture {
                                self.isShowActionSheet = true
                                self.recordVm.mediaPickerType = .main
                                self.recordVm.snippetMediaType = -1
                            }
                    }
                } else {
                    Image(IdentifiableKeys.ImageName.kAudioBanner)
                     .resizable()
                     .frame(width: UIScreen.main.bounds.width - 10,height: 200, alignment: .center)
                     .padding(.leading,5)
                     .padding(.trailing,5)
                     .onTapGesture {
                         self.isShowActionSheet = true
                         self.recordVm.mediaPickerType = .main
                         self.recordVm.snippetMediaType = -1
                     }
                }

                Text(IdentifiableKeys.Labels.kWriteSnippetDetails)
                    .padding(.all , 10)
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
                
                ZStack(alignment: .topLeading) {
                    TextEditor(text: self.$recordVm.snippetDetails)
                        .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
                        .foregroundColor(Color.myDarkCustomColor)
                        .background(Color.appSnippetsColor)
                        .frame(alignment: .leading)
                    Text("Please enter snippet details")
                        .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
                        .foregroundColor(Color.myDarkCustomColor.opacity(0.7))
                        .opacity(self.recordVm.snippetDetails == "" ? 1.0 : 0.0)
                        .padding([.horizontal], 2)
                        .padding(.vertical, 10)
                }
                .frame(height: 100)
                .padding(.all,10)
                
                Text("Welcome back! please tap and hold button and start recording")
                    .multilineTextAlignment(.center)
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._17FontSize))
                    .padding(.all,10)
                
                if recordVm.isRecording {
                    
                    VStack(alignment : .leading , spacing : -5){
                        Text("Recording : \(recordVm.timer)")
                            .font(.custom(Constant.FontStyle.Heavy.rawValue, size: Constant.FontSize._18FontSize))
                            .foregroundColor(.myDarkCustomColor)
                            .animation(.linear(duration: 1.0).repeatForever(autoreverses: true))
                            .scaleEffect(scale)
                            .onAppear {
                                self.scale = self.scale == 1.0 ? 0.75 : 1.0
                            }
                    }
                    .frame(width: UIScreen.main.bounds.width, alignment: .center)
                    
                }
                ZStack(alignment: .center) {
                    Image(systemName: recordVm.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .foregroundColor(.myDarkCustomColor)
                        .font(.system(size: 45))
                        .onTapGesture {
                            if self.recordCount == 0 {
                                if self.recordVm.isRecording == true {
                                    self.recordCount = 1
                                    self.recordVm.stopRecording()
                                    
                                } else {
                                    if(self.recordCount == 0) {
                                        self.recordVm.startRecording()
                                    }
                                }
                            }
                        }
                }
                .frame(width: UIScreen.main.bounds.width, alignment: .bottom)
                
                CommonButton(title: IdentifiableKeys.Buttons.kSave, cornerradius: 0) {
                    self.recordVm.snippetMediaType = 3
                    self.recordVm.createSnippetWithAudio {
                        print("=================================== Done ===================================")
                        self.presentation.wrappedValue.dismiss()
                    }
                }
                .padding(.top, 25)
                
            }
            .navigationBarItems(leading: HStack {
                Button {
                    self.recordVm.fetchAllRecording()
                    if self.recordVm.recordingsList.count > 0 {
                        recordVm.deleteRecording(url:recordVm.recordingsList[0].fileURL)
                    }
                    self.presentation.wrappedValue.dismiss()
                } label: {
                    Image(IdentifiableKeys.ImageName.kBackArrowBlack)
                }
                
                Text(IdentifiableKeys.NavigationbarTitles.kRecordAudio)
                    .font(.custom(Constant.FontStyle.Heavy.rawValue, size: Constant.FontSize._28FontSize))
            })
            .navigationBarBackButtonHidden(true)
            
            .sheet(isPresented: self.$recordVm.shouldOpenMediaPicker, content: {
                if self.recordVm.mediaPickerType == .image {
                    CustomImagePickerView(sourceType: self.isPresentCamera ? (UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary) : .photoLibrary, isVideoAllow: false , arrImage: self.$arrImage, image: self.$recordVm.image, isPresented: self.$recordVm.shouldOpenMediaPicker, videoURL: self.$recordVm.videoURL)
                } else {
                    // CustomAudioPickerView(isPresented: self.$recordVm.shouldOpenMediaPicker, audioURL: self.$recordVm.audioURL)
                }
            })
            .actionSheet(isPresented: self.$isShowActionSheet) {
                if self.recordVm.mediaPickerType == .main {
                    return ActionSheet(title: Text(""), message: Text("Browse Your Image , Videos and Audio"),
                                       buttons: [
                                        .default(Text("Image"), action: {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                                                self.recordVm.mediaPickerType = .image
                                                self.recordVm.snippetMediaType = 1
                                                self.isShowActionSheet = true
                                            })
                                        }),
                                        .cancel()
                                       ])
                } else if self.recordVm.mediaPickerType == .image {
                    return  ActionSheet(title: Text(""), message: Text("Browse Your Image"),
                                        buttons: [
                                            .default(Text("Camera"), action: {
                                                self.isPresentCamera = true
                                                self.recordVm.shouldOpenMediaPicker = true
                                            }),
                                            .default(Text("Gallery"), action: {
                                                self.recordVm.shouldOpenMediaPicker = true
                                                self.isPresentCamera = false
                                                // self.isShowVideos = false
                                            }),
                                            .cancel()
                                        ])
                }

                return ActionSheet(title: Text("Nothing to Show"))
            }
            
        }
        .onAppear {
            UIScrollView.appearance().bounces = false
        }
    }
}

// MARK: - Previews
struct RecordAudioView_Previews: PreviewProvider {
    static var previews: some View {
        RecordAudioView()
    }
}
