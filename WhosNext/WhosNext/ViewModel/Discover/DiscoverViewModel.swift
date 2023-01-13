//
//  DiscoverViewModel.swift
//  WhosNext
//
//  Created by differenz240 on 21/11/22.
//

import SwiftUI

class DiscoverViewModel: ObservableObject {
    // MARK: - Variables
    @Published var categoryList: [SelectTalentModel] = []
    @Published var selectedCategory: SelectTalentModel? = nil
    
    @Published var userListByCategory: GetUsersByCategoryModel? = nil

    @Published var searchedCategory: String = ""
    @Published var shouldShowCategoryDropDown: Bool = false
    
    @Published var moveToProfile: Bool = false

    @Published var errorMsg: String = ""
    @Published var showError: Bool = false
}

// MARK: - Functions
extension DiscoverViewModel {
    /// `setter` for the `self.selectedCategory`
    func setSelectedCategory(category: SelectTalentModel) -> Void {
        self.selectedCategory = category
    }
}

// MARK: - API Calls
extension DiscoverViewModel {
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
    
    /// `api call` for user list by category id
    func getUsersByCategory() -> Void {
        let param = [
            GetUsersByCategoryKeys.category_id.rawValue: self.selectedCategory?.categoryId ?? "",
            GetUsersByCategoryKeys.search_keyword.rawValue: self.searchedCategory
        ] as [String: Any]

        GetUsersByCategoryModel.getUsersByCategory(params: param, success: { response, message -> Void in
            guard let model = response else { return }

            self.userListByCategory = model
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }
}
