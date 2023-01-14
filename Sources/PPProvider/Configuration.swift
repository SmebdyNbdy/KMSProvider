//
//  Configuration.swift
//
//
//  Created by Alexander Gavrikov on 18.11.2022.
//

import Vapor

public struct PPClientConfiguration {
    public let appId: String?
    
    public init(appId: String? = nil) {
        self.appId = appId
    }
}
