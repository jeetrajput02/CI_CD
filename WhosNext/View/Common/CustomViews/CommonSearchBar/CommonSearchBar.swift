//
//  CommonSearchBar.swift
//  WhosNext
//
//  Created by differenz195 on 30/09/22.
//

import SwiftUI

struct CommonSearchBar: View {
    
    var placeholderText: String
    var onChange : () -> Void
    var onCommit : () -> Void
    
    @Binding var searchText: String
    
    var body: some View {
        
        let binding = Binding<String>(get: {
            self.searchText
        }, set: {
            self.searchText = $0
            onChange()
        })
        
        HStack(spacing: 1) {
            
            Button(action: {
                
            }, label: {
                Image(IdentifiableKeys.ImageName.kSearch)
                    .padding(.leading, 20)
            })
            
            TextField(placeholderText, text: binding, onCommit: {
                onCommit()
            })
                .font(.custom(Constant.FontStyle.Regular.rawValue, size: Constant.FontSize._14FontSize))
                .foregroundColor(Color.white)
            
                .background(Color.gray)
                .padding()
            
        }
        .frame(height: 50)
        .background(Color.black)
        .cornerRadius(0)
    }
}

//
//struct CommonSearchBar_Previews: PreviewProvider {
//    static var previews: some View {
//        CommonSearchBar(onChange: {}, onCommit: {}, searchText:)
//    }
//}
