//
//  AppDelegate.swift
//  WhosNext
//
//  Created by Pooja Gandhi on 12/07/22.
//
import UIKit
import IQKeyboardManagerSwift

class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.portrait

    let notificationCenter = UNUserNotificationCenter.current()
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.configureNotifications(application: application)

        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = false

        return true
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")

        /// `with swizzling disabled you must set the APNs token here.`
        UserDefaults.standard.set(deviceToken.map { String(format: "%02.2hhx", $0) }.joined(), forKey: UserDefaultsKey.kDeviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("error while registering notifications: \(error.localizedDescription)")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(.newData)

        guard let notificationDict = userInfo["aps"] as? [AnyHashable: Any] else { return }
        guard let badge = notificationDict["badge"] as? Int else { return }

        UIApplication.shared.applicationIconBadgeNumber = badge
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("notification response userInfo: \(response.notification.request.content.userInfo)")

        guard let notificationDict = response.notification.request.content.userInfo["aps"] as? [AnyHashable: Any] else { return }
        WhosNext.shared.isFromNotification = true

        guard let notificationType = notificationDict["notification_type"] as? Int, let badge = notificationDict["badge"] as? Int,
                let postId = notificationDict["post_id"] as? Int, let postType = notificationDict["post_type"] as? Int,
                let postSubType = notificationDict["post_sub_type"] as? Int, let postVisibility = notificationDict["post_visibility"] as? Int else { return }

        UIApplication.shared.applicationIconBadgeNumber = badge

        WhosNext.shared.notificationType = notificationType
        WhosNext.shared.postId = postId
        WhosNext.shared.postType = postType
        WhosNext.shared.postSubType = postSubType
        WhosNext.shared.postVisibility = postVisibility

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
            self.handleNotificationTap()
        })
        
        completionHandler()
    }
}

// MARK: - Functions
extension AppDelegate {
    /// `configure notifications`
    func configureNotifications(application: UIApplication) -> Void {
        self.notificationCenter.delegate = self
        
        self.notificationCenter.requestAuthorization(options: [.sound, .alert, .badge]) { granted, error -> Void in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    /// `handle notification tap`
    func handleNotificationTap() -> Void {
        switch WhosNext.shared.notificationType {
            case NotificationType.simplePostCreated.rawValue: // 1
                NotificationCenter.default.post(name: .moveToPictureDetails, object: nil)
                break

            case NotificationType.groupVideoPostCreated.rawValue: // 2
                NotificationCenter.default.post(name: .moveToPictureDetails, object: nil)
                break

            case NotificationType.taggedInPost.rawValue: // 3
                NotificationCenter.default.post(name: .moveToPictureDetails, object: nil)
                break

            case NotificationType.taggedInGroupVideo.rawValue: // 4
                NotificationCenter.default.post(name: WhosNext.shared.postVisibility == 1 ? .moveToPictureDetails : .moveToNotifications, object: nil)
                break

            case NotificationType.commentOnPost.rawValue: // 6
                NotificationCenter.default.post(name: .moveToComments, object: nil)
                break

            case NotificationType.likePost.rawValue: // 7
                NotificationCenter.default.post(name: .moveToPictureDetails, object: nil)
                break

            case NotificationType.sendFollowingRequest.rawValue: // 8
                NotificationCenter.default.post(name: .moveToFollowRequest, object: nil)
                break

            default:
                break
        }
    }
}
