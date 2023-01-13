//
//  CustomTabBarView.swift
//  WhosNext
//
//  Created by differenz195 on 17/10/22.
//

import SwiftUI

//MARK: - CustomTabbar View
struct CustomTabBarView: View {
    
    @Binding var currentTab: Int
    @Namespace var namespace
    
    var tabBarOptions: [String]
    var body: some View {
        
        VStack(spacing: 0){
            HStack(spacing: 20) {
                
                ForEach(Array(zip(self.tabBarOptions.indices,
                                  self.tabBarOptions)),
                        id: \.0,
                        content: {
                    index, name in
                    TabBarItem(currentTab: self.$currentTab,
                               namespace: namespace.self,
                               tabBarItemName: name,
                               tab: index)
                    
                })
                
            }
            .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._18FontSize))
    //        .padding(.horizontal)
            .frame(height: 30)
     
        }
    }
    
    struct CustomTabBarView_Previews: PreviewProvider {
        static var previews: some View {
            CustomTabBarView(currentTab: .constant(1), tabBarOptions: ["MEDIA", "FEED"])
        }
    }
}

//MARK: - Tabbar Items
struct TabBarItem: View {
    
    @Binding var currentTab: Int
    let namespace: Namespace.ID
    
    var tabBarItemName: String
    var tab: Int
    
    var body: some View {
        Button {
            self.currentTab = tab
        } label: {
            VStack(spacing: 4) {
//                Spacer()
                Text(tabBarItemName)
                if currentTab == tab {
                    Color.myDarkCustomColor
                        .frame(height: 2)
                        .matchedGeometryEffect(id: "underline",
                                               in: namespace,
                                               properties: .frame)
                } else {
                    Color.clear.frame(height: 2)
                }
            }
            .animation(.spring(), value: self.currentTab)
        }
        .buttonStyle(.plain)
    }
}
