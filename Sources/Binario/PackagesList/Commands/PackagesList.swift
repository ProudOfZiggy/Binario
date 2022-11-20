//
//  PackagesList.swift
//  
//
//  Created by Silvester on 31.07.2022.
//

import Foundation
import ArgumentParser

struct PackagesListCommand: ParsableCommand {
    public static let configuration = CommandConfiguration(commandName: "packages-list")

    @Argument(help: "Directory with packages containing sources.")
    var path: String

    mutating func run() throws {
        let allPackages: [SwiftPackage] = .init(dependenciesPath: path)

        if allPackages.isEmpty {
            print("No packages at \(path.canonicalPath ?? "")")
        } else {
            debugPrint(allPackages)
        }
    }
}
