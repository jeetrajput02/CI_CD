//
//  CustomTextField.swift
//  WhosNext
//
//  Created by differenz195 on 27/09/22.

import SwiftUI

enum CommonTextFieldFocusState: Hashable {
    case username
    case password, confirmPassword, currentPassword, newPassword
    case email, confirmEmail
    case firstName, lastName
    case otp
    case website1, website2, website3, website4, website5
    case addName
}

struct CommonTextField: View {
    // MARK: - Variables
    var placeholderText: String = ""
    var isSecuredField = false    
    
    @Binding var text: String
    @State private var hidePass: Bool = true
    @State var backgroundColor: Color = Color.black
    @State var foregroundColor: Color = Color.white
    
    var focusState: FocusState<CommonTextFieldFocusState?>.Binding
    @Binding var currentFocus: CommonTextFieldFocusState
    
    var onCommit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            HStack(alignment : .center) {
                ZStack {
                    if self.isSecuredField && self.hidePass {
                        SecureField(self.placeholderText, text: self.$text, onCommit: self.onCommit)
                            .focused(self.focusState, equals: self.$currentFocus.wrappedValue)
                            .multilineTextAlignment(.center)
                            .font(.custom(Constant.FontStyle.Regular.rawValue, size: Constant.FontSize._14FontSize))
                            .foregroundColor(Color.myDarkCustomColor)
                    } else {
                        TextField(self.placeholderText, text: self.$text, onCommit: self.onCommit)
                            .focused(self.focusState, equals: self.$currentFocus.wrappedValue)
                            .autocapitalization(.none)
                            .multilineTextAlignment(.center)
                            .font(.custom(Constant.FontStyle.Regular.rawValue, size: Constant.FontSize._14FontSize))
                            .foregroundColor(Color.myDarkCustomColor)
                    }
                }
                .padding(.all, 16)
                .disableAutocorrection(true)
//                .foregroundColor(backgroundColor)
//                .background(Color.white)
                
                Spacer()
                
                if self.isSecuredField == true {
                    if self.text != "" {
                        Button (action: {
                            self.text = ""
                        }) {
                            Image(IdentifiableKeys.ImageName.kCancel)
                                .frame(width: 32, height: 32)
                                .padding(.trailing)
                        }
                    }
                } else {
                    if self.text != "" {
                        Button (action: {
                            self.text = ""
                        }) {
                            Image(IdentifiableKeys.ImageName.kCancel)
                                .frame(width: 32, height: 32)
                                .padding(.trailing)
                        }
                    }
                }
            }
            .frame(height: 50)
            .background(RoundedRectangle(cornerRadius: 5))
//            .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
//            .foregroundColor(Color(UIColor(named: "uniColor")!))
            .foregroundColor(Color.myCustomColor)
            
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.myDarkCustomColor))
        }
    }
}

//MARK: -


struct UITextViewWrapper: UIViewRepresentable {
    typealias UIViewType = UITextView

    @Binding var text: String?
    @Binding var calculatedHeight: CGFloat
    var onDone: (() -> Void)?

    func makeUIView(context: UIViewRepresentableContext<UITextViewWrapper>) -> UITextView {
        let textField = UITextView()
        textField.delegate = context.coordinator

        textField.isEditable = true
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.isSelectable = true
        textField.isUserInteractionEnabled = true
        textField.isScrollEnabled = false
        textField.backgroundColor = UIColor.clear
        if nil != onDone {
            textField.returnKeyType = .done
        }

        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textField
    }

    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<UITextViewWrapper>) {
        if uiView.text != self.text {
            uiView.text = self.text
        }
        if uiView.window != nil, !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        }
        UITextViewWrapper.recalculateHeight(view: uiView, result: $calculatedHeight)
    }

    fileprivate static func recalculateHeight(view: UIView, result: Binding<CGFloat>) {
        let newSize = view.sizeThatFits(CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        if result.wrappedValue != newSize.height {
            DispatchQueue.main.async {
                result.wrappedValue = 200 // !! must be called asynchronously
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text,height: $calculatedHeight, onDone: onDone)
        
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String?>
        var calculatedHeight: Binding<CGFloat>
        var onDone: (() -> Void)?

        init(text: Binding<String?>, height: Binding<CGFloat>, onDone: (() -> Void)? = nil) {
            self.text = text
            self.calculatedHeight = height
            self.onDone = onDone
        }

        func textViewDidChange(_ uiView: UITextView) {
            text.wrappedValue = uiView.text
            UITextViewWrapper.recalculateHeight(view: uiView, result: calculatedHeight)
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if let onDone = self.onDone, text == "\n" {
                textView.resignFirstResponder()
                onDone()
                return false
            }
            return true
        }
    }

}

//struct MultilineTextField: View {
//
//    private var placeholder: String
//    private var onCommit: (() -> Void)?
//
//    @Binding private var text: String
//    private var internalText: Binding<String> {
//        Binding<String>(get: { self.text } ) {
//            self.text = $0
//            self.showingPlaceholder = $0.isEmpty
//        }
//    }
//
//    @State private var dynamicHeight: CGFloat = 100
//    @State private var showingPlaceholder = false
//
//    init (_ placeholder: String = "", text: Binding<String>, onCommit: (() -> Void)? = nil) {
//        self.placeholder = placeholder
//        self.onCommit = onCommit
//        self._text = text
//        self._showingPlaceholder = State<Bool>(initialValue: self.text.isEmpty)
//    }
//
//    var body: some View {
//        UITextViewWrapper(text: self.internalText, calculatedHeight: $dynamicHeight, onDone: onCommit)
//            .frame(minHeight: dynamicHeight, maxHeight: dynamicHeight)
//            .background(placeholderView, alignment: .topLeading)
//    }
//
//    var placeholderView: some View {
//        Group {
//            if showingPlaceholder {
//                Text(placeholder).foregroundColor(.gray)
//                    .padding(.leading, 4)
//                    .padding(.top, 8)
//            }
//        }
//    }
//}
