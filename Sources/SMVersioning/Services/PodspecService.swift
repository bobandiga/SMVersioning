//
//  PodspecService.swift
//  SMVersioning
//
//  Created by Максим Шаптала on 28.03.2022.
//

import Foundation

struct PodspecService {


    // MARK: Private

    private let podspecVersionParser: PodspecVersionParser
    private let fileManager: FileManager

    private var _oldVersion: VersionInfo!
    private var _oldPodspecText: String!


    // MARK: Public

    enum LocalError: LocalizedError {
        case read
        case write
    }


    // MARK: Lifecycle

    init(fileManager: FileManager, podspecVersionParser: PodspecVersionParser) {
        self.fileManager = fileManager
        self.podspecVersionParser = podspecVersionParser
    }


    // MARK: Public

    mutating func readPodspec() throws -> VersionInfo {
        let podspec = try _readPodspec()
        let version = try podspecVersionParser.parseValue(textSpec: podspec)

        _oldVersion = version
        _oldPodspecText = podspec

        return version
    }

    func writePodspec(new versionInfo: VersionInfo) throws {
        guard let url = fileManager.podspecURL else {
            throw CocoaError(.fileNoSuchFile)
        }

        let range = _oldPodspecText.range(of: _oldVersion.rowVersion)
        let newText = _oldPodspecText.replacingOccurrences(of: _oldVersion.rowVersion, with: versionInfo.rowVersion, options: [], range: range)

        do {
            try newText.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            throw LocalError.write
        }
    }

    func revertPodspec() throws {

    }

    // MARK: Private

    private func _readPodspec() throws -> String {
        guard let url = fileManager.podspecURL else {
            throw CocoaError(.fileNoSuchFile)
        }

        do {
            let text = try String(contentsOf: url, encoding: .utf8)
            return text
        } catch {
            throw LocalError.read
        }
    }
}
