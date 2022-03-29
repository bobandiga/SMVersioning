//
//  BumpProgram.swift
//  SMVersioning
//
//  Created by Максим Шаптала on 26.03.2022.
//

import Foundation

struct BumpProgram {


    // MARK: Public

    enum LocalError: LocalizedError {
        case creation
    }

    // MARK: Dependencies

    private let fileManager: FileManager
    private let bumpService: BumpService
    private var podspecService: PodspecService


    // MARK: Flags

    private let force: Bool
    private let skipPodspec: Bool


    // MARK: Lifecycle

    init(fileManager: FileManager,
         bumpService: BumpService,
         podspecService: PodspecService,
         force: Bool,
         skipPodspec: Bool) {
        self.fileManager = fileManager
        self.bumpService = bumpService
        self.force = force
        self.skipPodspec = skipPodspec
        self.podspecService = podspecService
    }

    // MARK: Public

    mutating func run() {

        var newVersion: VersionInfo!

        do {

            // 1: Get version and text
            if skipPodspec {
                newVersion = try packageOnlyVersion()
            } else {
                newVersion = bumpService.bumpNewVersion(oldVerionInfo: try podspecService.readPodspec())
            }

            // 2: Git check
            let tempVersion = try checkTagFlow(version: newVersion)

            if tempVersion != newVersion {
                if !skipPodspec {
                    if tempVersion > newVersion {
                        Logger.output("New selected version \(tempVersion.rowVersion) is greather then version \(newVersion.rowVersion) in podspec.")
                        let answer = Logger.offer(message: "Do you want to change version in podspec with \(tempVersion.rowVersion). [y] to continue, [n] to exit", variants: ["y", "n"])
                        if answer != "n" {
                            newVersion = tempVersion
                        } else {
                            exit(EXIT_FAILURE)
                        }
                    } else {
                        Logger.output("New selected version \(tempVersion.rowVersion) is less then version \(newVersion.rowVersion) in podspec.")
                        exit(EXIT_FAILURE)
                    }
                } else {
                    newVersion = tempVersion
                }

            }

            // 3: Git tag
            try GitTagProgramm().run(version: newVersion.rowVersion)

            if !skipPodspec {
                try podspecService.writePodspec(new: newVersion)
            }

            if force {
                try GitPushOriginProgramm().run(version: newVersion.rowVersion)
            }

        } catch let error as GitCheckTagProgramm.LocalError {
            Logger.error(error)
        } catch let error as GitTagProgramm.LocalError {
            Logger.error(error)
        } catch let error as GitPushOriginProgramm.LocalError {
            Logger.error(error)
        } catch let error as GitGetTagsProgramm.LocalError {
            Logger.error(error)
        } catch let error as PodspecService.LocalError where error == .write {
            Logger.warning(error)
            errorWritePodspecFlow(version: newVersion)
        } catch let error as GitPushOriginProgramm.LocalError {
            Logger.warning(error)
            errorPushOriginFlow(version: newVersion)
        } catch {
            Logger.error(error)
        }
    }


    // MARK: Private

    private func packageOnlyVersion() throws -> VersionInfo {
        
        guard fileManager.packageExist else {
            throw CocoaError(.fileNoSuchFile)
        }

        if let oldVersion = try GitGetTagsProgramm().run().last {
            let oldVersionInfo = try RowVersionParser().parseValue(rowVersion: oldVersion)
            let newVersionInfo = bumpService.bumpNewVersion(oldVerionInfo: oldVersionInfo)
            return newVersionInfo
        } else {
            return try startFlow()
        }
    }

    private func startFlow() throws -> VersionInfo {
        let answer = Logger.offer(message: "Let`s start with new version 1.0.0. Print [n] if want another version. [y] for agree.", variants: ["y", "n"])
        switch answer {
            case "n":
                let answer = Logger.input(message: "Let`s print version in vid [major.minor.patch]", regex: (regex: #"\d.\d.\d"#, message: "Support 'x.y.z' format."))
                return try RowVersionParser().parseValue(rowVersion: answer)
            default:
                return try RowVersionParser().parseValue(rowVersion: "1.0.0")
        }
    }

    private func errorWritePodspecFlow(version: VersionInfo) {
        do {
            try GitDeleteTagProgramm().run(version: version.rowVersion)
        } catch {
            Logger.error(error)
        }
    }

    private func errorPushOriginFlow(version: VersionInfo) {
        let answer = Logger.offer(message: "Can`t push version \(version.rowVersion) on origin. Unknown error. Print [y] if want to keep local version without origin pushing. [n] for decline all changes.", variants: ["y", "n"])
        if answer == "n" {
            do {
                try podspecService.revertPodspec()
                errorWritePodspecFlow(version: version)
            } catch {
                Logger.error(error)
            }
        } else {
            exit(EXIT_SUCCESS)
        }
    }

    private func checkTagFlow(version: VersionInfo) throws -> VersionInfo {
        do {
            try GitCheckTagProgramm().run(version: version.rowVersion)
            return version
        } catch let error as GitCheckTagProgramm.LocalError {
            switch error {
                case .git:
                    throw error
                case .local:
                    Logger.output("Version \(version.rowVersion) is already exist")
                    let answer = Logger.input(message: "Let`s print version in vid [major.minor.patch]", regex: (regex: #"\d.\d.\d"#, message: "Support 'x.y.z' format."))
                    let newVersion = try RowVersionParser().parseValue(rowVersion: answer)
                    return try checkTagFlow(version: newVersion)
            }
        } catch {
            throw error
        }
    }
}
