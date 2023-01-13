//
//  CreateNewBCLView.swift
//  WhosNext
//
//  Created by differenz195 on 28/10/22.
//

import SwiftUI
import BottomSheet
import SDWebImageSwiftUI

struct CreateNewBCLView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @StateObject var bclVM: BreastCancerLegaciesViewModel = BreastCancerLegaciesViewModel()
    
    @FocusState private var focusState: CommonTextFieldFocusState?
    @State private var date = Date()
    
    @State private var placeholderText: String = "Please type name"
    @State private var placeholderTextDescription: String = "Please type description"
    
    @State private var txtLegacyName: String?
    @State private var txtLegacyDescription: String?
    
    var legacyDetailsModel: BCLDetailsModel?
    var isEdit = false
    
    var body: some View {
        ZStack {
            VStack {
                CustomNavigationBar(title: IdentifiableKeys.NavigationbarTitles.kAddNew, isVisibleNotification: false, isVisibleBackBtn: true, backButtonAction: {
                    self.presentationMode.wrappedValue.dismiss()
                }, menuButtonAction: {}, refereshAction: {})
                
                ScrollView(showsIndicators: false) {
                    VStack {
                        HStack {
                            Text(IdentifiableKeys.Labels.kAddPicture)
                                .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._14FontSize))
                                .foregroundColor(Color.CustomColor.AppBCLColor)
                                .padding(.leading, 5)
                                .padding(.top, 5)
                            
                            Spacer()
                        }
                        
                        VStack {
                            self.addPictureSection()
                        }
                        .onTapGesture {
                            self.bclVM.isShowActionSheet = true
                        }
                        .background(Color.CustomColor.AppSnippetsColor)
                        
                        self.descriptionAndnameSection()
                        self.carnationSection()
                    }
                    
                }
                .bottomSheet(isPresented: self.$bclVM.showDatePicker, height: 250, showTopIndicator: false, content: {
                    self.calendarview()
                })
                .actionSheet(isPresented: self.$bclVM.isShowActionSheet) { () -> ActionSheet in
                    ActionSheet(title: Text(""), message: Text("Browse Your Photos"), buttons: [
                        .default(Text("Take From Camera"), action: {
                            self.bclVM.shouldPresentImagePicker = true
                            self.bclVM.isPresentCamera = true
                        }),
                        .default(Text("Select From Library"), action: {
                            self.bclVM.shouldPresentImagePicker = true
                            self.bclVM.isPresentCamera = false
                        }),
                        .cancel()
                    ])
                }
                .sheet(isPresented: self.$bclVM.shouldPresentImagePicker) {
                    CustomImagePickerView(sourceType: self.bclVM.isPresentCamera ? (UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary) : .photoLibrary, arrImage: self.$bclVM.arrImage, image: $bclVM.image, isPresented: self.$bclVM.shouldPresentImagePicker, videoURL: self.$bclVM.videoURL)
                }
                .onChange(of: self.bclVM.image) { newValue in
                    if newValue == nil {
                        self.bclVM.imageSelected = false
                    } else {
                        self.bclVM.imageSelected = true
                    }
                    
                }
            }
            .offset(y: ScreenSize.SCREEN_HEIGHT > 700.0 ? 0 : -8)
            .alert(isPresented: self.$bclVM.showValidationAlert) {
                Alert(title: Text(""), message: Text(bclVM.validationMsg), dismissButton: .default(Text("OK")) {})
            }
        }
        .onAppear {
            print("create/edit on appear detail model--> \(self.legacyDetailsModel?.data as Any)")
            if self.isEdit {
                self.bclVM.legaciesName = self.legacyDetailsModel?.data?.legaciesName ?? ""
                self.bclVM.legaciesDescription = self.legacyDetailsModel?.data?.legaciesDescription ?? ""
                
                if legacyDetailsModel?.data?.carnation == 0 {
                    self.bclVM.carnationSelect = .none
                } else if legacyDetailsModel?.data?.carnation == 1 {
                    self.bclVM.isSelected = true
                    self.bclVM.carnationSelect = .carnation1
                } else if legacyDetailsModel?.data?.carnation == 2 {
                    self.bclVM.isSelected = true
                    self.bclVM.carnationSelect = .carnation2
                } else if legacyDetailsModel?.data?.carnation == 3 {
                    self.bclVM.isSelected = true
                    self.bclVM.carnationSelect = .carnation3
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    let dateBirth = dateFormatter.date(from: self.legacyDetailsModel?.data?.dateOfBirth ?? "")
                    let datePassing = dateFormatter.date(from: self.legacyDetailsModel?.data?.dateOfPassing ?? "")
                    
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    
                    self.bclVM.dateOfBirth = dateFormatter.string(from: dateBirth ?? Date())
                    self.bclVM.dateOfPassing = dateFormatter.string(from: datePassing ?? Date())
                    
                    print("on appear detail model DOB --> \(self.bclVM.dateOfBirth)")
                    print("on appear detail model Passing Date --> \(self.bclVM.dateOfPassing)")
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .edgesIgnoringSafeArea(.top)
    }
}

// MARK: - UI Helpers
extension CreateNewBCLView {
    /// `add picture section`
    func addPictureSection() -> some View {
        VStack {
            if self.isEdit {
                if self.bclVM.imageSelected {
                    Image(uiImage: (self.bclVM.image ?? UIImage()))
                        .resizable()
                        .frame(width: ScreenSize.SCREEN_WIDTH, height: 300, alignment: .center)
                        .padding(.top, 10)
                    
                } else {
                    if let url = URL(string: self.legacyDetailsModel?.data?.postThumbnail ?? "") {
                        WebImage(url: url)
                            .resizable()
                            .frame(width: ScreenSize.SCREEN_WIDTH, height: 300)
                    }
                }
                
            } else {
                if self.bclVM.image == nil {
                    Image(IdentifiableKeys.ImageName.kCameraupload)
                        .resizable()
                        .frame(width: 45, height: 45, alignment: .center)
                    
                } else {
                    Image(uiImage: (self.bclVM.image ?? UIImage()))
                        .resizable()
                        .frame(width: ScreenSize.SCREEN_WIDTH, height: 300, alignment: .center)
                        .padding(.top, 10)
                }
            }
        }
        
        .frame(width: ScreenSize.SCREEN_WIDTH,height: 300)
        .background(Color.appSnippetsColor)
    }
    
    /// `description & name section`
    func descriptionAndnameSection() -> some View {
        VStack {
            HStack {
                Text(IdentifiableKeys.Labels.kAddName)
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._14FontSize))
                    .foregroundColor(Color.CustomColor.AppBCLColor)
                    .padding(.leading, 5)
                
                Spacer()
            }

            CommonEditProfileTextField(placeholderText: "Please type name", text: self.$bclVM.legaciesName, focusState: self.$focusState, currentFocus: .constant(.addName), onCommit: {
                self.focusState = nil
            })
            .submitLabel(.done)
            
            HStack {
                Text(IdentifiableKeys.Labels.kAddDescription)
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._14FontSize))
                    .foregroundColor(Color.CustomColor.AppBCLColor)
                    .padding(.leading, 5)
                Spacer()
            }
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: Binding(self.$bclVM.legaciesDescription, replacingNilWith: ""))
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
                    .colorMultiply(Color.appSnippetsColor)
                    .frame(alignment: .leading)
                
                Text(self.bclVM.legaciesDescription ?? self.bclVM.placeholderText)
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
                    .foregroundColor(Color.secondary.opacity(0.5))
                    .opacity(self.bclVM.legaciesDescription  == nil ? 1 : 0)
                    .padding([.horizontal], 5)
                    .padding(.vertical, 10)
                
            }
            .frame(width: ScreenSize.SCREEN_WIDTH, height: 100, alignment: .center)
            .background(Color.appSnippetsColor)
        }
    }
    
    /// `add carnation upload`
    func carnationSection() -> some View {
        VStack {
            HStack {
                Button(action: {
                    self.bclVM.isSelected.toggle()
                    self.bclVM.carnationSelect = .none
                }, label: {
                    HStack {
                        Image(self.bclVM.isSelected ? IdentifiableKeys.ImageName.kCheckedpink : IdentifiableKeys.ImageName.kUncheckedBox)
                            .resizable()
                            .frame(width: 20, height: 20, alignment: .center)
                        
                        Text(IdentifiableKeys.Labels.kAddCarnationduringupload)
                            .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
                            .foregroundColor(Color.CustomColor.AppBCLColor)
                        
                        Spacer()
                    }
                    .padding(.leading, 10)
                })
            }
            
            if self.bclVM.isSelected {
                VStack {
                    HStack {
                        Image(IdentifiableKeys.ImageName.kFlower1)
                            .resizable()
                            .frame(width: 16, height: 16)
                        
                        Button(action: {
                            self.bclVM.carnationSelect = .carnation1
                        }, label: {
                            HStack {
                                Image(self.bclVM.carnationSelect == .carnation1 ? IdentifiableKeys.ImageName.kRadioChecked : IdentifiableKeys.ImageName.kRadioUnchecked)
                                    .resizable()
                                    .frame(width: 20, height: 20, alignment: .center)
                                
                                Text(IdentifiableKeys.Labels.kWhileCarnationsloveandgoodluckfightingcancer)
                                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._12FontSize))
                                    .foregroundColor(Color.myDarkCustomColor)
                                
                                Spacer()
                            }
                            .padding(.leading, 10)
                        })
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 8)
                    
                    HStack {
                        Image(IdentifiableKeys.ImageName.kFlower2)
                            .resizable()
                            .frame(width: 16, height: 16)
                        
                        Button(action: {
                            self.bclVM.carnationSelect = .carnation2
                        }, label: {
                            HStack {
                                Image(self.bclVM.carnationSelect == .carnation2 ? IdentifiableKeys.ImageName.kRadioChecked : IdentifiableKeys.ImageName.kRadioUnchecked)
                                    .resizable()
                                    .frame(width: 20, height: 20, alignment: .center)
                                
                                Text(IdentifiableKeys.Labels.kPinkandWhiteCarnationsmeansyouhavebeatcancer)
                                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._12FontSize))
                                    .foregroundColor(Color.myDarkCustomColor)
                                
                                Spacer()
                            }
                            .padding(.leading, 10)
                        })
                    }
                    .padding(.horizontal, 8)
                    
                    HStack {
                        Image(IdentifiableKeys.ImageName.kFlower3)
                            .resizable()
                            .frame(width: 16, height: 16)
                        
                        Button(action: {
                            self.bclVM.carnationSelect = .carnation3
                        }, label: {
                            HStack {
                                Image(self.bclVM.carnationSelect == .carnation3 ? IdentifiableKeys.ImageName.kRadioChecked : IdentifiableKeys.ImageName.kRadioUnchecked)
                                    .resizable()
                                    .frame(width: 20, height: 20, alignment: .center)
                                
                                Text(IdentifiableKeys.Labels.kStrippedCarnationssomeonepassedawayformcancer)
                                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._12FontSize))
                                    .foregroundColor(Color.myDarkCustomColor)
                                
                                Spacer()
                            }
                            .padding(.leading, 10)
                        })
                    }
                    .padding(.bottom, 10)
                    .padding(.horizontal, 8)
                    
                    if self.bclVM.carnationSelect == .carnation3 {
                        HStack {
                            VStack(alignment: .leading, spacing: 5.0) {
                                Text(IdentifiableKeys.Labels.kDateofBirth)
                                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._12FontSize))
                                    .foregroundColor(Color.myDarkCustomColor)
                                
                                Text(self.bclVM.dateOfBirth == "" ? "MM/DD/YYYY" : bclVM.dateOfBirth)
                                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._12FontSize))
                                    .foregroundColor(Color.myDarkCustomColor)
                                
                                RoundedRectangle(cornerRadius: 2)
                                    .background(Color.black)
                                    .frame(height: 1)
                            }
                            .padding(.leading,10)
                            .onTapGesture {
                                self.bclVM.isDateSelect = .birthDate
                                self.bclVM.showDatePicker = true
                            }
                            
                            VStack(alignment: .leading,spacing: 5) {
                                Text(IdentifiableKeys.Labels.kDateofPassing)
                                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._12FontSize))
                                    .foregroundColor(Color.myDarkCustomColor)
                                
                                Text(bclVM.dateOfPassing == "" ? "MM/DD/YYYY" : bclVM.dateOfPassing)
                                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._12FontSize))
                                    .foregroundColor(Color.myDarkCustomColor)
                                
                                RoundedRectangle(cornerRadius: 2)
                                    .background(Color.black)
                                    .frame(height: 1)
                            }
                            .onTapGesture {
                                if self.bclVM.dateOfBirth == "" {
                                    Alert.show(message: "Please select date of birth.")
                                } else {
                                    self.bclVM.isDateSelect = .passingDate
                                    self.bclVM.showDatePicker = true
                                }
                            }
                        }
                        .background(colorScheme == .dark ? Color.appSnippetsColor : Color.white)
                        
                    }
                }
                .background(Color.appSnippetsColor)
            }
            
            
            
            Button(action: {
                var postId = ""

                if self.isEdit {
                    postId = "\(self.legacyDetailsModel?.data?.postID ?? 0)"
                } else {
                    postId = ""
                }
                
                if self.bclVM.imageSelected == false {
                    self.bclVM.imageRemote = String(self.legacyDetailsModel?.data?.postURL?.split(separator: "/").last ?? "")
                    self.bclVM.postHeight = Double(self.legacyDetailsModel?.data?.postHeight ?? 0)
                    self.bclVM.postWidth = Double(self.legacyDetailsModel?.data?.postWidth ?? 0)
                }
                
                if self.isEdit {
                    guard let legacy = self.legacyDetailsModel?.data, let deleteFileName = legacy.postURL?.split(separator: "?").first?.split(separator: "/").last else { return }
                    
                    self.bclVM.updateLegacies(postId: postId, deleteImageName: String(deleteFileName)) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    
                } else {
                    print("edit has not done, create new legacy button clicked")
                    self.bclVM.createLegacies(postId: postId) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
                
            }, label: {
                VStack {
                    Text(IdentifiableKeys.Buttons.kSubmit)
                        .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._20FontSize))
                        .foregroundColor(Color.white)
                }
                .frame(maxWidth : .infinity)
                .frame(height: 50)
                .background(Color.blue)
            })
            
        }
    }
    
    /// `calender view`
    func calendarview() -> some View {
        VStack {
            HStack {
                Spacer()
                
                Button {
                    DispatchQueue.main.async {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MM/dd/yyyy"
                        
                        switch self.bclVM.isDateSelect {
                            case .birthDate:
                                self.bclVM.dateOfBirth = dateFormatter.string(from: self.date)
                                self.bclVM.showDatePicker = false
                            case .passingDate:
                                self.bclVM.dateOfPassing = dateFormatter.string(from: self.date)
                                self.bclVM.showDatePicker = false
                            case .none:
                                break
                        }
                    }

                    self.bclVM.showDatePicker = false
                } label: {
                    Text(IdentifiableKeys.Buttons.kDone)
                        .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._22FontSize))
                        .foregroundColor(Color.white)
                }
            }
            .frame(height: 45)
            .background(Color.CustomColor.AppBCLColor)

            Spacer()
            
            if self.bclVM.showDatePicker {
                DatePicker("", selection: self.$date, in: ...(Calendar.current.date(byAdding: .day, value: 1, to: Date())!), displayedComponents: (self.bclVM.isDateSelect == .birthDate || self.bclVM.isDateSelect == .passingDate) ? .date : .hourAndMinute)
                    .onChange(of: self.date) { newValue in
                        DispatchQueue.main.async {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "MM/dd/yyyy"
                            
                            switch self.bclVM.isDateSelect {
                                case .birthDate:
                                    self.bclVM.dateOfBirth = dateFormatter.string(from: newValue)
                                    self.bclVM.showDatePicker = false
                                case .passingDate:
                                    self.bclVM.dateOfPassing = dateFormatter.string(from: newValue)
                                    self.bclVM.showDatePicker = false
                                case .none:
                                    break
                            }
                        }
                    }
            }
        }
    }
}

// MARK: - Previews
struct CreateNewBCLView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewBCLView()
    }
}



