//
//  File.swift
//  WhosNext
//
//  Created by Pooja Gandhi on 12/07/22.
//

import SwiftUI
import Foundation

extension View {
    
    func hideNavigationBar(isSideBarMenuOpen: Bool = false) -> some View {
        
        self
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(isSideBarMenuOpen ? true : false)
    }
    
    func showNavigationBar(title : String) -> some View {
        
        self
            .navigationBarHidden(false)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitle(title, displayMode: .inline)
            .font(.setFont(style: .Regular, size: Constant.FontSize._18FontSize))
    }
    
    func customAlert<ContentBox: View>(isShowing: Binding<Bool>,
                                       @ViewBuilder boxContent: @escaping () -> ContentBox) -> some View {
        self.modifier(CustomAlert(isShowing: isShowing, dialogContent: boxContent))
    }
    
    func draggable() -> some View {
        return modifier(DraggableView())
    }
    
    func navigationBarColor(backgroundColor: UIColor?) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor))
    }
    
    func activityIndicator(show: Bool) -> some View {
        self.modifier(ActivityIndicatorExt(show: show))
    }
    
    func innerShadow(color: Color, radius: CGFloat = 0.1) -> some View {
        modifier(InnerShadow(color: color, radius: min(max(0, radius), 1)))
    }
}

// MARK: - Color Extensions
extension Color {
    public static var myCustomColor: Color {
        return Color(UIColor(named: "uniColor")!)
    }

    public static var myDarkCustomColor: Color {
        return Color(UIColor(named: "darkUniColor")!)
    }

    public static var appSnippetsColor: Color {
        return Color(UIColor(named: "appSnippetsColor")!)
    }

    public static var appLoaderColor:Color {
        return Color(UIColor(named: "loaderColor")!)
    }
}
