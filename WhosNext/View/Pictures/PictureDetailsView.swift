//
//  PictureDetailsView.swift
//  WhosNext
//
//  Created by differenz240 on 08/11/22.
//

import SwiftUI

struct PictureDetailsView: View {
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @StateObject private var postVM: PostViewModel = PostViewModel()
    
    var postId: String?
    var postType: Int?
    
    var body: some View {
        VStack {
            MediaCell(isVideo: self.postType == 2, postId: self.postId)
                .environmentObject(self.postVM)
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: HStack {
                    Button {
                        self.presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(IdentifiableKeys.ImageName.kBackArrowBlack)
                    }
                    
                    Text(IdentifiableKeys.NavigationbarTitles.kPost)
                        .font(.custom(Constant.FontStyle.Heavy.rawValue, size: Constant.FontSize._28FontSize))
                })
        }
    }
}

// MARK: - Previews
struct PictureDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        PictureDetailsView()
    }
}
