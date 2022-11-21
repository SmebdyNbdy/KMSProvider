//
//  String+Base64UrlEncoded.swift
//  
//
//  Created by Alexander Gavrikov on 18.11.2022.
//

extension String {
    func urlDecodedBase64() -> String {
        let remainder = self.count % 4
        let toAppend: String
        switch remainder {
        case 2:
            toAppend = "=="
        case 3:
            toAppend = "="
        default:
            toAppend = ""
        }
        var newStr = self + toAppend
        
        newStr = newStr.replacingOccurrences(of: "_", with: "/")
        newStr = newStr.replacingOccurrences(of: "-", with: "+")
        
        return newStr
    }
    func urlEncodedBase64() -> String {
        var newStr = self.replacingOccurrences(of: "=", with: "")
        newStr = newStr.replacingOccurrences(of: "/", with: "_")
        newStr = newStr.replacingOccurrences(of: "+", with: "-")
        
        return newStr
    }
}
