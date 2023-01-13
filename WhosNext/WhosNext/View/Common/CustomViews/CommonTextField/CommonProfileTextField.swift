//
//  CommonProfileTextField.swift
//  WhosNext
//
//  Created by differenz195 on 17/10/22.
//

import SwiftUI

struct CommonProfileTextField: View {
    
    var placeholderText = ""
    @Binding var text: String
    
    var body: some View {
        VStack{
            
            TextField(placeholderText , text: $text)
                .allowsHitTesting(false)
                .padding(.leading, 5)
                .frame(width: ScreenSize.SCREEN_WIDTH, height: 40, alignment: .leading)
//                .background(Color.CustomColor.AppSnippetsColor)
                .background(Color.appSnippetsColor)
                .foregroundColor(.blue)
                .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize ))
                .onTapGesture {
                    let url = URL.init(string: text)
                    guard let openURL = url, UIApplication.shared.canOpenURL(openURL) else { return }
                    UIApplication.shared.open(openURL)
                }
        }
    }
}

struct CommonProfileTextField_Previews: PreviewProvider {
    static var previews: some View {
        CommonProfileTextField(text: .constant("testing"))
    }
}
