//
//  Build.swift
//  
//
//  Created by Silvester on 01.08.2022.
//

import Foundation
import ArgumentParser

struct BuildCommand: ParsableCommand {
    public static let configuration = CommandConfiguration(commandName: "build",
                                                           subcommands: [Build.self,
                                                                         BuildPiplelineCommand.self],
                                                           defaultSubcommand: Build.self)
}

private struct Build: ParsableCommand {
    public static let configuration = CommandConfiguration(shouldDisplay: false)

    @Argument(help: "Package containing directory.")
    var packagePath: String

    mutating func run() throws {
        do {
            guard let package = Package(path: packagePath) else {
                throw "No package found at \(packagePath.canonicalPath ?? "")"
            }

            let config = PackageBuildConfiguration(package: package)
            let pipeline = BuildPipeline(buildConfiguration: config)
            try pipeline.run()
        } catch let error {
            print("Unable to build package \(packagePath.lastPathComponent)")
            print(error.localizedDescription)
        }
    }
}
