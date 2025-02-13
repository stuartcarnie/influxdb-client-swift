//
// IsOnboarding.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation


public struct IsOnboarding: Codable {

    /** True means that the influxdb instance has NOT had initial setup; false means that the database has been setup. */
    public var allowed: Bool?

    public init(allowed: Bool? = nil) {
        self.allowed = allowed
    }

}

