//
//  CommonProfileTextField.swift
//  WhosNext
//
//  Created by differenz195 on 14/10/22.
//

import SwiftUI

struct CommonEditProfileTextField: View {
    // MARK: - Variables
    var placeholderText: String = ""
    @Binding var text: String
    
    var focusState: FocusState<CommonTextFieldFocusState?>.Binding
    @Binding var currentFocus: CommonTextFieldFocusState

    var onCommit: () -> Void

    var body: some View {
        VStack {
            TextField(self.placeholderText , text: self.$text, onCommit: self.onCommit)
                .focused(self.focusState, equals: self.$currentFocus.wrappedValue)
                .padding(.leading, 10)
                .autocapitalization(.none)
                .frame(width: ScreenSize.SCREEN_WIDTH, height: 40, alignment: .leading)
                .background(Color.appSnippetsColor)
                .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._16FontSize))
        }
    }
}

/* // MARK: - Previews
struct CommonEditProfileTextField_Previews: PreviewProvider {
    static var previews: some View {
        CommonEditProfileTextField(text: .constant("Hello"))
    }
} */
