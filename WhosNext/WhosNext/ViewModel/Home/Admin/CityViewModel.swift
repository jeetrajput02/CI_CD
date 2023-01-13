//
//  CityViewModel.swift
//  WhosNext
//
//  Created by differenz240 on 17/11/22.
//

import SwiftUI

enum CityOperations { case add, edit, delete, clear }
enum CityViewAlertType { case validation, deleteConfirmation }

enum CRUDCityModel: String { case city_id, city, city_flag }

class CityViewModel: ObservableObject {
    @Published var cityModel: CityModel? = nil

    @Published var searchedCity: String = ""

    @Published var selectedCity: CityData? = nil
    @Published var city: String = ""
    
    @Published var addCity: String = ""
    
    @Published var isSideBarOpened: Bool = false
    
    @Published var errorMsg: String = ""
    @Published var showError: Bool = false

    @Published var cityOperation: CityOperations? = nil

    @Published var alertMsg: String = ""
    @Published var showAlert: Bool = false
    @Published var alertType: CityViewAlertType? = nil
}

// MARK: - Functions
extension CityViewModel {
    /// `open` sidemenu
    func openSideMenu() -> Void {
        self.isSideBarOpened.toggle()
    }
    
    /// `opens` delete confirmation alert
    func openDeleteCityConfirmation(city: CityData) -> Void {
        self.selectedCity = city
        
        self.cityOperation = .delete
        self.alertMsg = "Are you sure you want to delete this city?"
        self.alertType = .deleteConfirmation
        self.showAlert = true
    }
    
    /// `validations` for `update` city
    func updateCityValidations() -> Bool {
        guard let city = self.selectedCity else {
            self.alertMsg = "Please enter the city name."
            self.alertType = .validation
            self.showAlert = true
            
            return false
        }
        
        if city.city.isEmpty {
            self.alertMsg = "Please enter the city name."
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
    func btnEditClicked(city: CityData, operation: CityOperations) -> Void {
        self.selectedCity = operation == .edit ? city : nil
        self.city = operation == .edit ? city.city : ""
        self.cityOperation = operation
    }
    
    /// `api function` for `add` city
    func addCityApi() -> Void {
        self.cityOperation = .add
        self.addCity = self.searchedCity

        self.createUpdateDeleteCity {
            self.getCities()
        }
    }
    
    /// `api function` for `update` city
    func updateCityApi() -> Void {
        self.cityOperation = .edit
        
        if self.updateCityValidations() {
            self.createUpdateDeleteCity {
                self.getCities()
            }
        }
    }
    
    /// `api function` for `delete` city
    func deleteCityApi() -> Void {
        self.cityOperation = .delete
        
        self.createUpdateDeleteCity {
            self.getCities()
        }
    }
    
    /// `clears` the state
    func clearState() -> Void {
        self.searchedCity = ""
        self.selectedCity = nil
        self.city = ""
        self.addCity = ""
        self.isSideBarOpened = false
        self.errorMsg = ""
        self.showError = false
        self.cityOperation = nil
        self.alertMsg = ""
        self.showAlert = false
        self.alertType = nil
    }
}

// MARK: - API Calls
extension CityViewModel {
    /// `api call` for get the cities
    func getCities() -> Void {
        CityModel.getCities(success: { cityModel, message -> Void in
            self.clearState()

            self.cityModel = cityModel
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }
    
    /// `api call` for create, update ot delete the city
    func createUpdateDeleteCity(completion: @escaping () -> Void) -> Void {
        var params = [String: Any]()

        if self.cityOperation == .add {
            params = [
                CRUDCityModel.city_id.rawValue: "",
                CRUDCityModel.city.rawValue: self.addCity,
                CRUDCityModel.city_flag.rawValue: "1",
            ]
        } else if self.cityOperation == .edit {
            params = [
                CRUDCityModel.city_id.rawValue: self.selectedCity?.cityID ?? 0,
                CRUDCityModel.city.rawValue: self.city,
                CRUDCityModel.city_flag.rawValue: "2",
            ]
        } else if self.cityOperation == .delete {
            params = [
                CRUDCityModel.city_id.rawValue: self.selectedCity?.cityID ?? 0,
                CRUDCityModel.city.rawValue: self.selectedCity?.city ?? "",
                CRUDCityModel.city_flag.rawValue: "3",
            ]
        }

        CityModel.createUpdateDeleteCity(param: params, success: {
            self.clearState()

            completion()
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }
}
