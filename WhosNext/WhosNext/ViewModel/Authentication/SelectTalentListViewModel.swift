//
//  SelectTalentListViewModel.swift
//  WhosNext
//
//  Created by differenz195 on 30/09/22.
//

import Foundation
import SwiftUI


public class SelectTalentListViewModel: ObservableObject {

    @Published var isDone: Bool = false
    @Published var tempValue : [String] = []
    @Published var totalCount : Int = 0
    @Published var categoryList : [SelectTalentModel] = []

}

extension SelectTalentListViewModel {
    
    //get category list
    func getCategoryList(showLoader:Bool = true, onSuccess: @escaping () -> () , onFailuer: @escaping () -> ()) {
        
        SelectTalentModel.GetCategoryList(showLoader: showLoader, withSuccess: { response in
            
            if response.count > 0 {
                self.categoryList = response
                Indicator.hide()
                
            } else {
                Alert.show(message: "No Data Found.")
            }
            onSuccess()
        },  withFailure: { error, isAuth in
        
            if showLoader {
                Indicator.hide()
            }
            onFailuer()
        })
    }
  
}
