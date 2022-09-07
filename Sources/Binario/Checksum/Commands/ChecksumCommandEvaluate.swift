//
//  ChecksumCommandEvaluate.swift
//  
//
//  Created by Silvester on 10.08.2022.
//

import Foundation
import ArgumentParser

extension ChecksumCommand {

    struct Evaluate: ParsableCommand {
        @Argument(help: "Package containing directory.")
        var packagePath: String = ""

        mutating func run() throws {
            do {
                guard let package = Package(path: packagePath) else {
                    throw "No package found at \(packagePath.canonicalPath ?? "")"
                }

                let evaluator = PackageChecksumEvaluator()

                if let checksum = try evaluator.evaluateChecksum(package: package) {
                    print("\(packagePath.lastPathComponent) package checksum - \(checksum.value)")
                } else {
                    print("Unable to evaluate checksum for package \(package.name)")
                }
            } catch let error {
                print("Unable to evaluate checksum for package \(packagePath.lastPathComponent)")
                print(error.localizedDescription)
            }
        }
    }
}
