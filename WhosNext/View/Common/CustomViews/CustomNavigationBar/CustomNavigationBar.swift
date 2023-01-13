//
//  CustomNavigationBar.swift
//  WhosNext
//
//  Created by differenz195 on 01/11/22.
//

import SwiftUI

struct CustomNavigationBar: View {
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    var title = ""
    var isVisibleNotification = false
    var isVisibleReferesh = false
    var isVisibleBackBtn = false
    var isVisibleMenuBtn = false
    
    let backButtonAction: () -> Void
    let menuButtonAction: () -> Void
    let refereshAction: () -> Void
    
    var body: some View {
        VStack {
            HStack {}
                .frame(width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT * 0.030)
                .background(Color.CustomColor.AppBCLColor)
            
            HStack {
                HStack {
                    if self.isVisibleBackBtn {
                        Button(action: {
                            self.backButtonAction()
                        }) {
                            Image(colorScheme == .dark ? IdentifiableKeys.ImageName.kBackarrowwhite : IdentifiableKeys.ImageName.kBackArrowBlack)
                        }
                        .padding(.leading, 10)
                        // .padding(.top, 20)
                    }
                    
                    if self.isVisibleMenuBtn {
                        Button(action: {
                            self.menuButtonAction()
                        }) {
                            Image(IdentifiableKeys.ImageName.kMenuBar)
                        }
                        .padding(.leading, 10)
                        // .padding(.top, 20)
                    }
                }
                
                Text(self.title)
                    .font(.custom(Constant.FontStyle.Heavy.rawValue, size: Constant.FontSize._24FontSize))
                    .foregroundColor(Color.myDarkCustomColor)
                    // .padding(.top, 20)
                
                Spacer()

                HStack {
                    if self.isVisibleNotification {
                        Button(action: {}) {
                            Image(IdentifiableKeys.ImageName.kNotification)
                                .padding(.trailing, 10)
                                // .padding(.top, 20)
                        }
                    }

                    if self.isVisibleReferesh {
                        Button(action: {
                            self.refereshAction()
                        }) {
                            Image(IdentifiableKeys.ImageName.kBlackRefresh)
                                .padding(.trailing, 10)
                                // .padding(.top, 20)
                        }
                    }
                }
            }
            .frame(width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT * 0.070)
            .background(Color.CustomColor.AppBCLColor)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Previews
struct CustomNavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomNavigationBar(title: "Navigation Title", isVisibleNotification: true, isVisibleReferesh: true, isVisibleBackBtn: false, isVisibleMenuBtn: true ,backButtonAction: {}, menuButtonAction: {}, refereshAction: {})
    }
}
