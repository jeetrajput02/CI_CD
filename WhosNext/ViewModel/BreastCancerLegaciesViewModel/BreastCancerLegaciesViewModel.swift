//
//  BreastCancerLegaciesViewModel.swift
//  WhosNext
//
//  Created by differenz195 on 20/10/22.
//

import SwiftUI

enum BCLDateSelection {
    case birthDate
    case passingDate
    case none
}

enum BCLCarnationSelection: Int {
    case none = 0
    case carnation1 = 1
    case carnation2 = 2
    case carnation3 = 3
}

class BreastCancerLegaciesViewModel: ObservableObject {
    @Published var legaciesHomeScreenModel: LegaciesHomeScreenModel? = nil
    @Published var legacies: [LegaciesHomeScreenData] = []
    @Published var currentpage: Int = 1
    @Published var postsListFull: Bool = false
    
    @Published var legacyDetailModel: BCLDetailsModel? = nil
    @Published var selectedLegacy: LegaciesHomeScreenData? = nil
    
    @Published var reportReasonsModel: ReportReasonModel? = nil
    @Published var selectedReportReason: ReportReasonData? = nil
    @Published var showReportSheet: Bool = false

    @Published var imageSelected: Bool = false
    @Published var dateSelectedOnEdit: Bool = false
    
    @Published var deleteImageFileName: String = ""
    @Published var deleteImageThumbFileName: String = ""
    
    @Published var isDateSelect: BCLDateSelection = .none
    @Published var carnationSelect: BCLCarnationSelection = .none
    
    @Published var isSideBarOpened: Bool = false
    @Published var moveToCreateLegacy: Bool = false
    @Published var editLegacy: Bool = false
    @Published var postId: String = ""
    @Published var legaciesName: String = ""
    @Published var legaciesDescription: String?
    @Published var description: String = ""
    @Published var carnation: String = ""
    @Published var postHeight: Double = 0.0
    @Published var postWidth: Double = 0.0
    @Published var dateOfBirth: String = ""
    @Published var dateOfPassing: String = ""
    @Published var showDatePicker = false
    @Published var isShowActionSheet: Bool = false
    @Published var shouldPresentImagePicker: Bool = false
    @Published var isPresentCamera = false
    @Published var image: UIImage? = nil
    @Published var videoURL: URL?
    @Published var videoUrl: String = ""
    @Published var moveToProfile: Bool = false
    @Published var placeholderText: String = "Please type description"
    @Published var isSelected = false
    @Published var arrImage: [UIImage] = []
    @Published var showValidationAlert: Bool = false
    @Published var validationMsg: String = ""
    @Published var errorMsg = ""
    @Published var showError = false
    @Published var imageRemote: String = ""
    
    @Published var updatedCommentPostId: Int = 0
    @Published var isCommentUpdated: Bool = false
    
    @Published var userID: Int = 0
    @Published var userFullName: String = ""
    @Published var postID: Int = 0
    @Published var videoSheet: Bool = false
    @Published var showDetailVideo: Bool = false
    @Published var isMoreBtnSheet: Bool = false
    @Published var isShowControls: Bool = true
    @Published var isShowMuteBtn: Bool = true
    @Published var moveToComments: Bool = false
    @Published var moveToLegacyDetails: Bool = false
    @Published var moveToShareScreen: Bool = false
}

// MARK: - Functions
extension BreastCancerLegaciesViewModel {
    /// `validations` for Create bcl post
    func validations() -> Bool {
        if self.image == nil {
            self.validationMsg = "Please select an image"
            self.showValidationAlert = true
            
            return false
        } else if self.legaciesName.trimWhiteSpace.isEmpty {
            self.validationMsg = "Please add your name"
            self.showValidationAlert = true
            
            return false
        } else if self.legaciesDescription == nil {
            self.validationMsg = "Please enter description"
            self.showValidationAlert = true
            
            return false
        }  else if ((self.legaciesDescription?.trimWhiteSpace == "")) {
            if ((self.legaciesDescription?.replacingOccurrences(of: " ", with: "")) != nil) {
                self.validationMsg = "Please enter description."
                self.showValidationAlert = true
                
                return false
            } else {
                return true
            }
        }  else {
            self.validationMsg = ""
            self.showValidationAlert = false
            
            return true
        }
    }
}

