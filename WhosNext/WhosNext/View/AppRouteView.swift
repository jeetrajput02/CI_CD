//
//  AppRouteView.swift
//  WhosNext
//
//  Created by differenz240 on 11/01/23.
//

import SwiftUI

struct AppRouteView: View {
    @EnvironmentObject var viewRouter : ViewRouter
    
    @StateObject var pushNotificationsVM: PushNotificationsViewModel = PushNotificationsViewModel()
    
    @State var showSplash: Bool = true
    
    var body: some View {
        NavigationView {
            ZStack {
                if WhosNext.shared.isFromNotification {
                    Group {
                        NavigationLink(destination: PictureDetailsView(postId: "\(WhosNext.shared.postId)", postType: WhosNext.shared.postType), isActive: self.$pushNotificationsVM.moveToPictureDetails, label: {})
                        NavigationLink(destination: CommentsView(postId: "\(WhosNext.shared.postId)"), isActive: self.$pushNotificationsVM.moveToComments, label: {})
                        NavigationLink(destination: NotificationView(), isActive: self.$pushNotificationsVM.moveToNotifications, label: {})
                        NavigationLink(destination: FollowRequestView(), isActive: self.$pushNotificationsVM.moveToFollowRequest, label: {})
                    }
                }
                
                VStack {
                    if self.showSplash {
                        Image(IdentifiableKeys.ImageName.kAppTitleText)
                            .ignoresSafeArea(.all, edges: .all)
                            .onAppear(perform: {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                                    withAnimation {
                                        self.showSplash = false
                                    }
                                })
                            })
                    } else {
                        
                        if UserDefaults.standard.object(forKey: UserDefaultsKey.kLoginUser) == nil {
                            if self.viewRouter.currentView == .Login {
                                LoginView(viewRouter: self.viewRouter)
                            }
                            else if viewRouter.currentView == .Home {
                                HomeView(viewRouter: self.viewRouter)
                            }
                        }
                        else {
                            HomeView(viewRouter: self.viewRouter)
                        }
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .moveToPictureDetails), perform: { result in
                self.pushNotificationsVM.moveToPictureDetails = true
            })
            .onReceive(NotificationCenter.default.publisher(for: .moveToComments), perform: { result in
                self.pushNotificationsVM.moveToComments = true
            })
            .onReceive(NotificationCenter.default.publisher(for: .moveToNotifications), perform: { result in
                self.pushNotificationsVM.moveToNotifications = true
            })
            .onReceive(NotificationCenter.default.publisher(for: .moveToFollowRequest)) { request in
                self.pushNotificationsVM.moveToFollowRequest = true
            }
        }
        .navigationViewStyle(.stack)
    }
}
