//
//  Bumper.swift
//  SMVersioning
//
//  Created by Максим Шаптала on 23.03.2022.
//

import Foundation

struct BumpService {


    // MARK: Private

    private let regex = #"(?<=').*?(?=')"#

    
    // MARK: Public

    let bumpType: BumpType


    // MARK: Lifecycle

    init(bumpType: BumpType) {
        self.bumpType = bumpType
    }

    // MARK: Public
    
    func bumpNewVersion(oldVerionInfo: VersionInfo) -> VersionInfo {

        let newVersion: VersionInfo.Version
        let newRowVersion: String

        switch bumpType {
            case .major:
                newVersion = .init(arrayLiteral: [oldVerionInfo.version.major + 1,
                                                  0,
                                                  0])
            case .minor:
                newVersion = .init(arrayLiteral: [oldVerionInfo.version.major,
                                                  oldVerionInfo.version.minor + 1,
                                                  0])
            case .patch:
                newVersion = .init(arrayLiteral: [oldVerionInfo.version.major,
                                                  oldVerionInfo.version.minor,
                                                  oldVerionInfo.version.patch + 1])
        }

        newRowVersion = [newVersion.major, newVersion.minor, newVersion.patch].map({ String($0) }).joined(separator: ".")

        return VersionInfo(version: newVersion, rowVersion: newRowVersion)
    }
}
