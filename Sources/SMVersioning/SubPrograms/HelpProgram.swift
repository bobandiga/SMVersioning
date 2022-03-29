//
//  HelpProgram.swift
//  SMVersioning
//
//  Created by Максим Шаптала on 29.03.2022.
//

import Foundation

struct HelpProgram {

    func run() {
        Logger.output("""
Usage bump [major|minor|patch].
Options:
        [-s] skip podspec, only package. Default false.
        [-f] force push on origin, only package. Default false.
""")
    }
}
