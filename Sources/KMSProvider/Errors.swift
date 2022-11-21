//
//  Errors.swift
//  
//
//  Created by Alexander Gavrikov on 18.09.2022.
//

import Pioneer
import GraphQL

public enum KMSError: String, Codable, CaseIterable {
    case unknownError,
         badToken,
         passwordMismatch,
         encodingError,
         awsRequestError,
         kidNotConfigured
}

public extension GraphQLError {
    init(_ kms: KMSError) {
        self.init(message: kms.rawValue)
    }
}
