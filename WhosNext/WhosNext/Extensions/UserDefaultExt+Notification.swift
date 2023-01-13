//
//  UserDefaultExt.swift
//  WhosNext
//
//  Created by Pooja Gandhi on 12/07/22.
//

import SwiftUI

//MARK: - User Defaults
extension UserDefaults {
    // To Set Data in UserDefault
    static func setData<T: Codable>(_ data: T, _ key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(data) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: key)
        }
    }
    
    // To get Data from UserDefault
    static func getData<T: Codable>(_ key: String, data: T.Type) -> T? {
        let defaults = UserDefaults.standard
        if let savedPerson = defaults.object(forKey: key) as? Data {
            let decoder = JSONDecoder()
            let loadedPerson = try? decoder.decode(data, from: savedPerson)
            return loadedPerson
        } else {
            print(key)
            return nil
            
        }
    }
    
    func removeAll() {
        let domain = Bundle.main.bundleIdentifier!
        removePersistentDomain(forName: domain)
        synchronize()
    }
}

// MARK: - Notification Name
extension Notification.Name {
    static let showAlert                    = Notification.Name("showAlert")
    static let showIndicator                = Notification.Name("showIndicator")
    static let showCustomAlert              = Notification.Name("showCustomAlert")
    static let showLogoutAlert              = Notification.Name("showLogoutAlert")
    
    static let playVideo                    = Notification.Name("playVideo")
    static let pauseVideo                   = Notification.Name("pauseVideo")
    static let mutePlayer                   = Notification.Name("mutePlayer")
    static let unMutePlayer                 = Notification.Name("unMutePlayer")
    
    /// `from notifications`
    static let moveToPictureDetails         = Notification.Name("moveToPictureDetails")
    static let moveToComments               = Notification.Name("moveToComments")
    static let moveToNotifications          = Notification.Name("moveToNotifications")
    static let moveToFollowRequest          = Notification.Name("moveToFollowRequest")
}


extension Alert {
    static func showPopUp(withAlert alert: AnyView) {
        NotificationCenter.default.post(name: .showCustomAlert, object: alert)
    }
    
    static func show(title: String = "", message: String = "", isLogOut: Bool = false, viewRouter: ViewRouter = ViewRouter()) {
        NotificationCenter.default.post(name: .showAlert, object: AlertData(title: title, message: message, isLogOut: isLogOut, viewRouter: viewRouter))
    }
}

// MARK: -  Pop to Root View Navigate
struct NavigationUtil {
    static func popToRootView() {
        self.findNavigationController(viewController: UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController)?.popToRootViewController(animated: true)
    }
    
    static func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
        guard let viewController = viewController else {
            return nil
        }
        
        if let navigationController = viewController as? UINavigationController {
            return navigationController
        }
        
        for childViewController in viewController.children {
            return findNavigationController(viewController: childViewController)
        }
        
        return nil
    }
}

// MARK: - AlertData
class AlertData {
    static var empty = AlertData(title: "Sample", message: "Empty", isLogOut: false, viewRouter: ViewRouter())

    @StateObject var sidebarVM: SidebarViewModel = SidebarViewModel()
    
    var title: String
    var message: String
    var isLogOut: Bool
    var viewRouter: ViewRouter
    
    private(set) var dismissButton: Alert.Button = .default(Text("OK"))
    private(set) var secondaryButton: Alert.Button = .default(Text("Yes"))
    private(set) var primaryButton: Alert.Button = .default(Text("No"))
    
    init(title: String, message: String, isLogOut: Bool, viewRouter: ViewRouter) {
        self.title = title
        self.message = message
        self.isLogOut = isLogOut
        self.viewRouter = viewRouter
        
        
        if isLogOut {
            self.dismissButton = .default(Text("OK")) {
                DispatchQueue.main.async {
                    UserDefaults.standard.removeObject(forKey: UserDefaultsKey.kLoginUser)
                    viewRouter.currentView = .Login
                    NavigationUtil.popToRootView()
                }
            }
        }
        
        self.secondaryButton = .default(Text("Yes")) {
            DispatchQueue.main.async {
                UserDefaults.standard.removeObject(forKey: UserDefaultsKey.kLoginUser)
                viewRouter.currentView = .Login
                NavigationUtil.popToRootView()
            }
        }
    }
}

