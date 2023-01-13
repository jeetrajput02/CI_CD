//
//  ProfileViewModel.swift
//  WhosNext
//
//  Created by differenz195 on 11/10/22.
//

import SwiftUI
import AVKit

public class ProfileViewModel: ObservableObject {
    @Published var profileModel: ProfileModel?
    @Published var cityModel: CityModel? = nil
    @Published var categoryList: [SelectTalentModel] = []
    
    @Published var selectedCity: CityData? = nil
    @Published var selectedCategories: [SelectTalentModel] = []
    
    @Published var userId: Int = -1
    
    @Published var videoURL: URL? = nil
    @Published var videoThumbnailURL: URL? = nil
    @Published var deleteVideoFileName: String = ""
    @Published var deleteVideoThumbFileName: String = ""
    
    @Published var moveToEditProfile: Bool = false
    @Published var moveToFollowers: Bool = false
    @Published var moveToFollowing: Bool = false
    @Published var moveToPosts: Bool = false
    @Published var isSideBarOpened: Bool = false
    
    @Published var errorMsg = ""
    @Published var showError = false
    
    @Published var isOpenValidationAlert = false
    @Published var validationAlertMsg = ""
    
    @Published var info: AlertInfo?
    @Published var videoRemote: String = ""
    @Published var videoThumbnail: String = ""
    
    @Published var muteBtnOpacity: Int = 1
    
    @Published var isVideoLoad: Bool = false
    @Published var isPrivate = false
    @Published var isPresent = false
    @Published var isOpenDeactivateAlert = false
    @Published var isShowMuteBtn: Bool = true
    
    @Published var aboutSelf: String?
    @Published var city: String = ""
    @Published var website1: String = ""
    @Published var website2: String = ""
    @Published var website3: String = ""
    @Published var website4: String = ""
    @Published var website5: String = ""
    @Published var category: String = ""
    
    @Published var isShowPhotosLibrary: Bool = false
    @Published var isShowSheet : Bool = false
    @Published var isShowCitySheet = false
    @Published var player = AVPlayer()
    @Published var firstName: String = ""
    @Published var lasttName: String = ""
    @Published var userName: String = ""
    @Published var email: String = ""
    @Published var videoSheet = false
    
    @Published var isShowVideos: Bool = false
    
    @Published var arrImage: [UIImage] = []

    @Published var isShowImage: UIImage? = nil
    @Published var shouldPresentImagePicker = false
    @Published var isPresentCamera = false
}

// MARK: - Functions
extension ProfileViewModel {
    /// `validations` for the edit profile screen
    func validations() -> Bool {
        if self.firstName.trimWhiteSpace == "" {
            self.isOpenValidationAlert = true
            self.validationAlertMsg = IdentifiableKeys.ValidationMessages.kEmptyFirstName
            return false
        } else if self.lasttName.trimWhiteSpace == "" {
            self.isOpenValidationAlert = true
            self.validationAlertMsg = IdentifiableKeys.ValidationMessages.kEmptyLastName
            return false
        } else if self.userName.trimWhiteSpace == "" {
            self.isOpenValidationAlert = true
            self.validationAlertMsg = IdentifiableKeys.ValidationMessages.kEmptyUsername
            return false
        } else if self.email.trimWhiteSpace == "" {
            self.isOpenValidationAlert = true
            self.validationAlertMsg = IdentifiableKeys.ValidationMessages.kEmptyEmail
            return false
        } else if self.email.trimWhiteSpace.isValidEmailAddress == false {
            self.isOpenValidationAlert = true
            self.validationAlertMsg = IdentifiableKeys.ValidationMessages.kInvalidEmail
            return false
        } else if self.selectedCity == nil {
            self.isOpenValidationAlert = true
            self.validationAlertMsg = IdentifiableKeys.ValidationMessages.kEmptyCity
            return false
        } else if self.category == "" {
            self.isOpenValidationAlert = true
            self.validationAlertMsg = IdentifiableKeys.ValidationMessages.kEmptyCategory
            return false
        } else {
            self.isOpenValidationAlert = false
            self.validationAlertMsg = ""
            return true
        }
    }
}

