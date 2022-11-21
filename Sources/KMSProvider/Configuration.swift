//
//  Configuration.swift
//  
//
//  Created by Alexander Gavrikov on 18.11.2022.
//

import Vapor

public struct KMSClientConfiguration {
    public let kid: String?
    
    public init(keyId: String? = nil) {
        self.kid = keyId
    }
}
