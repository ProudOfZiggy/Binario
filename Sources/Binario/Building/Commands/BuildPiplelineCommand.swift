//
//  BuildPipeline.swift
//  
//
//  Created by Silvester on 10.08.2022.
//

import Foundation
import ArgumentParser

struct BuildPiplelineCommand: ParsableCommand {
    public static let configuration = CommandConfiguration(commandName: "pipeline",
                                                           subcommands: [Build.self,
                                                                         Clean.self,
                                                                         GenerateXCProject.self,
                                                                         CreateXCFramework.self])
}

private extension BuildPiplelineCommand {

    struct Build: ParsableCommand {
        @Argument(help: "Package containing directory.")
        var packagePath: String

        mutating func run() throws {
            do {
                guard let package = Package(path: packagePath) else {
                    throw "No package found at \(packagePath.canonicalPath ?? "")"
                }

                let config = PackageBuildConfiguration(package: package)
                let action = BuildPipeline.Build(buildConfiguration: config)
                try action.run()
            } catch let error {
                print("Unable to build package \(packagePath.lastPathComponent)")
                print(error.localizedDescription)
            }
        }
    }
}

private extension BuildPiplelineCommand {

    struct Clean: ParsableCommand {
        @Argument(help: "Package containing directory.")
        var packagePath: String

        mutating func run() throws {
            do {
                guard let package = Package(path: packagePath) else {
                    throw "No package found at \(packagePath.canonicalPath ?? "")"
                }

                let config = PackageBuildConfiguration(package: package)
                let action = BuildPipeline.Clean(buildConfiguration: config)
                try action.run()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}

private extension BuildPiplelineCommand {

    struct CreateXCFramework: ParsableCommand {
        public static let configuration = CommandConfiguration(commandName: "create-xcframework")

        @Argument(help: "Package containing directory.")
        var packagePath: String

        mutating func run() throws {
            do {
                guard let package = Package(path: packagePath) else {
                    throw "No package found at \(packagePath.canonicalPath ?? "")"
                }

                let config = PackageBuildConfiguration(package: package)
                let action = BuildPipeline.CreateXCFramework(buildConfiguration: config)
                try action.run()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}

private extension BuildPiplelineCommand {

    struct GenerateXCProject: ParsableCommand {
        public static let configuration = CommandConfiguration(commandName: "create-xcproject")

        @Argument(help: "Package containing directory.")
        var packagePath: String

        mutating func run() throws {
            do {
                guard let package = Package(path: packagePath) else {
                    throw "No package found at \(packagePath.canonicalPath ?? "")"
                }

                let config = PackageBuildConfiguration(package: package)
                let action = BuildPipeline.GenerateXCProject(buildConfiguration: config)
                try action.run()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}