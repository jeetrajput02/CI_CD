//
//  ViewRouter.swift
//  WhosNext
//
//  Created by Pooja Gandhi on 26/09/22.
//

import Foundation
import UIKit

class ViewRouter: ObservableObject {
    @Published var currentView: AppView = UserDefaults.standard.bool(forKey: "isLogin") ? .Home : .Login
}

enum AppView {
    case Login, Home, Empty
}
