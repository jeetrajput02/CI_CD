//
//  CityModel.swift
//  WhosNext
//
//  Created by differenz240 on 09/11/22.
//

import Foundation

struct CityModel: Codable, Equatable, Hashable {
    var success: Bool
    var statusCode: Int
    var message: String
    var data: [CityData]
    
    enum CodingKeys: String, CodingKey {
        case success
        case statusCode = "status_code"
        case message, data
    }
}

struct CityData: Codable, Equatable, Hashable {
    var cityID: Int
    var city: String
    
    enum CodingKeys: String, CodingKey {
        case cityID = "city_id"
        case city
    }
}

// MARK: - API Calls
extension CityModel {
    /// `api call` for get the cities
    static func getCities(success: @escaping (CityModel?, String) -> Void, failure: @escaping (String) -> Void) -> Void {
        Indicator.show()
        
        APIManager.makeRequest(with: Constant.ServerAPI.kGetCity, method: .get, parameter: nil, success: { response -> Void in
            Indicator.hide()
            
            guard let json = response as? [String: Any] else { return }
            guard let data = try? JSONSerialization.data(withJSONObject: json) else { return }
            
            do {
                let cityModel = try JSONDecoder().decode(CityModel.self, from: data)
                
                success(cityModel, cityModel.message)
            } catch let error {
                print(error.localizedDescription)
            }
        }, failure: { error, errorCode, isAuth -> Void  in
            Indicator.hide()
            
            failure(error)
        }, connectionFailed: { error -> Void in
            Indicator.hide()
            
            failure(error)
        })
    }
    
    /// `api call` for create, update ot delete the city
    static func createUpdateDeleteCity(param: [String: Any], success: @escaping () -> Void, failure: @escaping (String) -> Void) -> Void {
        Indicator.show()

        APIManager.makeRequest(with: Constant.ServerAPI.kCreateUpdateDeleteCity, method: .post, parameter: param, success: { response -> Void in
            success()
        }, failure: { error, errorCode, isAuth -> Void  in
            Indicator.hide()
            
            failure(error)
        }, connectionFailed: { error -> Void in
            Indicator.hide()
            
            failure(error)
        })
    }
}


