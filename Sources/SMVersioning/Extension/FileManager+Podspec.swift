//
//  FileManager+Podspec.swift
//  SMVersioning
//
//  Created by Максим Шаптала on 26.03.2022.
//

import Foundation

extension FileManager {
    var podspecName: String? {
        guard let _files = try? contentsOfDirectory(atPath: currentDirectoryPath),
              let podspecName = _files.first(where: { $0.hasSuffix(".podspec") })?.split(separator: ".").first
        else {
            return nil
        }

        return String(podspecName)
    }

    var podspecURL: URL? {
        guard let podspecName = podspecName else {
            return nil
        }

        let dirURL = URL(fileURLWithPath: currentDirectoryPath)
        let podspecURL = dirURL.appendingPathComponent(String(podspecName)).appendingPathExtension(.podspecExtesnion)

        return podspecURL
    }
}

fileprivate extension String {
    static var podspecExtesnion = "podspec"
}
