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

        @Argument(help: "Directory with packages containing sources.")
        var packages: String

        mutating func run() throws {
            let cache = PackagesChecksumsCacheStorage(packagesPath: packages)
            cache.clean()
            print("Cleaned packages cache at \(packages.canonicalPath ?? "")")
        }
    }
}
