//
//  CategoryViewModel.swift
//  WhosNext
//
//  Created by differenz240 on 17/11/22.
//

import SwiftUI

enum CategoryOperations { case add, edit, delete, clear }
enum CategoryViewAlertType { case validation, deleteConfirmation }

enum CRUDCategoryModel: String { case category_id, category, category_flag }

class CategoryViewModel: ObservableObject {
    @Published var searchedCategory: String = ""
    
    @Published var categoryList: [SelectTalentModel] = []
    @Published var selectedCateory: SelectTalentModel? = nil
    @Published var category: String = ""
    
    @Published var addCategory: String = ""

    @Published var isSideBarOpened: Bool = false
    
    @Published var errorMsg: String = ""
    @Published var showError: Bool = false
    
    @Published var categoryOperation: CategoryOperations? = nil
    
    @Published var alertMsg: String = ""
    @Published var showAlert: Bool = false
    @Published var alertType: CategoryViewAlertType? = nil
}

// MARK: - Functions
extension CategoryViewModel {
    /// `open` sidemenu
    func openSideMenu() -> Void {
        self.isSideBarOpened.toggle()
    }
    
    /// `opens` delete confirmation alert
    func openDeleteCategoryConfirmation(category: SelectTalentModel) -> Void {
        self.selectedCateory = category
        
        self.categoryOperation = .delete
        self.alertMsg = "Are you sure you want to delete this category?"
        self.alertType = .deleteConfirmation
        self.showAlert = true
    }
    
    /// `validations` for `update` category
    func updateCategoryValidations() -> Bool {
        guard let category = self.selectedCateory else {
            self.alertMsg = "Please enter the category name."
            self.alertType = .validation
            self.showAlert = true
            
            return false
        }
        
        if category.category.isEmpty {
            self.alertMsg = "Please enter the category name."
            self.alertType = .validation
            self.showAlert = true
            
            return false
        } else {
            self.alertMsg = ""
            self.alertType = nil
            self.showAlert = false
            
            return true
        }
    }
    
    /// `edit` button click
    func btnEditClicked(category: SelectTalentModel, operation: CategoryOperations) -> Void {
        self.selectedCateory = operation == .edit ? category : nil
        self.category = operation == .edit ? category.category : ""
        self.categoryOperation = operation
    }
    
    /// `api function` for `add` category
    func addCategoryApi() -> Void {
        self.categoryOperation = .add
        self.addCategory = self.searchedCategory
        
        self.createUpdateDeleteCategory {
            self.getCategoryList()
        }
    }
    
    /// `api function` for `update` category
    func updateCategoryApi() -> Void {
        self.categoryOperation = .edit
        
        if self.updateCategoryValidations() {
            self.createUpdateDeleteCategory {
                self.getCategoryList()
            }
        }
    }
    
    /// `api function` for `delete` category
    func deleteCategoryApi() -> Void {
        self.categoryOperation = .delete
        
        self.createUpdateDeleteCategory {
            self.getCategoryList()
        }
    }

    /// `clears` the state
    func clearState() -> Void {
        self.searchedCategory = ""
        self.selectedCateory = nil
        self.category = ""
        self.isSideBarOpened = false
        self.errorMsg = ""
        self.showError = false
        self.categoryOperation = nil
        self.alertMsg = ""
        self.showAlert = false
        self.alertType = nil
    }
}

// MARK: - API Calls
extension CategoryViewModel {
    /// `api call` for get category list
    func getCategoryList(showLoader: Bool = true) {
        SelectTalentModel.GetCategoryList(showLoader: showLoader, withSuccess: { response in
            if response.count > 0 {
                self.clearState()

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
    
    /// `api call` for for create, update ot delete the category
    func createUpdateDeleteCategory(completion: @escaping () -> Void) -> Void {
        var params = [String: Any]()

        if self.categoryOperation == .add {
            params = [
                CRUDCategoryModel.category_id.rawValue: "",
                CRUDCategoryModel.category.rawValue: self.addCategory,
                CRUDCategoryModel.category_flag.rawValue: "1",
            ]
        } else if self.categoryOperation == .edit {
            params = [
                CRUDCategoryModel.category_id.rawValue: self.selectedCateory?.categoryId ?? 0,
                CRUDCategoryModel.category.rawValue: self.category,
                CRUDCategoryModel.category_flag.rawValue: "2",
            ]
        } else if self.categoryOperation == .delete {
            params = [
                CRUDCategoryModel.category_id.rawValue: self.selectedCateory?.categoryId ?? 0,
                CRUDCategoryModel.category.rawValue: self.selectedCateory?.category ?? "",
                CRUDCategoryModel.category_flag.rawValue: "3",
            ]
        }

        SelectTalentModel.createUpdateDeleteCategory(param: params, success: {
            self.clearState()

            completion()
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }
}
