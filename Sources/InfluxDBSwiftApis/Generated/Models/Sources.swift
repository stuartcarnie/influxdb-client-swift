//
// Sources.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation


public struct Sources: Codable {

    public var links: UsersLinks?
    public var sources: [Source]?

    public init(links: UsersLinks? = nil, sources: [Source]? = nil) {
        self.links = links
        self.sources = sources
    }

}

