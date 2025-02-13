//
// OrganizationLinks.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation


public struct OrganizationLinks: Codable {

    /** URI of resource. */
    public var _self: String?
    /** URI of resource. */
    public var members: String?
    /** URI of resource. */
    public var owners: String?
    /** URI of resource. */
    public var labels: String?
    /** URI of resource. */
    public var secrets: String?
    /** URI of resource. */
    public var buckets: String?
    /** URI of resource. */
    public var tasks: String?
    /** URI of resource. */
    public var dashboards: String?

    public init(_self: String? = nil, members: String? = nil, owners: String? = nil, labels: String? = nil, secrets: String? = nil, buckets: String? = nil, tasks: String? = nil, dashboards: String? = nil) {
        self._self = _self
        self.members = members
        self.owners = owners
        self.labels = labels
        self.secrets = secrets
        self.buckets = buckets
        self.tasks = tasks
        self.dashboards = dashboards
    }

    public enum CodingKeys: String, CodingKey, CaseIterable { 
        case _self = "self"
        case members
        case owners
        case labels
        case secrets
        case buckets
        case tasks
        case dashboards
    }

}

