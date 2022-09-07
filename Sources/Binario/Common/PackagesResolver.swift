//
//  PackagesResolver.swift
//  
//
//  Created by Silvester on 01.08.2022.
//

import TSCBasic
import Foundation

class PackagesResolver {

    func resolve(package: Package) throws {
        try? FileManager.default.removeItem(at: package.resolvedPath.asURL)

        let process = Process(arguments: ["swift", "package", "resolve"],
                              workingDirectory: package.absolutePath,
                              outputRedirection: .pretty)
        try process.launch()
        try process.waitUntilExit()

        if case .terminated(let errorCode) = process.result?.exitStatus, errorCode != 0 {
            throw "Unable to resove package - \(package.name)"
        }
    }
}

extension Package {

    func resolve() throws {
        let resolver = PackagesResolver()
        try resolver.resolve(package: self)
    }
}
