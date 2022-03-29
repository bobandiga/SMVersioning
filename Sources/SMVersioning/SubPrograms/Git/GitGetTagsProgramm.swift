//
//  GitGetTagsProgramm.swift
//  SMVersioning
//
//  Created by Максим Шаптала on 25.03.2022.
//

import Foundation

struct GitGetTagsProgramm {


    // MARK: Public

    struct LocalError: LocalizedError {

        let message: String

        var errorDescription: String? {
            return "Can`t get git tag`s. \(message)"
        }
    }


    // MARK: Private

    private let executablePath = "/usr/bin/git"
    private let arguments = ["tag"]

    private let outputPipe = Pipe()
    private let errorPipe = Pipe()


    // MARK: Public

    func run() throws -> [String] {
        let task = Process()
        task.arguments = arguments

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
            throw LocalError(message: error)
        }

        return output.split(separator: "\n").map { String($0) }
    }
}
