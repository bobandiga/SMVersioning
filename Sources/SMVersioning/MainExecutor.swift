//
//  MainExecutor.swift
//  SMVersioning
//
//  Created by Максим Шаптала on 24.03.2022.
//

import Foundation

struct MainExecutor {


    // MARK: Programs

    private var bumpProgram: BumpProgram!
    private var helpProgram: HelpProgram!

    private let program: String

    // MARK: Lifecycle

    init(fileManager: FileManager = .default,
         processInfo: ProcessInfo = .processInfo) {
        var arguments = processInfo.arguments
        arguments.removeFirst()

        guard let program = arguments.first, ["bump", "b", "help"].contains(program) else {
            Logger.output("Unsupported command. Try use help")
            exit(EXIT_FAILURE)
        }
        arguments.removeFirst()
        self.program = program

        prepare(for: program, arguments: &arguments)

        checkExtraArguments(arguments: arguments)
    }


    // MARK: Public

    mutating func run() {
        switch program {
            case "bump", "b":
                bumpProgram.run()
                exit(EXIT_SUCCESS)
            case "help":
                helpProgram.run()
                exit(EXIT_SUCCESS)
            default:
                exit(EXIT_FAILURE)
        }
    }

    // MARK: Private

    mutating private func prepare(for program: String, arguments: inout [String]) {
        switch program {
            case "bump", "b":
                guard let _bumpType = arguments.first, let bumpType = BumpType(rawValue: _bumpType) else {
                    Logger.output("Unsupported bump type. Try use bump [major|minor|patch]")
                    exit(EXIT_FAILURE)
                }
                arguments.removeFirst()

                let force = parseArgument(arguments: &arguments, key: "-p")
                let skipPodspec = parseArgument(arguments: &arguments, key: "-s")

                bumpProgram = BumpProgram(fileManager: .default,
                                          bumpService: BumpService(bumpType: bumpType),
                                          podspecService: PodspecService(fileManager: .default,
                                                                         podspecVersionParser: PodspecVersionParser()),
                                          force: force,
                                          skipPodspec: skipPodspec)

            case "help":
                helpProgram = HelpProgram()
            default:
                return
        }
    }

    private func parseArgument(arguments: inout [String], key: String) -> Bool {
        if arguments.contains(key), let index = arguments.firstIndex(of: key) {
            arguments.remove(at: index)
            return true
        }

        return false
    }

    private func checkExtraArguments(arguments: [String]) {
        guard !arguments.isEmpty else {
            return
        }

        for arg in arguments {
            Logger.output("Unknown argument \(arg). Skip it.")
        }
    }
}
