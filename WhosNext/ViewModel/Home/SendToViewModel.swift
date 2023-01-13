//
//  SendToViewModel.swift
//  WhosNext
//
//  Created by differenz195 on 20/10/22.
//

import Foundation
public class SendToViewModel: ObservableObject {
    
    @Published var navigationLink: String? = nil
    @Published var moveToShare: Bool = false
    
    
    func onBtnShare_Click() {
        self.moveToShare = true
    }
    
}
