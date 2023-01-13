//
//  WhosNextApp.swift
//  WhosNext
//
//  Created by Pooja Gandhi on 27/09/22.
//

import SwiftUI
import UIKit

@main
struct WhosNextApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate: AppDelegate

    @StateObject var viewRouter = ViewRouter()
    @StateObject var registerVM: RegisterViewModel = RegisterViewModel()
    
    @State private var alert: AlertData = AlertData.empty
    @State private var showAlert: Bool = false
    @State private var customeAlert: AnyView = AnyView(VStack { Text("No View") })
    @State private var showCustomeAlert: Bool = false
    @State private var showIndicator: Bool = false

    init() {
        UITextField.appearance().tintColor = UIColor(named: "darkUniColor")
        UITextView.appearance().tintColor = UIColor(named: "darkUniColor")

        UIScrollView.appearance().bounces = true
    }

    var body: some Scene {
        WindowGroup {
            AppRouteView()
                .environmentObject(self.registerVM)
                .environmentObject(self.viewRouter)
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .onReceive(NotificationCenter.default.publisher(for: .showIndicator)) { result in
                    self.showIndicator = result.object as! Bool
                }
                .activityIndicator(show: self.showIndicator)
                .onReceive(NotificationCenter.default.publisher(for: .showAlert)) { result in
                    if let alert = result.object as? AlertData {
                        self.alert = alert
                        self.showAlert = true
                    }
                }
                .alert(isPresented: self.$showAlert) {
                    if self.alert.isLogOut {
                        return Alert(title: Text(self.alert.title), message: Text(self.alert.message), primaryButton: self.alert.primaryButton, secondaryButton: self.alert.secondaryButton)
                    } else {
                        if self.alert.message == "Authentication token has expired." {
                            return Alert(
                                title: Text(self.alert.title), message: Text(self.alert.message),
                                dismissButton: .default(Text("OK"), action: {
                                    DispatchQueue.main.async {
                                        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.kLoginUser)
                                        viewRouter.currentView = .Login
                                        NavigationUtil.popToRootView()
                                    }
                                })
                            )
                        } else {
                            return Alert(title: Text(self.alert.title), message: Text(self.alert.message), dismissButton: self.alert.dismissButton)
                        }
                    }
                }
        }
    }
}
