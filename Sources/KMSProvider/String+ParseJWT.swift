//
//  File.swift
//  
//
//  Created by Alexander Gavrikov on 19.11.2022.
//

import struct GraphQL.GraphQLError

extension String {
    func parseJWT() throws -> (String, String, String) {
        let parts = self.split(separator: ".")
        guard parts.count == 3 else {
            throw GraphQLError(KMSError.badToken)
        }
        return (String(parts[0]).urlDecodedBase64(),
                String(parts[1]).urlDecodedBase64(),
                String(parts[2]).urlDecodedBase64())
    }
}
