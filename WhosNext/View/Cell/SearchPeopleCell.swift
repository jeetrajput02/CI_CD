//
//  SearchPeopleCell.swift
//  WhosNext
//
//  Created by differenz195 on 21/10/22.
//

import SwiftUI

struct SearchPeopleCell: View {
    
    private let imageSize: CGFloat = 45
    
    var body: some View {
        
        HStack{
            
            Image(IdentifiableKeys.ImageName.kAvatar)
                .resizable()
                .frame(width: imageSize, height: imageSize)
                .cornerRadius(25)
            
            VStack(alignment: .leading){
                Text("Monil Lad")
                    .font(.custom(Constant.FontStyle.Medium
                        .rawValue, size: Constant.FontSize._18FontSize))
                
                Text("Monil")
                    .font(.custom(Constant.FontStyle.TMedium
                        .rawValue, size: Constant.FontSize._14FontSize))
                
            }
            Spacer()
            
        }
        .padding(.leading, 5)
    }
}

struct SearchPeopleCell_Previews: PreviewProvider {
    static var previews: some View {
        SearchPeopleCell()
    }
}