// MARK: - API Calls
extension BreastCancerLegaciesViewModel {
    /// `api call` get legacies data
    func getLegaciesData() -> Void {
        let params = ["page": self.currentpage] as [String: Any]
        
        LegaciesHomeScreenModel.getLegaciesData(params: params, success: { [self] response, message -> Void in
            guard let model = response else { return }
            
            
            if self.currentpage == 1 {
                self.legaciesHomeScreenModel = model
                
                guard let posts = model.data else { return }
                self.legacies = posts
            } else {
                if ((self.legaciesHomeScreenModel?.data?.count) ?? 0) % 10 == 0 && model.data?.count != 0 {
                    self.legaciesHomeScreenModel?.data?.append(contentsOf: model.data ?? [])
                    
                    guard let posts = model.data else { return }
                    
                    self.legacies.append(contentsOf: posts)
                }
                
                else if ((self.legaciesHomeScreenModel?.data?.count ?? 0) > (model.totalCount ?? 0)){
                    self.legaciesHomeScreenModel?.data?.removeLast()
                    self.legacies.removeLast()
                }
                
                
                //                else if ((self.legaciesHomeScreenModel?.data?.count) ?? 0) % 10 > (model.data?.count ?? 0) % 10 {
                //
                //                }
                else if ((self.legaciesHomeScreenModel?.data?.count) ?? 0) % 10 < (model.data?.count ?? 0) % 10 {
                    self.legaciesHomeScreenModel?.data?.append((model.data?.last)!)
                    self.legacies.append((model.data?.last)!)
                }
                else if ((self.legaciesHomeScreenModel?.data?.count) ?? 0) % 10 == (model.data?.count ?? 0) % 10 {
                    
                    for i in 0..<(model.data?.count ?? 0) {
                        if model.data![i].postID == self.selectedLegacy?.postID{
                            //                            print(model.data![i].postID)
                            
                            for j in 0..<(self.legaciesHomeScreenModel?.data!.count)! {
                                if legaciesHomeScreenModel?.data![j].postID == model.data![i].postID {
                                    self.legaciesHomeScreenModel?.data![j] = model.data![i]
                                    self.legacies[j] = model.data![i]
                                    
                                }
                            }
                        }
                    }
                }
            }
            //            print("legacy_posts: \(self.legacies)")
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }
    
    /// `api call` for pagination in legacies
    func loadMoreLegaciesData(currentLegacy legacy: LegaciesHomeScreenData) {
        guard let legacies = self.legaciesHomeScreenModel?.data, legacies.count >= (self.currentpage * 10) else { return }
        
        if (self.legaciesHomeScreenModel?.totalCount ?? 0) > legacies.count {
            if self.legaciesHomeScreenModel?.data?.last?.postID == legacy.postID {
                self.currentpage += 1
                self.getLegaciesData()
            }
        }
    }
    
    /// `api call` for creating  legacies
    func createLegacies(postId: String, isShowLoader: Bool = true,  completion: @escaping () -> ()) -> Void {
        guard self.validations() else { return }
        
        Indicator.show()
        
        AWSS3Manager.shared.uploadImage(image: self.image ?? UIImage(), bucketname: .bclImage, withSuccess: { fileUrl, thumbName in
            guard let imageName = thumbName.split(separator: "/").last else { return }
            self.imageRemote = String(imageName)
            
            /// `image height`
            let height = self.image?.size.height
            self.postHeight = Double(height ?? 0.0)
            
            /// `image width`
            let width = self.image?.size.width
            self.postWidth = Double(width ?? 0.0)
            
            /// `input date format`
            let inputDateFormatter = DateFormatter()
            inputDateFormatter.dateFormat = "MM/dd/yyyy"
            let dateBirth = inputDateFormatter.date(from: self.dateOfBirth)
            let datePassing = inputDateFormatter.date(from: self.dateOfPassing)
            
            /// `output date format`
            let outputDateFormatter = DateFormatter()
            outputDateFormatter.dateFormat = "yyyy-MM-dd"
            let outputDateBirth = outputDateFormatter.string(from: dateBirth ?? Date())
            let outputDatePassing = outputDateFormatter.string(from: datePassing ?? Date())
            
            let params = [
                BreastCancerLegaciesModelKeys.post_id.rawValue: postId,
                BreastCancerLegaciesModelKeys.legacies_name.rawValue: self.legaciesName,
                BreastCancerLegaciesModelKeys.legacies_description.rawValue: self.legaciesDescription ?? "",
                BreastCancerLegaciesModelKeys.post_url.rawValue: self.imageRemote,
                BreastCancerLegaciesModelKeys.post_thumbnail.rawValue: self.imageRemote,
                BreastCancerLegaciesModelKeys.post_height.rawValue: self.postHeight,
                BreastCancerLegaciesModelKeys.post_width.rawValue: self.postWidth,
                BreastCancerLegaciesModelKeys.carnation.rawValue: self.carnationSelect.rawValue,
                BreastCancerLegaciesModelKeys.date_of_birth.rawValue: self.carnationSelect.rawValue == 3 ? outputDateBirth : "",
                BreastCancerLegaciesModelKeys.date_of_passing.rawValue: self.carnationSelect.rawValue == 3 ? outputDatePassing : ""
            ] as [String: Any]
            
            BreastCancerLegaciesModel.createOrUpdateLegacies(params: params, success: {
                completion()
                Indicator.hide()
            }, failure: { error -> Void in
                self.errorMsg = error
                self.showError = true
                
                Alert.show(title: "", message: error)
            })
        }, failure: { error in
            Indicator.hide()
            
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        }, connectionFail: { error in
            Indicator.hide()
            
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }
    
    /// `api call` for  updating legacies
    func updateLegacies(postId: String, deleteImageName: String, isShowLoader: Bool = true,  completion: @escaping () -> ()) -> Void {
        guard self.validations() else { return }
        
        Indicator.show()
        
        if self.imageSelected == false {
            /// `input date format`
            let inputDateFormatter = DateFormatter()
            inputDateFormatter.dateFormat = "MM/dd/yyyy"
            let dateBirth = inputDateFormatter.date(from: self.dateOfBirth)
            print("updateLegacies dateBirth --> \(String(describing: dateBirth))")
            let datePassing = inputDateFormatter.date(from: self.dateOfPassing)
            print("updateLegacies datePassing --> \(String(describing: datePassing))")
            
            /// `output date format`
            let outputDateFormatter = DateFormatter()
            outputDateFormatter.dateFormat = "yyyy-MM-dd"
            let outputDateBirth = outputDateFormatter.string(from: dateBirth ?? Date())
            print("updateLegacies outputDateBirth --> \(outputDateBirth)")
            let outputDatePassing = outputDateFormatter.string(from: datePassing ?? Date())
            print("updateLegacies outputDatePassing --> \(outputDatePassing)")
            
            let params = [
                BreastCancerLegaciesModelKeys.post_id.rawValue: postId,
                BreastCancerLegaciesModelKeys.legacies_name.rawValue: self.legaciesName,
                BreastCancerLegaciesModelKeys.legacies_description.rawValue: self.legaciesDescription ?? "",
                BreastCancerLegaciesModelKeys.post_url.rawValue: self.imageRemote,
                BreastCancerLegaciesModelKeys.post_thumbnail.rawValue: self.imageRemote,
                BreastCancerLegaciesModelKeys.post_height.rawValue: self.postHeight,
                BreastCancerLegaciesModelKeys.post_width.rawValue: self.postWidth,
                BreastCancerLegaciesModelKeys.carnation.rawValue: self.carnationSelect.rawValue,
                BreastCancerLegaciesModelKeys.date_of_birth.rawValue: self.carnationSelect.rawValue == 3 ? outputDateBirth : "",
                BreastCancerLegaciesModelKeys.date_of_passing.rawValue: self.carnationSelect.rawValue == 3 ? outputDatePassing : ""
            ] as [String: Any]
            
            BreastCancerLegaciesModel.createOrUpdateLegacies(params: params, success: {
                completion()
                Indicator.hide()
            }, failure: { error -> Void in
                self.errorMsg = error
                self.showError = true
                
                Alert.show(title: "", message: error)
            })
        } else {
            AWSS3Manager.shared.deleteMedia(fileName: deleteImageName, bucket: .postImage, withSuccess: { message -> Void in
                print("deleted \(deleteImageName) successfully from aws s3.")
                
                Indicator.show()
                
                AWSS3Manager.shared.uploadImage(image: self.image ?? UIImage(), bucketname: .bclImage, withSuccess: { fileUrl, thumbName in
                    guard let imageName = thumbName.split(separator: "/").last else { return }
                    self.imageRemote = String(imageName)
                    
                    /// `image height`
                    let height = self.image?.size.height
                    self.postHeight = Double(height ?? 0.0)
                    
                    /// `image width`
                    let width = self.image?.size.width
                    self.postWidth = Double(width ?? 0.0)
                    
                    /// `input date format`
                    let inputDateFormatter = DateFormatter()
                    inputDateFormatter.dateFormat = "MM/dd/yyyy"
                    let dateBirth = inputDateFormatter.date(from: self.dateOfBirth)
                    let datePassing = inputDateFormatter.date(from: self.dateOfPassing)
                    
                    /// `output date format`
                    let outputDateFormatter = DateFormatter()
                    outputDateFormatter.dateFormat = "yyyy/MM/dd"
                    let outputDateBirth = outputDateFormatter.string(from: dateBirth ?? Date())
                    print("updateLegacies deleteMedia outputDateBirth --> \(outputDateBirth)")
                    let outputDatePassing = outputDateFormatter.string(from: datePassing ?? Date())
                    print("updateLegacies deleteMedia outputDatePassing --> \(outputDatePassing)")
                    
                    let params = [
                        BreastCancerLegaciesModelKeys.post_id.rawValue: postId,
                        BreastCancerLegaciesModelKeys.legacies_name.rawValue: self.legaciesName,
                        BreastCancerLegaciesModelKeys.legacies_description.rawValue: self.legaciesDescription ?? "",
                        BreastCancerLegaciesModelKeys.post_url.rawValue: self.imageRemote,
                        BreastCancerLegaciesModelKeys.post_thumbnail.rawValue: self.imageRemote,
                        BreastCancerLegaciesModelKeys.post_height.rawValue: self.postHeight,
                        BreastCancerLegaciesModelKeys.post_width.rawValue: self.postWidth,
                        BreastCancerLegaciesModelKeys.carnation.rawValue: self.carnationSelect.rawValue,
                        BreastCancerLegaciesModelKeys.date_of_birth.rawValue: self.carnationSelect.rawValue == 3 ? outputDateBirth : "",
                        BreastCancerLegaciesModelKeys.date_of_passing.rawValue: self.carnationSelect.rawValue == 3 ? outputDatePassing : ""
                    ] as [String: Any]
                    
                    BreastCancerLegaciesModel.createOrUpdateLegacies(params: params, success: {
                        completion()
                        Indicator.hide()
                    }, failure: { error -> Void in
                        self.errorMsg = error
                        self.showError = true
                        
                        Alert.show(title: "", message: error)
                    })
                }, failure: { error in
                    Indicator.hide()
                    
                    self.errorMsg = error
                    self.showError = true
                    
                    Alert.show(title: "", message: error)
                }, connectionFail: { error in
                    Indicator.hide()
                    
                    self.errorMsg = error
                    self.showError = true
                    
                    Alert.show(title: "", message: error)
                })
            }, failure: { error -> Void in
                Indicator.hide()
            })
        }
    }
    
    /// `api call` for  post detail view
    func legacyDetails(postID: String, completion: @escaping () -> Void) -> Void {
        let param = [PostModelKey.postID: postID] as [String: Any]
        
        BCLDetailsModel.BCLDetails(params: param, success: { response, message -> Void in
            guard let postDetailModel = response else { return }
            
            self.legacyDetailModel = postDetailModel
            //            print("legacyDetailModel --> \(self.legacyDetailModel)")
            completion()
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }
    
    /// `api call` for post like
    func legacyLike(postID: String, completion: @escaping () -> Void) -> Void {
        let param = [PostModelKey.postID: postID] as [String: Any]
        
        PostModel.postLike(params: param, success: { () -> Void in
            completion()
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }
    
    /// `api call` for post view count
    func legacyViewCountApi(postID: String, viewType: String, completion: @escaping () -> Void) -> Void {
        let param = [PostModelKey.id: postID, PostModelKey.viewType: viewType] as [String: Any]
        
        PostModel.postViewCount(params: param, success: {
            completion()
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            Alert.show(title: "", message: error)
        })
    }
    
    /// `api call` for legacy Delete
    func legacyDelete(postID: String, completion: @escaping () -> Void) -> Void {
        let param = [PostModelKey.postID: postID] as [String: Any]
        
        PostModel.postDelete(params: param, success: {
            completion()
            self.getLegaciesData()
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }
    
    /// `api call` for post report
    func legacyReport(postID: String, reasonID: String, completion: @escaping () -> Void) -> Void {
        let param = [
            PostModelKey.postID: postID,
            PostModelKey.reasonID: reasonID
        ] as [String: Any]
        
        PostModel.postReport(params: param, success: {
            completion()
            Indicator.hide()
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }
    
    /// `api call` for get report reason
    func getReportReasons() -> Void {
        ReportReasonModel.getReportReasons { response, message -> Void in
            self.reportReasonsModel = response
        } failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        }
    }
}
