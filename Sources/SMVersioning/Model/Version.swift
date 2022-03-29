//
//  Version.swift
//  SMVersioning
//
//  Created by Максим Шаптала on 23.03.2022.
//

import Foundation

struct VersionInfo: Equatable {

    static func == (lhs: VersionInfo, rhs: VersionInfo) -> Bool {
        return lhs.version.raw == rhs.version.raw
    }

    static func > (lhs: VersionInfo, rhs: VersionInfo) -> Bool {
        return lhs.version.raw > rhs.version.raw
    }

    static func < (lhs: VersionInfo, rhs: VersionInfo) -> Bool {
        return lhs.version.raw < rhs.version.raw
    }

    struct Version: Equatable {
        let major: Int
        let minor: Int
        let patch: Int

        init(arrayLiteral elements: [Int]) {
            major = elements[0]
            minor = elements[1]
            patch = elements[2]
        }

        var raw: Int {
            return major * 100 + minor * 10 + patch
        }
    }

    let version: Version
    let rowVersion: String
}