// MARK: - API Calls
extension ProfileViewModel {
    /// `api call` for getting the user profile
    func getUserProfileApiCall(completion: @escaping (ProfileModel?) -> Void) -> Void {
        guard let currentUser = UserDefaults.getData(UserDefaultsKey.kLoginUser, data: UserModel.self) else { return }
        
        let param = [ProfileModelKey.user_id: self.userId == -1 ? currentUser.userId : self.userId] as [String: Any]
        
        ProfileModel.getUserProfileApiCall(params: param, success: { response, message -> Void in
            guard let model = response else { return }
            
            self.profileModel = model

            completion(self.profileModel)
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }
    
    /// `api call` for update the user profile
    func updateUserProfile(completion: @escaping () -> Void) -> Void {
        if self.validations() {
            guard let model = self.profileModel, let videoUrl = self.videoURL, let videoThumbnailUrl = self.videoThumbnailURL else { return }
            
            Indicator.show()
            
            if videoUrl.absoluteString.starts(with: "http") {
                let video_url = videoUrl.absoluteString.split(separator: "?").first ?? ""
                self.videoRemote = String(video_url.split(separator: "/").last ?? "")

                let video_thumbnail_url = videoThumbnailUrl.absoluteString.split(separator: "?").first ?? ""
                self.videoThumbnail = String(video_thumbnail_url.split(separator: "/").last ?? "")

                let param = [
                    ProfileModelKey.first_name: self.firstName,
                    ProfileModelKey.last_name: self.lasttName,
                    ProfileModelKey.username: self.userName,
                    ProfileModelKey.email: self.email,
                    ProfileModelKey.city_id: self.selectedCity?.cityID == -1 ? "\(self.selectedCity?.city ?? "")" : "\(self.selectedCity?.cityID ?? 0)",
                    ProfileModelKey.category_id: self.category,
                    ProfileModelKey.introduction_video: self.videoRemote,
                    ProfileModelKey.introduction_video_thumb: self.videoThumbnail,
                    ProfileModelKey.video_width: model.data.videoWidth ?? 0.0,
                    ProfileModelKey.video_height: model.data.videoHeight ?? 0.0,
                    ProfileModelKey.about_self: self.aboutSelf ?? "",
                    ProfileModelKey.website_url_1: self.website1 == "http://" ? "" : self.website1,
                    ProfileModelKey.website_url_2: self.website2 == "http://" ? "" : self.website2,
                    ProfileModelKey.website_url_3: self.website3 == "http://" ? "" : self.website3,
                    ProfileModelKey.website_url_4: self.website4 == "http://" ? "" : self.website4,
                    ProfileModelKey.website_url_5: self.website5 == "http://" ? "" : self.website5,
                    ProfileModelKey.is_private: model.data.isPrivate ? 1 : 0
                ] as [String: Any]
                
                ProfileModel.updateUserProfile(params: param, success: { response, message -> Void in
                    completion()
                    
                    Indicator.hide()
                }, failure: { error -> Void in
                    self.errorMsg = error
                    self.showError = true
                    
                    Alert.show(title: "", message: error)
                })
            } else {
                Indicator.show()

                AWSS3Manager.shared.deleteMedia(fileName: self.deleteVideoFileName, bucket: .introVideo, withSuccess: { message -> Void in
                    print("deleted \(self.deleteVideoFileName) successfully from aws s3.")

                    AWSS3Manager.shared.deleteMedia(fileName: self.deleteVideoThumbFileName, bucket: .introThumbnail, withSuccess: { message -> Void in
                        print("deleted \(self.deleteVideoThumbFileName) successfully from aws s3.")

                        guard let video_url = self.videoURL else { return }
                        let videoResolution = Utilities.getWidthHeightOfVideo(with: video_url)
                        
                        Indicator.show()

                        AWSS3Manager.shared.uploadVideo(video: videoUrl, bucketname: .introVideo, withSuccess: { (fileURL, remoteName) in
                            guard let videoName = remoteName.split(separator: "/").last else { return }
                            
                            self.videoRemote = String(videoName)
                            
                            guard let image =  Utilities.getThumbnailImage(forUrl: videoUrl) else { return }
                            
                            AWSS3Manager.shared.uploadImage(image: image, bucketname: .introThumbnail, withSuccess: {
                                (fileURL, thumbnail) in
                                guard let thumbnailName = thumbnail.split(separator: "/").last else { return }
                                self.videoThumbnail = String(thumbnailName)
                                
                                let param = [
                                    ProfileModelKey.first_name: self.firstName,
                                    ProfileModelKey.last_name: self.lasttName,
                                    ProfileModelKey.username: self.userName,
                                    ProfileModelKey.email: self.email,
                                    ProfileModelKey.city_id: self.selectedCity?.cityID == -1 ? "\(self.selectedCity?.city ?? "")" : "\(self.selectedCity?.cityID ?? 0)",
                                    ProfileModelKey.category_id: self.category,
                                    ProfileModelKey.introduction_video: self.videoRemote,
                                    ProfileModelKey.introduction_video_thumb: self.videoThumbnail,
                                    ProfileModelKey.video_width: videoResolution.first ?? 0.0,
                                    ProfileModelKey.video_height: videoResolution.last ?? 0.0,
                                    ProfileModelKey.about_self: self.aboutSelf ?? "",
                                    ProfileModelKey.website_url_1: self.website1 == "http://" ? "" : self.website1,
                                    ProfileModelKey.website_url_2: self.website2 == "http://" ? "" : self.website2,
                                    ProfileModelKey.website_url_3: self.website3 == "http://" ? "" : self.website3,
                                    ProfileModelKey.website_url_4: self.website4 == "http://" ? "" : self.website4,
                                    ProfileModelKey.website_url_5: self.website5 == "http://" ? "" : self.website5,
                                    ProfileModelKey.is_private: model.data.isPrivate ? 1: 0
                                ] as [String: Any]
                                
                                ProfileModel.updateUserProfile(params: param, success: { response, message -> Void in
                                    completion()
                                    
                                    Indicator.hide()
                                }, failure: { error -> Void in
                                    self.errorMsg = error
                                    self.showError = true
                                    
                                    Alert.show(title: "", message: error)
                                })
                            }, failure: { (error) in
                                Indicator.hide()
                            }, connectionFail: {(error) in
                                Indicator.hide()
                            })
                            
                        }, failure: { (error) in
                            Indicator.hide()
                        }, connectionFail: {(error) in
                            Indicator.hide()
                        })
                    }, failure: { error -> Void in
                        Indicator.hide()
                    })
                }, failure: { error -> Void in
                    Indicator.hide()
                })
            }
        }
    }
    
    /// `api call` for change profile visibility
    func changeProfileVisibility(profileModel: ProfileModel, isPrivate: Bool) -> Void {
        var videoUrl = ""
        var videoThumbail = ""

        let video = (profileModel.data.introductionVideo ?? "").split(separator: "?").first ?? ""
        videoUrl = String(video.split(separator: "/").last ?? "")

        let videoThumb = (profileModel.data.introductionVideoThumb ?? "").split(separator: "?").first ?? ""
        videoThumbail = String(videoThumb.split(separator: "/").last ?? "")

        let param = [
            ProfileModelKey.first_name: profileModel.data.firstName,
            ProfileModelKey.last_name: profileModel.data.lastName,
            ProfileModelKey.username: profileModel.data.username,
            ProfileModelKey.email: profileModel.data.email,
            ProfileModelKey.city_id: profileModel.data.cityID,
            ProfileModelKey.category_id: profileModel.data.categoryID,
            ProfileModelKey.introduction_video: videoUrl,
            ProfileModelKey.introduction_video_thumb: videoThumbail,
            ProfileModelKey.video_width: profileModel.data.videoWidth ?? 0.0,
            ProfileModelKey.video_height: profileModel.data.videoHeight ?? 0.0,
            ProfileModelKey.about_self: profileModel.data.aboutSelf,
            ProfileModelKey.website_url_1: profileModel.data.websiteURL1,
            ProfileModelKey.website_url_2: profileModel.data.websiteURL2,
            ProfileModelKey.website_url_3: profileModel.data.websiteURL3,
            ProfileModelKey.website_url_4: profileModel.data.websiteURL4,
            ProfileModelKey.website_url_5: profileModel.data.websiteURL5,
            ProfileModelKey.is_private: isPrivate ? 1 : 0
        ] as [String: Any]

        ProfileModel.changeProfileVisibility(params: param, success: { response, message -> Void in
            self.getUserProfileApiCall(completion: { profileModel -> Void in
                self.profileModel = profileModel
            })
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }

    /// `api call` for change profile visibility
    func deactivateAccount(completion: @escaping (String) -> Void) -> Void {
        ProfileModel.deactivateAccount(success: { success, message -> Void in
            // self.info = AlertInfo(id: .success, title: "", message: message)

            completion(message)
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }
    
    /// `api call` for profile view count
    func profileViewCount(userId: String, viewType: String, completion: @escaping () -> Void) -> Void {
        let param = [PostModelKey.id: userId, PostModelKey.viewType: viewType] as [String: Any]
        PostModel.postViewCount(params: param, success: {
            completion()
            Indicator.hide()
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            Alert.show(title: "", message: error)
        })
    }

    /// `api call` for follow/unfollow user
    func followUnfollowUser(completion: @escaping () -> Void) -> Void {
        guard let currentUser = UserDefaults.getData(UserDefaultsKey.kLoginUser, data: UserModel.self) else { return }
        
        let param = [ProfileModelKey.user_id: self.userId == -1 ? currentUser.userId : self.userId] as [String: Any]

        ProfileModel.followunFollowUser(param: param, success: {
            completion()
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }

    /// `api call` for get the cities
    func getCities(completion: @escaping (CityModel?) -> Void) -> Void {
        CityModel.getCities(success: { cityModel, message -> Void in
            self.cityModel = cityModel

            completion(self.cityModel)
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }
    
    /// `api call` for get category list
    func getCategoryList(showLoader: Bool = true, completion: @escaping ([SelectTalentModel]?) -> Void) {
        SelectTalentModel.GetCategoryList(showLoader: showLoader, withSuccess: { response in
            if response.count > 0 {
                self.categoryList = response

                completion(self.categoryList)
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
