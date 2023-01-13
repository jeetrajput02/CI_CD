//
//  NotificationCell.swift
//  WhosNext
//
//  Created by differenz195 on 13/10/22.
//

import SwiftUI

struct NotificationCell: View {

    private let imageSize: CGFloat = 45

    var body: some View {
        HStack {
            
            Image(IdentifiableKeys.ImageName.kAvatar)
                .resizable()
                .frame(width: imageSize, height: imageSize)
                .cornerRadius(25)
            
            VStack(alignment: .leading){
                Text("Johny")
                
                Text("started following you.")
                
            }.font(.custom(Constant.FontStyle.Medium
                .rawValue, size: Constant.FontSize._14FontSize))
            Spacer()
            VStack(alignment: .trailing, spacing: 1){
                
                Text("501")
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._14FontSize))
                Button(action: {
                    print("select Edit profile")

                }, label: {
                    Text("FOLLOWING")
                        .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._10FontSize))
                        .foregroundColor(Color.black)
                })
            
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .foregroundColor(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.black)
                )
               
            }
            .padding(.trailing,15)
            
            
        }
        
        RoundedRectangle(cornerRadius: 0)
            .frame(height: 1)
            .foregroundColor(Color.CustomColor.AppSnippetsColor)
            // .padding(.leading, 5)
    }
}

struct NotificationCell_Previews: PreviewProvider {
    static var previews: some View {
        NotificationCell()
    }
}
