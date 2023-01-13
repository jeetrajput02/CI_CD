//
//  AnimatedLabel.swift
//  WhosNext
//
//  Created by Pooja Gandhi on 27/09/22.
//

import SwiftUI

struct AnimatedLabel: View {
    
    //MARK: Variables
    @State var image: UIImage
    @State var backDegree = 0.0
    @State var isFlipped = false
    
    let durationAndDelay : CGFloat = 0.3
    
    //MARK: Flip Card Function
    func flipCard () {
        isFlipped = !isFlipped
        if isFlipped {
            withAnimation(.linear(duration: durationAndDelay)) {
                backDegree = 10
            }
        } else {
            withAnimation(.linear(duration: durationAndDelay).delay(durationAndDelay)){
                backDegree = 0
            }
        }
    }
    
    var foreverAnimation: Animation {
        Animation.linear(duration: 1.0)
            .repeatForever(autoreverses: true)
    }
    
    //MARK: View Body
    var body: some View {
        Image(uiImage: image)
            .rotation3DEffect(Angle(degrees: backDegree), axis: (x: 0, y: 1, z: 0))
            .animation(foreverAnimation)
            .onAppear {
                flipCard()
            }
    }
}
