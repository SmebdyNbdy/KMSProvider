//
//  File.swift
//  
//
//  Created by Alexander Gavrikov on 18.11.2022.
//

import Vapor
import JWTKit
import SotoKMS
import struct GraphQL.GraphQLError

public struct KMSClient {
    struct ConfigurationKey: StorageKey {
        typealias Value = KMSClientConfiguration
    }
    struct ClientKey: StorageKey {
        typealias Value = AWSClient
    }
    struct KMSKey: StorageKey {
        typealias Value = KMS
    }
    
    let application: Application
    
    public var aws: AWSClient {
        get {
            guard let client = self.application.storage[ClientKey.self] else {
                fatalError("AWSClient not setup. Use application.aws.client = ...")
            }
            return client
        }
        nonmutating set {
            self.application.storage.set(ClientKey.self, to: newValue) {
                try $0.syncShutdown()
            }
        }
    }
    public var configuration: KMSClientConfiguration? {
        get {
            application.storage[ConfigurationKey.self]
        }
        nonmutating set {
            application.storage[ConfigurationKey.self] = newValue
        }
    }
    public var kms: KMS {
        get {
            guard let kms = self.application.storage[KMSKey.self] else {
                fatalError("KMS not setup")
            }
            return kms
        }
        nonmutating set {
            self.application.storage[KMSKey.self] = newValue
        }
    }
    
    
    init(_ app: Application) {
        self.application = app
        
        guard let accessKey = Environment.get("AWS_ACCESS_KEY_ID"),
              let secretKey = Environment.get("AWS_SECRET_ACCESS_KEY") else {
            fatalError("AWS Credentials Missing")
        }
        
        let signingKey = Environment.get("KMS_KEY_ARN")
        
        self.aws = .init(credentialProvider: .static(accessKeyId: accessKey,
                                                     secretAccessKey: secretKey),
                         httpClientProvider: .shared(self.application.http.client.shared),
                         logger: self.application.logger)
        self.kms = .init(client: self.aws, region: .eunorth1)
        self.configuration = .init(keyId: signingKey)
    }
    
    public func getToken(_ payload: JWTPayload) async throws -> String {
        guard let kid = configuration!.kid else {
            throw GraphQLError(.kidNotConfigured)
        }
        
        guard let message = try? MessageBuilder.build(payload, kid: kid) else {
            throw GraphQLError(.unknownError)
        }
        
        let msg = SHA256.hash(data: Data(message.utf8))
        let request = KMS.GenerateMacRequest(keyId: kid,
                                             macAlgorithm: .hmacSha256,
                                             message: .data(msg.hex.base64Bytes()))
        guard let response = try? await kms.generateMac(request) else {
            throw GraphQLError(.awsRequestError)
        }
        guard let _ = try? aws.syncShutdown() else {
            throw GraphQLError(.unknownError)
        }
        
        guard let encodedMessage = response.mac else {
            throw GraphQLError(.awsRequestError)
        }
        guard let hmac = encodedMessage.decoded() else {
            throw GraphQLError(.unknownError)
        }
        
        let bytes = message + "." + hmac.base64
        return bytes.urlEncodedBase64()
    }
    
    public func verifyToken(_ token: String) async throws -> Data {
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .secondsSince1970
        dec.dataDecodingStrategy = .base64
        dec.keyDecodingStrategy = .useDefaultKeys
        
        let (header, body, signature) = try token.parseJWT()
        guard let headerData = Data(base64Encoded: header),
              let bodyData = Data(base64Encoded: body) else {
            throw GraphQLError(.badToken)
        }
        guard let headerValue = try? dec.decode(JWTHeader.self, from: headerData) else {
            throw GraphQLError(.badToken)
        }
        let messageStr = header + "." + body
        let message = SHA256.hash(data: Data(messageStr.utf8))
        
        let request = KMS.VerifyMacRequest(keyId: headerValue.kid!.string,
                                           mac: .base64(signature),
                                           macAlgorithm: .hmacSha256,
                                           message: .data(message.hex.base64Bytes()))
        guard let response = try? await kms.verifyMac(request) else {
            throw GraphQLError(.badToken)
        }
        let _ = try aws.syncShutdown()
        
        guard let isValid = response.macValid else {
            throw GraphQLError(.badToken)
        }
        guard isValid else {
            throw GraphQLError(.badToken)
        }
        return bodyData
    }
}

extension Application {
    public var kmsClient: KMSClient { .init(self) }
}

extension Request {
    public var kmsClient: KMSClient { .init(self.application) }
}
