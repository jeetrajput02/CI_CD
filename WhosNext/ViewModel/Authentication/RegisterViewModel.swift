//
//  RegisterViewModel.swift
//  WhosNext
//
//  Created by differenz195 on 29/09/22.
//

import SwiftUI

public class RegisterViewModel: ObservableObject {
    @Published var categoryList: [SelectTalentModel] = []
    @Published var selectedCategories: [SelectTalentModel] = []
    
    @Published var firstName : String = ""
    @Published var lastName : String = ""
    @Published var userName : String = ""
    @Published var email : String = ""
    @Published var confirmEmail : String = ""
    @Published var password : String = ""
    @Published var confirmPassword : String = ""
    @Published var introductionVideo : String = ""
    @Published var categoryId: Int = 0
    @Published var isSelected : Bool = false
    @Published var ShowImage: UIImage?
    @Published var isShowPhotoLibrary = false
    @Published var shouldPresentImagePicker = false
    @Published var isPresentCamera = false
    
    @Published var isVideoUpload:Bool = false
    @Published var videoURL: URL?
    @Published var uploadedVideo:URL?
    @Published var tempVideo: URL?
    
    @Published var moveToTermsPrivacy: Bool = false
    @Published var moveToLoginPage: Bool = false
    @Published var isForPrivacy = true
    @Published var videoRemote: String = ""
    @Published var videoThumbnail: String = ""
    
    @Published var tempValue : [String] = []
    
    var videoData = [String:Data]()
    var thumbnailData = [String:Data]()
    
    ///validation
    @Published var showingError = false
    @Published var errorMessage : String = ""
    
    func onBtnTermsPrivacy_Click(isForPrivacy : Bool) {
        self.isForPrivacy = isForPrivacy
        self.moveToTermsPrivacy = true
    }
    
    func clearState() -> Void {
        self.firstName = ""
        self.lastName = ""
        self.userName = ""
        self.email = ""
        self.confirmEmail = ""
        self.password = ""
        self.confirmPassword = ""
        self.introductionVideo = ""
        self.categoryId = 0
        self.isSelected = false
        self.ShowImage = nil
        self.isShowPhotoLibrary = false
        self.shouldPresentImagePicker = false
        self.isPresentCamera = false
        self.isVideoUpload = false
        self.videoURL = nil
        self.uploadedVideo = nil
        self.tempVideo = nil
        
        self.moveToTermsPrivacy = false
        self.moveToLoginPage = false
        self.isForPrivacy = true
        
        self.tempValue = []
        
        self.videoData = [String: Data]()
        self.thumbnailData = [String: Data]()
        
        self.showingError = false
        self.errorMessage = ""
    }
}

// MARK: - Helper Methods
extension RegisterViewModel {
    /**
     This method is used to validate user input.
     - Returns: Return boolean value to indicate input data is valid or not.
     */
    func isValidUserinput() -> Bool {
        let emailRegEx = IdentifiableKeys.ConstantString.kEmailRegex
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        if self.firstName.trimWhiteSpace.isEmpty {
            errorMessage = IdentifiableKeys.ValidationMessages.kEmptyFirstName
            showingError = true
            return false
        }
        
        else if self.lastName.trimWhiteSpace.isEmpty {
            errorMessage = IdentifiableKeys.ValidationMessages.kEmptyLastName
            showingError = true
            return false
        }
        
        else if self.userName.trimWhiteSpace.isEmpty {
            errorMessage = IdentifiableKeys.ValidationMessages.kEmptyUsername
            showingError = true
            return false
        }
        else if self.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = IdentifiableKeys.ValidationMessages.kEmptyEmail
            showingError = true
            return false
        }
        
        else if !emailTest.evaluate(with: self.email) {
            errorMessage = IdentifiableKeys.ValidationMessages.kInvalidEmail
            showingError = true
            return false
        }
        
