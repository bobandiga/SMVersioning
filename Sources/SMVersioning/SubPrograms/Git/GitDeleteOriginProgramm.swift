//
//  GitDeleteOriginProgramm.swift
//  SMVersioning
//
//  Created by Максим Шаптала on 24.03.2022.
//

import Foundation

struct GitDeleteOriginProgramm {

    // MARK: Private

    private let executablePath = "/usr/bin/git"
    private let arguments = ["push", "origin", "--delete"]

    private let outputPipe = Pipe()
    private let errorPipe = Pipe()


    // MARK: Public

    func run(version: String) throws -> Bool {
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
            return false
        }

        return !output.isEmpty
    }
}
