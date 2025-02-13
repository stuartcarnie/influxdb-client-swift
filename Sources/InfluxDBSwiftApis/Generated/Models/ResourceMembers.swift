//
// ResourceMembers.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation


public struct ResourceMembers: Codable {

    public var links: UsersLinks?
    public var users: [ResourceMember]?

    public init(links: UsersLinks? = nil, users: [ResourceMember]? = nil) {
        self.links = links
        self.users = users
    }

}

