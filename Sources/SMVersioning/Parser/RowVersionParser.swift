//
//  RowVersionParser.swift
//  SMVersioning
//
//  Created by Максим Шаптала on 26.03.2022.
//

import Foundation

struct RowVersionParser {


    // MARK: Public

    struct LocalError: LocalizedError {}


    // MARK: Public

    func parseValue(rowVersion: String) throws -> VersionInfo {
        let components = rowVersion.split(separator: ".").compactMap { Int($0) }

        guard components.count == 3 else {
            throw LocalError()
        }


        return VersionInfo(version: .init(arrayLiteral: components),
                           rowVersion: rowVersion)
    }
}
