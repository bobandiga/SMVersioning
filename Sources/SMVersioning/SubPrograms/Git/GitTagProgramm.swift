//
//  GitTagProgramm.swift
//  SMVersioning
//
//  Created by Максим Шаптала on 24.03.2022.
//

import Foundation

struct GitTagProgramm {


    // MARK: Public

    enum LocalError: LocalizedError {
        case git(String)
        case local

        var errorDescription: String? {
            switch self {
                case .git(let string):
                    return "Can`t git tag version. \(string)"
                case .local:
                    return "Can`t tag version. Unknown error."
            }
        }
    }
    

    // MARK: Private

    private let executablePath = "/usr/bin/git"
    private let arguments = ["tag"]

    private let outputPipe = Pipe()
    private let errorPipe = Pipe()


    // MARK: Public

    func run(version: String) throws {
        var args = arguments
        args.append(version)

        let task = Process()
        task.arguments = args

        if #available(macOS 10.13, *) {
            task.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        } else {
            task.launchPath = executablePath
        }

        task.standardOutput = outputPipe
        task.standardError = errorPipe

        if #available(macOS 10.13, *) {
            try? task.run()
        } else {
            task.launch()
        }

        task.waitUntilExit()

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

        let output = String(decoding: outputData, as: UTF8.self)
        let error = String(decoding: errorData, as: UTF8.self)

        guard error.isEmpty else {
            throw LocalError.git(error)
        }

        guard output.isEmpty else {
            throw LocalError.local
        }
    }
}
