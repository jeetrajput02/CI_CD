//
//  AllSnippetsDetailView.swift
//  WhosNext
//
//  Created by differenz104 on 07/12/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct AllSnippetsDetailView: View {
    @State var currentData: HomeSinppetData
    @Environment(\.presentationMode) var presentation: Binding<PresentationMode>
    @Binding var navigateToRoot: Bool 
    
    var body: some View {
        ScrollView {
            VStack {
                HStack{
                    ZStack {
                        Circle()
                            .overlay(
                                GeometryReader {
                                    let side = sqrt($0.size.width * $0.size.width / 2)
                                    VStack {
                                        Rectangle()
                                            .foregroundColor(.clear)
                                            .frame(width: side, height: side)
                                            .overlay(
                                                WebImage(url: URL(string: self.currentData.introductionVideoThumb ?? ""))
                                                    .placeholder(Image(systemName: "person.fill"))
                                                    .resizable()
                                                    .indicator(.activity)
                                                    .clipShape(Circle())
                                                    .frame(width: 30 ,height: 30)
                                            )
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                }
                            )
                            .frame(width: 30, height: 30)
                    }
                    
                    Text(self.currentData.username ?? "")
                        .font(.custom(Constant.FontStyle.Bold.rawValue, size: Constant.FontSize._14FontSize))

                }
                
                WebImage(url: URL(string: self.currentData.snippetThumb!))
                    .placeholder(Image(systemName: "person.fill").resizable())
                    .resizable()
                    .padding(.all ,6)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.6 , alignment: .center)
                    
                    .onTapGesture {
                        self.presentation.wrappedValue.dismiss()
                    }
                
                Text("Tap on image and play again")
                    .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._17FontSize))
                    .padding(.all,10)
                
                
                HStack {
                    Text("SNIPPET DETAILS")
                        .padding(.all , 10)
                        Spacer()
                    
                }
                
                HStack {
                    Text(self.currentData.snippetDetail ?? "")
                        .padding(.leading , 10)
                        .padding(.trailing , 10)

                    Spacer()
                }
                
                
                    
                
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: HStack {
                Button {
                    self.navigateToRoot = false
                } label: {
                    Image(IdentifiableKeys.ImageName.kBackArrowBlack)
                }
                
                Text("Home")
                    .font(.custom(Constant.FontStyle.Heavy.rawValue, size: Constant.FontSize._28FontSize))
            })
        }
    }
}

