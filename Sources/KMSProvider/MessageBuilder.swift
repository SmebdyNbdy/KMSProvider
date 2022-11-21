//
//  MessageBuilder.swift
//  
//
//  Created by Alexander Gavrikov on 18.11.2022.
//

import class Foundation.JSONEncoder
import JWT
import JWTKit

struct JWTHeader: Codable {
    var alg: String?
    var typ: String?
    var kid: JWKIdentifier?
}

struct MessageBuilder {
    static func build(_ payload: JWTPayload, kid: String) throws -> String {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .secondsSince1970
        jsonEncoder.dataEncodingStrategy = .base64
        jsonEncoder.keyEncodingStrategy = .useDefaultKeys

        var header = JWTHeader()
        header.kid = JWKIdentifier(string: kid)
        header.typ = "JWT"
        header.alg = "HS256"

        let headerData = try jsonEncoder.encode(header)
        let encodedHeader = headerData.base64String()

        let payloadData = try jsonEncoder.encode(payload)
        let encodedPayload = payloadData.base64String()

        let str = encodedHeader
                + "."
                + encodedPayload
        return str
    }
}
