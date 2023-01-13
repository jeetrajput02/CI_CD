//
//  MenuCell.swift
//  WhosNext
//
//  Created by differenz195 on 03/10/22.
//

import SwiftUI

struct MenuCell: View {
    var iconTitle: String
    var isChangeColor: Bool

    @State  var scale = 1.0
    @State var isAnimating: Bool = true

    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                HStack {
                    if self.isChangeColor {
                        Text(self.iconTitle)
                            .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._18FontSize))
                            .foregroundColor(Color.pink)
                            .scaleEffect(self.scale)
                            .animation(.linear(duration: 1.0).repeatForever(autoreverses: true), value: self.scale)
                            .onAppear {
                                self.scale = self.scale == 1 ? 0.8 : 1
                            }
                        
                        Image(IdentifiableKeys.ImageName.kRibbonSelected)
                            .resizable()
                            .frame(width: 18, height: 18, alignment: .center)
                    } else {
                        Text(self.iconTitle)
                            .frame(height: 20, alignment: .center)
                            .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._18FontSize))
                            .foregroundColor(Color("darkUniColor"))
                            .scaleEffect(self.scale)
                            .animation(.linear(duration: 01).repeatForever(autoreverses: true), value: self.scale)
                            .onAppear {
                                self.scale = self.scale == 1 ? 0.8 : 1
                            }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}



