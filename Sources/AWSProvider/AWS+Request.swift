//
//  Kaitse+Request.swift
//  
//
//  Created by Alexander Gavrikov on 22.09.2022.
//

import Vapor
import SotoCore

public extension Request {
    var aws: AWS {
        .init(request: self)
    }

    struct AWS {
        var client: AWSClient {
            return request.application.aws.client
        }

        let request: Request
    }
}
