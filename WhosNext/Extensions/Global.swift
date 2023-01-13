//
//  Global.swift
//  WhosNext
//
//  Created by Created by Pooja Gandhi on 26/09/22.
//

import UIKit
import AVKit

// MARK: - Data Extnsions
extension Data {
    var prettyPrintedJSONString: String? {
        /// NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) else { return nil }
        return prettyPrintedString
    }
}

// MARK: - AVPlayer Extensions
extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
