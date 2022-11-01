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
         "-project", "\(buildConfiguration.xcodeproj)",
         "-scheme", "\(buildConfiguration.packageName)-Package",
         "-configuration", "Release",
         "-archivePath", "\(buildConfiguration.archivesPath)/Release-\(platform.rawValue)",
         "-destination", platform.destination,
         "BUILD_DIR=\(buildConfiguration.buildDirectory)",
         "SKIP_INSTALL=NO",
         "BUILD_LIBRARY_FOR_DISTRIBUTION=YES"]
    }
}
