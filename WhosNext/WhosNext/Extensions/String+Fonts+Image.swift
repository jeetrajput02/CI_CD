//
//  StringExt.swift
//  WhosNext
//
//  Created by Pooja Gandhi on 12/07/22.
//

import SwiftUI

//MARK: - String
extension String {
    public var trimWhiteSpace: String {
        get {
            return self.trimmingCharacters(in: .whitespaces)
        }
    }
    
    var toNumber: Double {
        return Double(self) ?? 0
    }
    
    //emoji
    func withoutEmoji() -> String {
        return self.filter({!($0.isEmoji)})
    }
    
    /**
     This method is used to validate password field.
     - Returns: Return boolen value to indicate password is valid or not
     */
    func isValidPassword() -> Bool {
        // Length be 6 characters minimum.
        guard self.count >= 6 else {
            return false
        }
        return true
    }
    
    /// checks that the `email` is valid or not
    var isValidEmailAddress: Bool {
        get {
            var returnValue = true
            let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
            
            do {
                let regex = try NSRegularExpression(pattern: emailRegEx)
                let nsString = self as NSString
                let results = regex.matches(in: self, range: NSRange(location: 0, length: nsString.length))
                
                if results.count == 0 {
                    returnValue = false
                }
                
            } catch let error as NSError {
                print("invalid regex: \(error.localizedDescription)")
                returnValue = false
            }
            
            return  returnValue
        }
    }
}

//MARK: - Font
extension Font {
    static func setFont(style: Constant.FontStyle = .Regular, size: CGFloat = 15) -> Font {
        return .custom(style.rawValue, size: size)
    }
}


//MARK: - Image
extension Image {
    
    func setImage(url: URL) -> Self {
        if let data = try? Data(contentsOf: url) {
            return Image(uiImage: UIImage(data: data)!)
        } else {
            return self
        }
    }
}

//MARK: - Color
extension Color {
    struct CustomColor {
        
        
        static let AppLabelColor               = Color(#colorLiteral(red: 0.6823529412, green: 0.6941176471, blue: 0.7058823529, alpha: 1))   //#AEB1B4
        static let AppDropdownColor            = Color(#colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 1))   //#555555
        static let AppSnippetsColor            = Color(#colorLiteral(red: 0.9450980392, green: 0.9450980392, blue: 0.9450980392, alpha: 1))   //#F1F1F1
        static let AppBCLColor                 = Color(#colorLiteral(red: 1, green: 0.4, blue: 0.6, alpha: 1))   //#FF6699
        static let AppGreyColor                = Color(#colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1))   //#F5F5F5
        
    }
}

//MARK: - Charcter
extension Character {
    
    var isEmoji: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        return scalar.properties.isEmoji && (scalar.value > 0x238C || unicodeScalars.count > 1)
    }
}

// MARK: - Binding
extension Binding where Value: Equatable {
    init(_ source: Binding<Value?>, replacingNilWith nilProxy: Value) {
        self.init(
            get: { source.wrappedValue ?? nilProxy },
            set: { newValue in
                if newValue == nilProxy {
                    source.wrappedValue = nil
                }
                else {
                    source.wrappedValue = newValue
                }
        })
    }
}

// MARK: - Date Extensions
extension Date {
    
    func toMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    
    func toString(dateFormat format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: self)
    }
}
