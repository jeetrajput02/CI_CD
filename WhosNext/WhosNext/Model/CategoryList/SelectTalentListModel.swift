//
//  SelectTalentModel.swift
//  WhosNext
//
//  Created by differenz195 on 08/11/22.
//

import Foundation

enum selectTalentModelKey {
    static let categoryId  = "category_id"
    static let category    = "category"
}

struct SelectTalentModel: Codable, Equatable, Hashable {
    var categoryId: Int
    var category: String
    
    init(Dict: [String:Any]) {
        self.categoryId = Dict[selectTalentModelKey.categoryId] as? Int ?? 0
        self.category = Dict[selectTalentModelKey.category] as? String ?? ""
    }
}

// MARK: - API Calls
extension SelectTalentModel {
    /// `api call` for get category list
    static func GetCategoryList(showLoader: Bool = true, withSuccess: @escaping (_ categoryList: [SelectTalentModel]) -> Void, withFailure: @escaping (_ error: String, _ isAuth: Bool) -> Void) {
        if showLoader {
            Indicator.show()
        }
        
        APIManager.makeRequest(with: Constant.ServerAPI.kGetCategory, method: .get, parameter: nil, success: { response in
            let dict = response as? [String:Any] ?? [:]
            let isSuccess = dict[APIManagerKey.IsSuccess] as? Bool ?? false
            _ = dict[APIManagerKey.Message] as? String ?? ""
            let _ = dict[APIManagerKey.StatusCode] as? Int ?? 0
            let apiDictData = dict[APIManagerKey.Data] as? [[String:Any]] ?? []
            
            if isSuccess {
                let category = apiDictData.compactMap(SelectTalentModel.init)
                withSuccess(category)
            }
        } , failure: { error, errorcode, isAuth in
            if showLoader {
                Indicator.hide()
            }
            
            withFailure(error, isAuth)
        } , connectionFailed: { error in
            if showLoader {
                Indicator.hide()
            }
            
            withFailure(error, false)
        })
    }
    
    /// `api call` for for create, update ot delete the category
    static func createUpdateDeleteCategory(param: [String: Any], success: @escaping () -> Void, failure: @escaping (String) -> Void) -> Void {
        Indicator.show()

        APIManager.makeRequest(with: Constant.ServerAPI.kCreateUpdateDeleteCategory, method: .post, parameter: param, success: { response -> Void in
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

