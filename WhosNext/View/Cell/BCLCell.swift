//
//  BCLCell.swift
//  WhosNext
//
//  Created by differenz195 on 28/10/22.
//

import SwiftUI

struct BCLCell: View {
    
    @StateObject var commentVM: CommentViewModel = CommentViewModel()
    @StateObject var sendToVM: SendToViewModel = SendToViewModel()
    
    @State var isLike: Bool = false
    
    var body: some View {
        
        VStack{
            Group{
                NavigationLink(destination: CommentsView(), isActive: $commentVM.moveToComment, label: {})
                NavigationLink(destination: SendToView(), isActive: $sendToVM.moveToShare, label: {})
            }
            HStack{
                
                Text("Created By")
                    .font(.custom(Constant.FontStyle.Heavy.rawValue, size: Constant.FontSize._16FontSize))
                ZStack{
                    Circle()
                        .fill(.orange)
                        .overlay(GeometryReader {
                            let side = sqrt($0.size.width * $0.size.width / 2)
                            VStack {
                                Rectangle().foregroundColor(.clear)
                                    .frame(width: side, height: side)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .resizable()
                                            .foregroundColor(.black)
                                        
                                    )
                                
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        })
                        .frame(width: 25, height: 30)
                }
                Text("Testing")
                    .font(.custom(Constant.FontStyle.Heavy.rawValue, size: Constant.FontSize._16FontSize))
                
                Spacer()
                
                Text("1313 days")
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._14FontSize))
            }.padding(.horizontal, 5)
            
            Image(IdentifiableKeys.ImageName.kNature)
                .resizable()
                .frame(height: 250)
    
                
                HStack(spacing: 20){

                    Button(action: {
                        self.isLike.toggle()

                    }) {
                        Image(isLike ? IdentifiableKeys.ImageName.kRibbonSelected : IdentifiableKeys.ImageName.kRibbon)
                    }

                    Button(action: {
                        
                        self.commentVM.onBtnComment_Click()
                    }) {
                        Image(IdentifiableKeys.ImageName.kMikepink)
                            .frame(width: 14, height: 14)
                    }.padding(.trailing, 10)

                    Button(action: {

                        self.sendToVM.onBtnShare_Click()
                    }) {
                        Image(IdentifiableKeys.ImageName.kSharepink)
                            .frame(width: 14, height: 14)

                    }.padding(.trailing, 10)

                    Spacer()

                    Button(action: {
//                        self.isMoreBtnSheet = true
                    }) {
                        Image(IdentifiableKeys.ImageName.kDotpink)
                            .frame(width: 14, height: 14)

                    }
                }
                .padding(.horizontal, 10)

           Spacer()
        }
    }
}

struct BCLCell_Previews: PreviewProvider {
    static var previews: some View {
        BCLCell()
    }
}
