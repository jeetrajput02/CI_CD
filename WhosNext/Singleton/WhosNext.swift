//
//  WhosNext.swift
//  WhosNext
//
//  Created by Pooja Gandhi on 26/09/22.
//

import Foundation

class WhosNext: NSObject {
    /// `shared instance`
    static let shared: WhosNext = WhosNext()
    
    var isFromNotification: Bool = false
    var notificationType: Int = 0
    var postId: Int = 0
    var postType: Int = 0
    var postSubType: Int = 0
    var postVisibility: Int = 0
}
