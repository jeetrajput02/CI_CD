//
//  ImageDetailView.swift
//  WhosNext
//
//  Created by differenz104 on 07/12/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ImageDetailView: View {
    @State private var currentMagnification: CGFloat = 1
    @GestureState private var pinchMagnification: CGFloat = 1
    @State var snippetData: HomeSinppetData
    @State var navigate: Bool = false
    @Binding var navigateToRoot: Bool
    
    var body: some View {
        ZStack {
            NavigationLink("", isActive: self.$navigate) {
                AllSnippetsDetailView(currentData: self.snippetData, navigateToRoot: self.$navigateToRoot)
            }
            
            VStack {
                HStack {
                    Spacer()

                    Button {
                        self.navigate = true
                    } label: {
                        Image(IdentifiableKeys.ImageName.kClose)
                            .resizable()
                    }
                    .frame(width: 22,height: 22,alignment: .trailing)
                    .padding(.trailing , 10)
                }

                Spacer()
                
                WebImage(url: URL(string: self.snippetData.snippetThumb ?? ""))
                    .placeholder(Image(IdentifiableKeys.ImageName.kAppBanner).resizable())
                    .resizable()
                    .scaleEffect(self.currentMagnification * self.pinchMagnification)
                    .gesture(
                        MagnificationGesture()
                            .updating($pinchMagnification, body: { value, state, _ in
                                state = value
                            })
                            .onEnded {
                                if $0 > 2 {
                                    self.currentMagnification = 2.0
                                } else if $0 < 0.5 {
                                    self.currentMagnification = 0.5
                                } else {
                                    self.currentMagnification *= $0
                                }
                            }
                    )
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.6 , alignment: .center)
                
                Spacer()
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}
