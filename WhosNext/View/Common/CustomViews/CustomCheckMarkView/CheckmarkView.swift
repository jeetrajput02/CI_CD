//
//  CheckmarkView.swift
//  WhosNext
//
//  Created by differenz195 on 03/11/22.
//

import SwiftUI

//MARK: - CheckMark View
struct CheckmarkView: View {
    
    @EnvironmentObject var registerVM: RegisterViewModel
    @State private var showingAlert = false
    @State private var isSelected = false
    var text: String
    var index: Int
    var action : ( _ isSelected : Bool) -> ()
    
    var body: some View {
        
        HStack{
            
            Button(action: {
              
                self.isSelected.toggle()
                self.action(self.isSelected)
                print("select dropdown menu Btn")
                
            }, label: {
                
                Image(isSelected ? IdentifiableKeys.ImageName.kCircleFill : IdentifiableKeys.ImageName.kCircleBlank)
                    .resizable()
                    .frame(width: 20, height: 20, alignment: .center)
                
            })
            
//            Text("WhosNext")
//            ForEach(ListItem.listItem(),  id: \.id ){ row in

                Text(text)

//            }
        }
    }
}

struct CheckmarkView_Previews: PreviewProvider {
    static var previews: some View {
        CheckmarkView(text: "test", index: 1, action: {isSelected in })
    }
}
