//
//  Application+Pinpoint.swift
//  
//
//  Created by Alexander Gavrikov on 14.01.2023.
//

import Vapor
import SotoPinpoint
import struct GraphQL.GraphQLError

public struct PPClient {
    struct ConfigurationKey: StorageKey {
        typealias Value = PPClientConfiguration
    }
    struct ClientKey: StorageKey {
        typealias Value = AWSClient
    }
    struct PinpointKey: StorageKey {
        typealias Value = Pinpoint
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
    public var configuration: PPClientConfiguration? {
        get {
            application.storage[ConfigurationKey.self]
        }
        nonmutating set {
            application.storage[ConfigurationKey.self] = newValue
        }
    }
    public var pinpoint: Pinpoint {
        get {
            guard let pinpoint = self.application.storage[PinpointKey.self] else {
                fatalError("Pinpoint not setup")
            }
            return pinpoint
        }
        nonmutating set {
            self.application.storage[PinpointKey.self] = newValue
        }
    }
    
    
    init(_ app: Application) {
        self.application = app
        
        guard let accessKey = Environment.get("AWS_ACCESS_KEY_ID"),
              let secretKey = Environment.get("AWS_SECRET_ACCESS_KEY") else {
            fatalError("AWS Credentials Missing")
        }
        
        let applicationId = Environment.get("PP_APP_ID")
        
        self.aws = .init(credentialProvider: .static(accessKeyId: accessKey,
                                                     secretAccessKey: secretKey),
                         httpClientProvider: .shared(self.application.http.client.shared),
                         logger: self.application.logger)
        self.pinpoint = .init(client: self.aws, region: .eucentral1)
        self.configuration = .init(appId: applicationId)
    }
    
    public func sendOtp(to phoneNumber: String, refid: String) async throws {
        let _ = try await pinpoint.sendOTPMessage(.init(applicationId: self.configuration!.appId!, sendOTPMessageRequestParameters: .init(brandName: "Legeferenda", channel: "SMS", destinationIdentity: phoneNumber, originationIdentity: "LEGEFERENDA", referenceId: refid)))
    }
    
    public func verifyOtp(_ otp: String, to phoneNumber: String, refid: String) async throws -> Bool {
        let resp = try await pinpoint.verifyOTPMessage(.init(applicationId: self.configuration!.appId!, verifyOTPMessageRequestParameters: .init(destinationIdentity: phoneNumber, otp: otp, referenceId: refid)))
        return resp.verificationResponse.valid ?? false
    }
}

extension Application {
    public var ppClient: PPClient { .init(self) }
}

extension Request {
    public var ppClient: PPClient { .init(self.application) }
}
