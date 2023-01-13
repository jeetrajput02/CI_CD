//
//  VideoModel.swift
//  WhosNext
//
//  Created by differenz195 on 11/10/22.
//

import Foundation
import AVKit


struct VideoModel: Identifiable {
    
    var id = UUID()
    var player: AVPlayer?
    var name: String
    
}
