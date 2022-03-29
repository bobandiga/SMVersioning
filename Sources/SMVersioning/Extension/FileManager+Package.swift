//
//  FileManager+Package.swift
//  SMVersioning
//
//  Created by Максим Шаптала on 26.03.2022.
//

import Foundation

extension FileManager {
    var packageExist: Bool {
        guard let _files = try? contentsOfDirectory(atPath: currentDirectoryPath),
              _files.first(where: { $0 == "Package.swift" }) != nil
        else {
            return false
        }

        return true
    }
}
