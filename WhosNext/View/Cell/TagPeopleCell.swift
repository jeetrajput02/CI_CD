//
//  TagPeopleCell.swift
//  WhosNext
//
//  Created by differenz195 on 02/11/22.
//

import SwiftUI

struct TagPeopleCell: View {
    
    //MARK: - Variables
    @State private var isSelected = false
    let index: Int
    var fullName: String
    var name: String
    var action : ( _ isSelected : Bool,  _ fullName : String,  _ name : String) -> ()
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Button(action: {
                
                self.isSelected.toggle()
                self.action(self.isSelected, self.fullName, self.name)
                
            }, label: {
                VStack(alignment: .leading) {
                    
                    Text(fullName)
                        .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._18FontSize))
                        .foregroundColor(.white)
                        .padding(.leading, 40)
                    
                    Text(name)
                        .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
                        .foregroundColor(.white)
                        .padding(.leading, 40)
                    
                    RoundedRectangle(cornerRadius: 0)
                        .frame(height: 1)
                        .foregroundColor(Color.CustomColor.AppSnippetsColor)
                }
            })
        }
    }
}

struct TagPeopleCell_Previews: PreviewProvider {
    static var previews: some View {
        TagPeopleCell(index: 1, fullName: "test1", name: "test 2", action: {isSelected,fullName,name in })
    }
}
