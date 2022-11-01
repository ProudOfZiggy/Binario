//
//  ChecksumCommandClean.swift
//  
//
//  Created by Silvester on 10.08.2022.
//

import Foundation
import ArgumentParser

extension ChecksumCommand {

    struct Clean: ParsableCommand {
        public static let configuration = CommandConfiguration(commandName: "clean")

        @Argument(help: "Package directory")
        var packagePath: String = "."

        mutating func run() throws {
            guard let package = Package(path: packagePath) else {
                throw "No package found at \(packagePath.canonicalPath ?? "")"
            }
            
            let cache = PackageChecksumCache(package: package)
            cache.clean()
        }
    }
}
