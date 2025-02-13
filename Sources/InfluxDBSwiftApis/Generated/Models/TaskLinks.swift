//
// TaskLinks.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation


public struct TaskLinks: Codable {

    /** URI of resource. */
    public var _self: String?
    /** URI of resource. */
    public var owners: String?
    /** URI of resource. */
    public var members: String?
    /** URI of resource. */
    public var runs: String?
    /** URI of resource. */
    public var logs: String?
    /** URI of resource. */
    public var labels: String?

    public init(_self: String? = nil, owners: String? = nil, members: String? = nil, runs: String? = nil, logs: String? = nil, labels: String? = nil) {
        self._self = _self
        self.owners = owners
        self.members = members
        self.runs = runs
        self.logs = logs
        self.labels = labels
    }

    public enum CodingKeys: String, CodingKey, CaseIterable { 
        case _self = "self"
        case owners
        case members
        case runs
        case logs
        case labels
    }

}

