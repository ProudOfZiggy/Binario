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
        buildConfiguration.platforms.map { Command(arguments: makeArguments(for: $0)) }
    }
    
    private func makeArguments(for platform: Platform) -> [String] {
        var arguments = [
            "xcrun",
            "xcodebuild",
            "-scheme", "\(buildConfiguration.packageName)",
            "-configuration", "Release",
            "-archivePath", "\(buildConfiguration.archivesPath)/Release-\(platform.rawValue)",
            "-destination", platform.destination,
         	"-derivedDataPath", "\(buildConfiguration.buildDirectory)",
            "BUILD_DIR=\(buildConfiguration.buildDirectory)",
            "SKIP_INSTALL=NO",
            "BUILD_LIBRARY_FOR_DISTRIBUTION=YES"
        ]
        updateArgumentsIfNeeded(&arguments)
        return arguments
    }
    
    private func updateArgumentsIfNeeded(_ arguments: inout [String]) {
        var mergeIndex: Int?
        buildConfiguration.dependency.configuration.xcodeBuildSettings?.forEach { arg in
            if let index = mergeIndex {
                arguments[index] = arg
                mergeIndex = nil
            } else if arg.contains("="),
                let key = arg.split(separator: "=").first,
                let index = arguments.firstIndex(where: { $0.hasPrefix(key) }){
                arguments[index] = arg
            } else if let index = arguments.firstIndex(of: arg) {
                mergeIndex = index + 1
            } else {
                arguments.append(arg)
            }
        }
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