// MARK: - UIImage Orientastion
extension UIImage {
    /// get `orientatiuon image` to upload
    func imageOrientation() -> UIImage {
        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }

        var transform: CGAffineTransform = CGAffineTransform.identity

        switch self.imageOrientation {
            case UIImage.Orientation.down, UIImage.Orientation.downMirrored:
                transform = transform.translatedBy(x: self.size.width, y: self.size.height)
                transform = transform.rotated(by: CGFloat(Double.pi))
                break
            case UIImage.Orientation.left, UIImage.Orientation.leftMirrored:
                transform = transform.translatedBy(x: self.size.width, y: 0)
                transform = transform.rotated(by: CGFloat(Double.pi / 2))
                break
            case UIImage.Orientation.right, UIImage.Orientation.rightMirrored:
                transform = transform.translatedBy(x: 0, y: self.size.height)
                transform = transform.rotated(by: CGFloat(-Double.pi / 2))
                break
            case UIImage.Orientation.up, UIImage.Orientation.upMirrored:
                break
            default:
                break
        }

        switch self.imageOrientation {
            case UIImage.Orientation.upMirrored, UIImage.Orientation.downMirrored:
                transform.translatedBy(x: self.size.width, y: 0)
                transform.scaledBy(x: -1, y: 1)
                break
            case UIImage.Orientation.leftMirrored, UIImage.Orientation.rightMirrored:
                transform.translatedBy(x: self.size.height, y: 0)
                transform.scaledBy(x: -1, y: 1)
            case UIImage.Orientation.up, UIImage.Orientation.down, UIImage.Orientation.left, UIImage.Orientation.right:
                break
            default:
                break
        }

        let ctx: CGContext = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: (self.cgImage)!.bitsPerComponent, bytesPerRow: 0, space: (self.cgImage)!.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        ctx.concatenate(transform)

        switch self.imageOrientation {
            case UIImage.Orientation.left, UIImage.Orientation.leftMirrored, UIImage.Orientation.right, UIImage.Orientation.rightMirrored:
                ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width))
                break
            default:
                ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
                break
        }

        let cgimg: CGImage = ctx.makeImage()!
        let img: UIImage = UIImage(cgImage: cgimg)

        return img
    }
}

// MARK: - ImageShadow
struct InnerShadow: ViewModifier {
    var color: Color = .gray
    var radius: CGFloat = 0.1
    
    private var colors: [Color] {
        [self.color.opacity(0.75), self.color.opacity(0.0), .clear]
    }
    
    func body(content: Content) -> some View {
        GeometryReader { geo in
            content
                .overlay(LinearGradient(gradient: Gradient(colors: self.colors), startPoint: .top, endPoint: .bottom)
                    .frame(height: self.radius * self.minSide(geo)),
                         alignment: .top)
                /* .overlay(LinearGradient(gradient: Gradient(colors: self.colors), startPoint: .bottom, endPoint: .top)
                    .frame(height: self.radius * self.minSide(geo)),
                         alignment: .bottom)
                .overlay(LinearGradient(gradient: Gradient(colors: self.colors), startPoint: .leading, endPoint: .trailing)
                    .frame(width: self.radius * self.minSide(geo)),
                         alignment: .leading)
                .overlay(LinearGradient(gradient: Gradient(colors: self.colors), startPoint: .trailing, endPoint: .leading)
                    .frame(width: self.radius * self.minSide(geo)),
                         alignment: .trailing) */
        }
    }
    
    func minSide(_ geo: GeometryProxy) -> CGFloat {
        CGFloat(3) * min(geo.size.width, geo.size.height) / 2
    }
}
