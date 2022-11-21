//
//  ChecksumCommandWrite.swift
//  
//
//  Created by Nikita Rodionov on 01.11.2022.
//

import Foundation
import ArgumentParser

extension ChecksumCommand {
    
    struct Write: ParsableCommand {
        public static let configuration = CommandConfiguration(commandName: "write")
        
        @Argument(help: "Checksum to write")
        var checksum: String
        
        @Argument(help: "Package containing directory.")
        var packagePath: String = "."
        
        mutating func run() throws {
            guard let package = SwiftPackage(path: packagePath) else {
                throw "No package found at \(packagePath.canonicalPath ?? "")"
            }
            
            let cache = PackageChecksumCache(dependency: package)
            cache.write(checksum: PackageChecksum(packageName: package.name, value: checksum))
        }
    }
}
