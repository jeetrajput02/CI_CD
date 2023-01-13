//
//  UIResponder.swift
//  WhosNext
//
//  Created by Pooja Gandhi on 13/07/22.
//

import Foundation
import SwiftUI

//returns current first responder
extension UIResponder {

    ///Returns current first responder
    static var currentFirstResponder: UIResponder? {
        _currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(UIResponder.findFirstResponder(_:)), to: nil, from: nil, for: nil)
        return _currentFirstResponder
    }

    private static weak var _currentFirstResponder: UIResponder?

    @objc private func findFirstResponder(_ sender: Any) {
        UIResponder._currentFirstResponder = self
    }
}

extension Bundle {
    
    func decodeJson<T: Decodable>(_ type : T.Type,   fileName: String) -> T {
        
        guard let url = self.url(forResource: fileName, withExtension: nil) else {
            fatalError("Unable to load file!")
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode(type, from: data)
            return jsonData
        }
        catch {
            fatalError("err::\(error)")
        }
    
    }
}
