//
//  BuildPipelineBuild.swift
//  
//
//  Created by Silvester on 10.08.2022.
//

import Foundation
import TSCBasic

extension BuildPipeline {

    class Build: BuildPipelineAction {

        override func run() throws {
            var commands: [[String]] = []

            let command1: [String] = [
                "xcrun",
                "xcodebuild",
                "-project", "\(buildConfiguration.xcodeproj)",
                "-scheme", "\(buildConfiguration.packageName)-Package",
                "-configuration", "Release",
                "-archivePath", "\(buildConfiguration.archivesPath)/Release-iphoneos",
                "-destination", "generic/platform=iOS",
                "BUILD_DIR=\(buildConfiguration.buildDirectory)",
                "SKIP_INSTALL=NO",
                "BUILD_LIBRARY_FOR_DISTRIBUTION=YES"
            ]

            let command2: [String] = [
                "xcrun",
                "xcodebuild",
                "-project", "\(buildConfiguration.xcodeproj)",
                "-scheme", "\(buildConfiguration.packageName)-Package",
                "-configuration", "Release",
                "-archivePath", "\(buildConfiguration.archivesPath)/Release-iphonesimulator",
                "-destination", "generic/platform=iOS Simulator",
                "BUILD_DIR=\(buildConfiguration.buildDirectory)",
                "SKIP_INSTALL=NO",
                "BUILD_LIBRARY_FOR_DISTRIBUTION=YES"
            ]

            commands.append(command1)
            commands.append(command2)

            for arguments in commands {
                let process = Process(arguments: arguments,
                                      outputRedirection: .pretty)
                try process.launch()
                try process.waitUntilExit()

                if case .terminated(let errorCode) = process.result?.exitStatus, errorCode != 0 {
                    throw "Unable to build \(buildConfiguration.packageName)"
                }
            }
        }
    }
}
