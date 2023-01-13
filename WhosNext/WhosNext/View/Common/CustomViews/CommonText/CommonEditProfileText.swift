//
//  CommonEditProfileText.swift
//  WhosNext
//
//  Created by differenz195 on 14/10/22.
//

import SwiftUI

struct CommonEditProfileText: View {
    
    var text: String
    
    var body: some View {
        
        VStack{
            
            Text(text)
                .padding(.leading,10)
                .frame(width: ScreenSize.SCREEN_WIDTH, height: 40, alignment: .leading)
                .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._20FontSize))
        }
    }
}

struct CommonEditProfileText_Previews: PreviewProvider {
    static var previews: some View {
        CommonEditProfileText(text: "hello")
    }
}
