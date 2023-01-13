//
//  ProgressHUD.swift
//  WhosNext
//
//  Created by Pooja Gandhi on 12/07/22.
//


import SwiftUI
struct ActivityIndicator: View {
    
    @Binding var shouldAnimate: Bool
    
    var body: some View {
        MyCustomAlert(show: $shouldAnimate) {
                ProgressView()
                .padding(20)
                .background(Color.secondary.colorInvert())
                .cornerRadius(15)
        }
    }
}
