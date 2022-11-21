//
//  Data+Base64.swift
//  
//
//  Created by Alexander Gavrikov on 18.11.2022.
//

import protocol Foundation.DataProtocol
import struct Foundation.Data

extension UInt8 {
    static var period: UInt8 {
        return Character(".").asciiValue!
    }
}

extension DataProtocol {
    func copyBytes() -> [UInt8] {
        if let array = self.withContiguousStorageIfAvailable({ buffer in
            return [UInt8](buffer)
        }) {
            return array
        } else {
            let buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: self.count)
            self.copyBytes(to: buffer)
            defer { buffer.deallocate() }
            return [UInt8](buffer)
        }
    }
    
    func base64URLDecodedBytes() -> [UInt8] {
        return Data(base64Encoded: Data(self.copyBytes()).base64URLUnescaped())?.copyBytes() ?? []
    }

    func base64URLEncodedBytes() -> [UInt8] {
        return Data(self.copyBytes()).base64EncodedData().base64URLEscaped().copyBytes()
    }
}

extension Data {
    /// Converts base64-url encoded data to a base64 encoded data.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    mutating func base64URLUnescape() {
        for (i, byte) in self.enumerated() {
            switch byte {
            case 0x2D: self[self.index(self.startIndex, offsetBy: i)] = 0x2B
            case 0x5F: self[self.index(self.startIndex, offsetBy: i)] = 0x2F
            default: break
            }
        }
        /// https://stackoverflow.com/questions/43499651/decode-base64url-to-base64-swift
        let padding = count % 4
        if padding > 0 {
            self += Data(repeating: 0x3D, count: 4 - count % 4)
        }
    }

    /// Converts base64 encoded data to a base64-url encoded data.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    mutating func base64URLEscape() {
        for (i, byte) in enumerated() {
            switch byte {
            case 0x2B: self[self.index(self.startIndex, offsetBy: i)] = 0x2D
            case 0x2F: self[self.index(self.startIndex, offsetBy: i)] = 0x5F
            default: break
            }
        }
        self = split(separator: 0x3D).first ?? .init()
    }

    /// Converts base64-url encoded data to a base64 encoded data.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    func base64URLUnescaped() -> Data {
        var data = self
        data.base64URLUnescape()
        return data
    }

    /// Converts base64 encoded data to a base64-url encoded data.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    func base64URLEscaped() -> Data {
        var data = self
        data.base64URLEscape()
        return data
    }
}
