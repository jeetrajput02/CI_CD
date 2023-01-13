//
//  LinearProgressBar.swift
//  WhosNext
//
//  Created by differenz240 on 10/01/23.
//

import SwiftUI

struct LinearProgressBar: View {
    var title: String
    @Binding var progress: Float

    var body: some View {
        VStack(alignment: .leading) {
            Text(self.title)
                .fontWeight(.bold)
                .padding(.horizontal, 8.0)
                .padding(.top, 12.0)
                .frame(alignment: .center)
            
            ProgressView(value: self.progress, total: 100.0)
                .tint(.myDarkCustomColor)
        }
        .background(Color.appSnippetsColor)
        .frame(height: 50.0)
    }
}

// MARK: - Previews
struct LinearProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            LinearProgressBar(title: "Loading...", progress: .constant(10.0))
        }
    }
}
