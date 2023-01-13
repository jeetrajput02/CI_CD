//
//  PostsViewModel.swift
//  WhosNext
//
//  Created by differenz195 on 17/10/22.
//

import Foundation

public class PostsViewModel: ObservableObject {
    @Published var navigationLink: String? = nil
    @Published var moveToPosts: Bool = false
    
    // MARK: - Buttons Action
    func onBtnPosts_Click() {
        self.moveToPosts = true
    }
}
