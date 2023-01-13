//
//  SendToView.swift
//  WhosNext
//
//  Created by differenz195 on 20/10/22.
//

import SwiftUI

struct SendToView: View {
    
    var arrMenu = [UserList(id: 0, text: "Actor" ),UserList(id: 1, text: "Automotive"),UserList(id: 2, text: "Animation"),UserList(id: 3, text: "Band"),UserList(id: 4, text: "Basketball"),UserList(id: 5, text: "Catering"),UserList(id: 6, text: "Fashion"),UserList(id: 7, text: "Fitness"),UserList(id: 8, text: "Kitchen / cooking"),UserList(id: 9, text: "Public Figure"),UserList(id: 10, text: "Actress"),UserList(id: 11, text: "Actor" ),UserList(id: 12, text: "Automotive"),UserList(id: 13, text: "Animation"),UserList(id: 14, text: "Band"),UserList(id: 15, text: "Basketball"),UserList(id: 16, text: "Catering"),UserList(id: 17, text: "Fashion"),UserList(id: 18, text: "Fitness"),UserList(id: 19, text: "Kitchen / cooking"),UserList(id: 20, text: "Public Figure"),UserList(id: 21, text: "Actress")]
    
    @State var writeText: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        VStack{
            
            ScrollView(showsIndicators: false){
                
                LazyVStack(alignment: .leading) {
                    
                    ForEach( arrMenu  , id: \.id) { temp in
                        
                        CheckMarkCell(isCheckmark: true, text: temp.text, index: temp.id) { isselect,val  in
                            
                    
                        }

                        RoundedRectangle(cornerRadius: 0)
                            .frame(height: 1)
                            .foregroundColor(Color.CustomColor.AppSnippetsColor)
                        
                    }
                }
                .padding([.horizontal,.top], 10)
                
                
            }
            HStack{
                
                TextField("write a message...", text: $writeText, onCommit: {
                    
                    
                })
                .multilineTextAlignment(.leading)
                .font(.custom(Constant.FontStyle.Regular.rawValue, size: Constant.FontSize._14FontSize))
                .disableAutocorrection(true)
                .foregroundColor(Color.black)
                .background(Color.white)
                .padding(.all, 10)
                
                Spacer()
                
                Button(action: {
            
                    self.writeText = ""
                    print("select dropdown menu Btn")
                    
                }, label: {
                    
                    Image(IdentifiableKeys.ImageName.kSendBtn)
                        .resizable()
                        .background(Color.black)
                        .frame(width: 30, height: 30, alignment: .center)
                    
                })
                .padding(.trailing, 8)
                
            }
            
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.black)
            )
            
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
                                HStack {
            
            Button {
              presentationMode.wrappedValue.dismiss()
            } label: {
                Image(IdentifiableKeys.ImageName.kBackArrowBlack)
            }
            
            Text(IdentifiableKeys.NavigationbarTitles.kSendTo)
                .font(.custom(Constant.FontStyle.Heavy.rawValue, size: Constant.FontSize._28FontSize))
            
        })
        .navigationBarColor(backgroundColor: .white)

    }
}

struct SendToView_Previews: PreviewProvider {
    static var previews: some View {
        SendToView()
    }
}


//MARK: - List items
struct UserList: Identifiable {
    
    var id: Int
    var text: String
    
}
