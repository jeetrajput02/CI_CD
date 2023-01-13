//
//  CommentViewModel.swift
//  WhosNext
//
//  Created by differenz195 on 11/10/22.
//

import Foundation

public class CommentViewModel: ObservableObject {
    
    @Published var navigationLink: String? = nil
    @Published var moveToComment: Bool = false
    
    //MARK: - Buttons Action

    func onBtnComment_Click() {
        self.moveToComment = true
    }
    
}
