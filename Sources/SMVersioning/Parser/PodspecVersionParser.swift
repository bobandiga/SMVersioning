//
//  PodspecVersionParser.swift
//  SMVersioning
//
//  Created by Максим Шаптала on 23.03.2022.
//

import Foundation

struct PodspecVersionParser {


    // MARK: Public

    enum LocalError: LocalizedError {
        case version
        case format
    }
    

    // MARK: Private

    private let regex =  #"(?<=').*?(?=')"#


    // MARK: Public

    func parseValue(textSpec: String) throws -> VersionInfo {
        return try oldVersionInfo(textSpec: textSpec)
    }


    // MARK: Private

    private func oldVersionInfo(textSpec: String) throws -> VersionInfo {
        let rows = textSpec.split(separator: "\n" ).map { String($0) }

        guard let fullRowVersion = rows.first(where: { $0.contains(".version") }) else {
            throw LocalError.version
        }

        guard let rowVersion = fullRowVersion.matches(for: regex).first else {
            throw LocalError.format
        }

        return try RowVersionParser().parseValue(rowVersion: rowVersion)
    }
}
