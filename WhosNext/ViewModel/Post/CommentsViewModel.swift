//
//  CommentsViewModel.swift
//  WhosNext
//
//  Created by differenz240 on 21/11/22.
//

import SwiftUI

class CommentsViewModel: ObservableObject {
    // MARK: - Variables
    @Published var postId: String = ""

    @Published var commentsModel: CommentsModel? = nil
    @Published var commentText: String = ""

    @Published var validationMsg: String = ""
    @Published var showValidationAlert: Bool = false

    @Published var errorMsg = ""
    @Published var showError = false
}

// MARK: - Functions
extension CommentsViewModel {
    func validations() -> Bool {
        if self.commentText.trimWhiteSpace.isEmpty {
            self.validationMsg = "Please enter comment."
            self.showValidationAlert = true
            
            return false
        } else {
            self.validationMsg = ""
            self.showValidationAlert = false
            
            return true
        }
    }
    
    /// `get the index` from the list
    func getIndex(comment: CommentsData) -> Int {
        guard let model = self.commentsModel else { return 0 }
        
        return model.data.firstIndex(where: { $0.commentID == comment.commentID }) ?? 0
    }
}

// MARK: - API Calls
extension CommentsViewModel {
    /// `api call` for comments list
    func getCommentsList() -> Void {
        let params = [CommentsModelKeys.post_id.rawValue: self.postId] as [String: Any]
        
        CommentsModel.getCommentsList(params: params, success: { response, message -> Void in
            self.commentsModel = response
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }
    
    /// `api call` for comment on post
    func postComment() -> Void {
        if self.validations() {
            let params = [
                CommentsModelKeys.post_id.rawValue: self.postId,
                CommentsModelKeys.post_comment.rawValue: self.commentText
            ] as [String: Any]
            
            CommentsModel.postComment(params: params, success: {
                DispatchQueue.main.async {
                    self.getCommentsList()
                    self.commentText = ""
                }
            }, failure: { error -> Void in
                self.errorMsg = error
                self.showError = true
                
                Alert.show(title: "", message: error)
            })
        }
    }
    
    /// `api call` for delete the comment
    func deleteComment(comment: CommentsData) -> Void {
        let params = [CommentsModelKeys.comment_id.rawValue: "\(comment.commentID)"] as [String: Any]

        CommentsModel.deleteComment(params: params, success: {
            DispatchQueue.main.async {
                self.getCommentsList()
            }
        }, failure: { error -> Void in
            self.errorMsg = error
            self.showError = true
            
            Alert.show(title: "", message: error)
        })
    }
}
