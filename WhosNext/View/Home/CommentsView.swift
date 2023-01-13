//
//  CommentsView.swift
//  WhosNext
//
//  Created by differenz195 on 11/10/22.
//

import SwiftUI
import UIKit
import IQKeyboardManagerSwift

struct CommentsView: View {
    // MARK: - Variables
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    @StateObject private var commentsVM: CommentsViewModel = CommentsViewModel()
    
    @State private var offset: CGSize = .zero
    var customColor: Color?
    var postId: String?
    
    var body: some View {
        VStack {
            Spacer(minLength: 12.0)
            
            CommentsList(commentsVM: self.commentsVM, customColor: self.customColor)
            CommentsSection(commentsVM: self.commentsVM)
                .padding(.bottom, ScreenSize.SCREEN_HEIGHT > 700.0 ? 0.0 : 10.0)
        }
        .navigationBarColor(backgroundColor: self.customColor != nil ? UIColor(self.customColor!) : UIColor(Color.myCustomColor))
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button {
                        self.presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(IdentifiableKeys.ImageName.kBackArrowBlack)
                    }
                    
                    Text(IdentifiableKeys.NavigationbarTitles.kComments)
                        .font(.custom(Constant.FontStyle.Heavy.rawValue, size: Constant.FontSize._28FontSize))
                }
                
            }
          
        }
        .onDisappear {
            let coloredAppearance = UINavigationBarAppearance()
            coloredAppearance.configureWithTransparentBackground()
            coloredAppearance.backgroundColor = UIColor(Color.myCustomColor)

            UINavigationBar.appearance().standardAppearance = coloredAppearance
            UINavigationBar.appearance().compactAppearance = coloredAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        }
        .alert(isPresented: self.$commentsVM.showValidationAlert) {
            Alert(title: Text(""), message: Text(self.commentsVM.validationMsg), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            self.commentsVM.postId = self.postId ?? ""
            
            DispatchQueue.main.async {
                self.commentsVM.getCommentsList()
            }
        }
        .onAppear {
            IQKeyboardManager.shared.enable = false
        }
        .onDisappear {
            IQKeyboardManager.shared.enable = true
        }
    }
}

// MARK: - Custom Views
private extension CommentsView {
    /// `comments list`
    private struct CommentsList: View {
        @StateObject var commentsVM: CommentsViewModel
        var customColor: Color?

        var body: some View {
            List {
                ForEach(self.commentsVM.commentsModel?.data ?? [], id: \.self) { comment in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(comment.username)
                                .font(.custom(Constant.FontStyle.Bold.rawValue, size: Constant.FontSize._14FontSize))
                                .foregroundColor(self.customColor)
                            Text(comment.postComment)
                                .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._14FontSize))
                        }
                        
                        Spacer()
                        
                        Text(comment.timeDisplayStr)
                            .foregroundColor(.gray)
                            .font(.custom(Constant.FontStyle.Regular.rawValue, size: Constant.FontSize._16FontSize))
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive, action: {
                            self.commentsVM.deleteComment(comment: comment)
                        }, label: {
                            Image(systemName: "trash")
                        })
                    }
                    
                }
            }
            .listStyle(.plain)
        }
    }
    
    /// `comments section with textfield and send button`
    private struct CommentsSection: View {
        @StateObject var commentsVM: CommentsViewModel

        var body: some View {
            HStack {
                TextField("add a comment...", text: self.$commentsVM.commentText)
                    .multilineTextAlignment(.leading)
                    .font(.custom(Constant.FontStyle.Regular.rawValue, size: Constant.FontSize._14FontSize))
                    .disableAutocorrection(true)
                    .foregroundColor(.myDarkCustomColor)
                    .background(Color.myCustomColor)
                    .padding(.all, 10.0)
                
                Spacer()
                
                Button(action: {
                    self.commentsVM.postComment()
                    print("select dropdown menu Btn")
                }, label: {
                    Image(IdentifiableKeys.ImageName.kSendBtn)
                        .resizable()
                        .background(Color.myDarkCustomColor)
                        .frame(width: 30, height: 30, alignment: .center)
                })
                .padding(.trailing, 8.0)
            }
            .overlay(RoundedRectangle(cornerRadius: 5.0).stroke(Color.myDarkCustomColor))
            .padding(.horizontal, 10.0)
        }
    }
}

// MARK: - Previews
struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        CommentsView()
    }
}
