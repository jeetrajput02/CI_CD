//
//  CheckMarkCell.swift
//  WhosNext
//
//  Created by differenz195 on 02/11/22.
//

import SwiftUI

struct CheckMarkCell: View {
    
    //MARK: - Variables
    @State private var isSelected = false
    var isCheckmark = true
    var text: String
    let index: Int
    var action : ( _ isSelected : Bool,  _ text : String) -> ()
    
    var body: some View {
        HStack{
            
            Button(action: {
              
                self.isSelected.toggle()
                self.action(self.isSelected, self.text)
                print("select dropdown menu Btn")

            }, label: {
                HStack{
                    if isCheckmark{
                        Image(isSelected ? IdentifiableKeys.ImageName.kCircleFill : IdentifiableKeys.ImageName.kCircleBlank)
                            .resizable()
                            .frame(width: 20, height: 20, alignment: .center)
                    }
                    Text(text)
                        .foregroundColor(.black)
                }
            })
    
        }
    }
}

//struct CheckMarkCell_Previews: PreviewProvider {
//    static var previews: some View {
//        CheckMarkCell(text: "test", index: 1, action: {isSelected,text in })
//    }
//}
