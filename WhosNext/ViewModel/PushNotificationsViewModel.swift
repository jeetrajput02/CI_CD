//
//  PushNotificationsViewModel.swift
//  WhosNext
//
//  Created by differenz240 on 11/01/23.
//

import Foundation

class PushNotificationsViewModel: ObservableObject {
    @Published var moveToPictureDetails: Bool = false
    @Published var moveToComments: Bool = false
    @Published var moveToNotifications: Bool = false
    @Published var moveToFollowRequest: Bool = false
}
