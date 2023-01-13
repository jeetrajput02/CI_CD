//
//  PullToRefresh.swift
//  WhosNext
//
//  Created by differenz195 on 11/10/22.
//
import SwiftUI

struct PullToRefresh: View {
    var coordinateSpaceName: String
    var onRefresh: () -> Void
    
    @State var needRefresh: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            if (geo.frame(in: .named(coordinateSpaceName)).midY > 10) {
                Spacer()
                    .onAppear {
                        self.needRefresh = true
                        print("*********Pull Up ******")
                    }
            } else if (geo.frame(in: .named(coordinateSpaceName)).maxY < 10) {
                Spacer()
                    .onAppear {
                        if self.needRefresh {
                            self.needRefresh = false
                          
                            print("*********Pull Down ******")
                            self.onRefresh()
                        }
                    }
            }

            HStack {
                Spacer()

                if self.needRefresh {
                    ProgressView()
                } else {
                    Text("")
                }

                Spacer()
            }
        }
        .padding(.top, -80)
    }
}

// MARK: - Previews
struct PullToRefresh_Previews: PreviewProvider {
    static var previews: some View {
        PullToRefresh(coordinateSpaceName: "", onRefresh: {})
    }
}