        else if self.confirmEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = IdentifiableKeys.ValidationMessages.kConfirmedEmailID
            showingError = true
            return false
        }
        
        else if self.confirmEmail != self.email{
            errorMessage = IdentifiableKeys.ValidationMessages.kDoesNotMatchEmailID
            showingError = true
            return false
        }
        else if self.password.trimWhiteSpace.isEmpty {
            errorMessage = IdentifiableKeys.ValidationMessages.kEmptyPassword
            showingError = true
            return false
        }
        
        else if !self.password.trimWhiteSpace.isValidPassword() {
            errorMessage = IdentifiableKeys.ValidationMessages.kPasswordMaximumCharcter
            showingError = true
            return false
        }
        
        else if self.confirmPassword.trimWhiteSpace.isEmpty {
            errorMessage = IdentifiableKeys.ValidationMessages.kEmptyConfiremPassword
            showingError = true
            return false
        }
        
        else if !self.confirmPassword.trimWhiteSpace.isValidPassword() {
            errorMessage = IdentifiableKeys.ValidationMessages.kPasswordMaximumCharcter
            showingError = true
            return false
        }
        else if self.confirmPassword != self.password{
            errorMessage = IdentifiableKeys.ValidationMessages.kDoesNotMatchConfirmPassword
            showingError = true
            return false
        }
        else if self.selectedCategories.count == 0 {
            errorMessage = IdentifiableKeys.ValidationMessages.kEmptyCategories
            showingError = true
            return false
        }
        
        else if self.videoURL == URL(string: "")  {
            errorMessage = IdentifiableKeys.ValidationMessages.kEmptyIntroductionVideo
            showingError = true
            return false
        }
        
        else if self.isSelected == false {
            errorMessage = IdentifiableKeys.ValidationMessages.kEmptyTermsAndCondition
            showingError = true
            return false
        }
        
        return true
    }
    
    /// `conversion` of `video url` to `data`
    func videoUrlToData(completion: @escaping () -> ()) {
        Indicator.show()

        if self.videoURL != nil  {
            let videoData = try? Data(contentsOf: self.videoURL!)
            self.videoData = ["introduction_video": videoData ?? Data()]
        }

        guard let url = self.videoURL else { return }
        
        AWSS3Manager.shared.uploadVideo(video: url, bucketname: AWSBucket.introVideo, withSuccess: {
            (fileURL, remoteName) in
            guard let videoName = remoteName.split(separator: "/").last else { return }
            
            self.videoRemote = String(videoName)
            guard let image =  Utilities.getThumbnailImage(forUrl: url) else { return }
            
            AWSS3Manager.shared.uploadImage(image: image, bucketname: AWSBucket.introThumbnail, withSuccess: {
                (fileURL, thumbnail) in
                guard let thumbnailName = thumbnail.split(separator: "/").last else { return }
                self.videoThumbnail = String(thumbnailName)
                
                completion()
            }, failure: { (error) in
                
            }, connectionFail: {(error) in
                
            })
        }, failure: { (error) in
            
        }, connectionFail: { (error) in
            
        })
    }
    
    /// `Register User` API Call
    func registerUserApiCall(isShoLoader:Bool = true,  Success: @escaping () -> ()) {
        guard self.isValidUserinput() else { return }
        
        let category = self.selectedCategories.map({
            $0.categoryId == -1 ? "\($0.category)" : "\($0.categoryId)"
        }).joined(separator: ",")
        
        self.videoUrlToData {
            guard let video_url = self.videoURL else { return }
            let videoResolution = Utilities.getWidthHeightOfVideo(with: video_url)

            let params: [String: Any] = [
                userModelKey.firstName : self.firstName,
                userModelKey.lastName : self.lastName,
                userModelKey.userName : self.userName,
                userModelKey.email : self.email,
                userModelKey.password : self.password,
                userModelKey.categoryId : category,
                userModelKey.deviceType : 1,
                userModelKey.deviceModel : "",
                userModelKey.appVersion : "",
                userModelKey.introduction_video: self.videoRemote,
                userModelKey.introduction_video_thumb: self.videoThumbnail,
                userModelKey.video_width: videoResolution.first ?? 0.0,
                userModelKey.video_height: videoResolution.last ?? 0.0,
                userModelKey.deviceToken : UserDefaults.standard.string(forKey: UserDefaultsKey.kDeviceToken) ?? ""
            ]
            
            print("All Register Params :- \(params)")
            
            UserModel.registerUser(params: params, success: { response, message in
                if isShoLoader {
                    Indicator.hide()
                }
                
                self.userName = ""
                self.firstName = ""
                self.lastName = ""
                self.email = ""
                self.confirmEmail = ""
                self.password = ""
                self.confirmPassword = ""
                self.selectedCategories.removeAll()
                self.isSelected = false
                
                Success()
            }, failure: { (errmsg) in
                if isShoLoader {
                    Indicator.hide()
                }
                
                print(errmsg)
                Alert.show(message: errmsg)
            })
        }
    }
    
    /// `api call` for get category list
    func getCategoryList(showLoader: Bool = true) {
        SelectTalentModel.GetCategoryList(showLoader: showLoader, withSuccess: { response in
            if response.count > 0 {
                self.categoryList = response
                Indicator.hide()
            } else {
                Alert.show(message: "No Data Found.")
            }
        },  withFailure: { error, isAuth in
            if showLoader {
                Indicator.hide()
            }
            
            Alert.show(message: error, isLogOut: isAuth)
        })
    }
}



