//
//  Logger.swift
//  SMVersioning
//
//  Created by Максим Шаптала on 23.03.2022.
//

import Foundation

struct Logger {

    static func input(message: String, regex: (regex: String, message: String)?) -> String {
        print(message)
        if let answer = readLine() {
            if let regex = regex {
                return message.matches(for: regex.regex).first ?? input(message: regex.message, regex: regex)
            } else {
                return answer
            }
        } else {
            return input(message: message, regex: regex)
        }
    }

    static func offer(message: String, variants: [String]) -> String {
        print(message, variants, separator: "\t", terminator: "\n")
        if let answer = readLine(), variants.contains(answer) {
            return answer
        } else {
            return offer(message: message, variants: variants)
        }
    }

    static func output(_ message: String) {
        print(message)
    }

    static func warning(_ error: Error) {
        print(error.localizedDescription)
    }

    static func error(_ error: Error) {
        print(error.localizedDescription)
        exit(EXIT_FAILURE)
    }
}
