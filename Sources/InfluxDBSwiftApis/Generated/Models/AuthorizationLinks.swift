//
// AuthorizationAllOfLinks.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation


public struct AuthorizationAllOfLinks: Codable {

    /** URI of resource. */
    public var _self: String?
    /** URI of resource. */
    public var user: String?

    public init(_self: String? = nil, user: String? = nil) {
        self._self = _self
        self.user = user
    }

    public enum CodingKeys: String, CodingKey, CaseIterable { 
        case _self = "self"
        case user
    }

}

