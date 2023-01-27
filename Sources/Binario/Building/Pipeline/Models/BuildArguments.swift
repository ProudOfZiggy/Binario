//
//  File.swift
//  
//
//  Created by Nikita Rodionov on 02.11.2022.
//

import Foundation

class BuildCommandsBuilder {
    struct Command {
        let arguments: [String]
    }
    
    let buildConfiguration: PackageBuildConfiguration
    
    init(buildConfiguration: PackageBuildConfiguration) {
        self.buildConfiguration = buildConfiguration
    }
    
    func buildCommands() -> [Command] {
        buildConfiguration.platforms.map { Command(arguments: defaultArguments(for: $0)) }
    }
    
    private func defaultArguments(for platform: Platform) -> [String] {
        ["xcrun",
         "xcodebuild",
         "-scheme", "\(buildConfiguration.packageName)",
         "-configuration", "Release",
         "-archivePath", "\(buildConfiguration.archivesPath)/Release-\(platform.rawValue)",
         "-destination", platform.destination,
         "-derivedDataPath", "\(buildConfiguration.buildDirectory)",
         "BUILD_DIR=\(buildConfiguration.buildDirectory)",
         "SKIP_INSTALL=NO",
         "BUILD_LIBRARY_FOR_DISTRIBUTION=YES"]
    }
}

class ResolveCommandBuilder {
    struct Command {
        let arguments: [String]
    }

    let buildConfiguration: PackageBuildConfiguration

    init(buildConfiguration: PackageBuildConfiguration) {
        self.buildConfiguration = buildConfiguration
    }

    func buildCommand() -> Command {
        Command(arguments: [
            "xcrun",
            "xcodebuild",
            "-resolvePackageDependencies",
            "-scheme", "\(buildConfiguration.packageName)",
            "-derivedDataPath", "\(buildConfiguration.buildDirectory)"
        ])
    }
}
