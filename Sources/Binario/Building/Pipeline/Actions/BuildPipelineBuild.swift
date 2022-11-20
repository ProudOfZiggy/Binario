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
            let commandsBuilder = BuildCommandsBuilder(buildConfiguration: buildConfiguration)
            let commands = commandsBuilder.buildCommands()
            
            for command in commands {
                let process = Process(arguments: command.arguments,
                                      workingDirectory: buildConfiguration.package.absolutePath,
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
