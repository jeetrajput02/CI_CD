//
//  CommonProfileText.swift
//  WhosNext
//
//  Created by differenz195 on 14/10/22.
//

import SwiftUI

struct CommonProfileText: View {
    
    var text: String
    
    var body: some View {
        VStack{
            
            Text(text)
                .padding(.leading,2)
                .frame(width: ScreenSize.SCREEN_WIDTH, height: 40, alignment: .leading)
                .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._20FontSize))
        }
    }
}

struct CommonProfileText_Previews: PreviewProvider {
    static var previews: some View {
        CommonProfileText(text: "testing")
    }
}

