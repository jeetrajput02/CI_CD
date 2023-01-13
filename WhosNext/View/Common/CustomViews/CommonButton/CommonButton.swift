//
//  CommonButton.swift
//  WhosNext
//
//  Created by differenz195 on 27/09/22.
//

import SwiftUI

struct CommonButton: View {
        
    private static let buttonHorizontalMargins: CGFloat = 20
    @State var backgroundColor: Color = Color.black
    @State var foregroundColor: Color = Color.white
    var cornerRadius : CGFloat = 16
    var fontsize : CGFloat =  20
    var fontStyle : Constant.FontStyle = .TMedium
    private let title: String
    private let action: () -> Void
    private let disabled: Bool
    var showImage  : Bool =  false
    
    init(title: String,
         disabled: Bool = false,
         backgroundColor: Color = Color.black,
         foregroundColor: Color = Color.white,
         cornerradius:CGFloat = 5,
         fontSizes : CGFloat =  20,
         fontStyles : Constant.FontStyle = .TMedium,
         showImage : Bool = false,
         action: @escaping () -> Void) {
        
//        self.backgroundColor = backgroundColor
//        self.foregroundColor = foregroundColor
        self.title = title
        self.action = action
        self.disabled = disabled
        self.cornerRadius = cornerradius
        self.fontsize = fontSizes
        self.showImage = showImage
        self.fontStyle = fontStyles
    }
    
    var body: some View {
        
        HStack {
            
            Button(action:self.action) {
                
                HStack(alignment : .center) {
                    
                    
                    
                    Text(self.title)
                        .font(.setFont(style: fontStyle, size: fontsize))
                        .multilineTextAlignment(.center)
                    
                    if showImage {
                      
                        HStack {
                       
                            Image(IdentifiableKeys.ImageName.kDropdown)
                                .resizable()
                            .frame(width: 10, height: 7, alignment: .trailing)
                       
                        }
                        
                    }
                }
                .frame(maxWidth:.infinity)
            }
            .buttonStyle(CommonButtonStyle(backgroundColor: Color.myDarkCustomColor, foregroundColor: Color.myCustomColor, isDisabled: disabled, cornerRadius: cornerRadius, fontsize: fontsize))
            .disabled(self.disabled)
            
        }
        .frame(maxWidth:.infinity)
    }
}

struct CommonButton_Previews: PreviewProvider {
    static var previews: some View {
        CommonButton(title: "LOGIN", action: {})
    }
}
