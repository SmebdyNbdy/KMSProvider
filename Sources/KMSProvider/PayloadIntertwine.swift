//
//  PayloadIntertwine.swift
//  
//
//  Created by Alexander Gavrikov on 22.11.2022.
//

import Vapor
import JWT

public enum ITRole: String, Codable {
    case mfgod, admin, basic
}

public enum ITEntity: String, Codable {
    case ladu, kaitse, kirjutusmasina
}

public struct PayloadIntertwine: JWTPayload {
    public enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case expiration = "exp"
        case role = "rol"
        case source = "src"
        case target = "trg"
    }
    
    public let subject: SubjectClaim
    public var expiration: ExpirationClaim
    public var role: ITRole
    public var source: ITEntity
    public var target: ITEntity
    
    public func getValidRole(targetCheck: ITEntity) -> ITRole? {
        guard let _ = try? self.expiration.verifyNotExpired() else {
            return nil
        }
        guard targetCheck == target else {
            return nil
        }
        return role
    }
    
    public func verify(using signer: JWTKit.JWTSigner) throws {
        try self.expiration.verifyNotExpired()
    }
    
    public init(role: ITRole, source: ITEntity, target: ITEntity) {
        self.subject = .init(value: "intertwine-auth")
        self.expiration = .init(value: Date.now.advanced(by: 3600.0))
        self.role = role
        self.source = source
        self.target = target
    }
}

