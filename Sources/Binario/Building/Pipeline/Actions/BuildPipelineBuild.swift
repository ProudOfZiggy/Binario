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
                                      workingDirectory: buildConfiguration.dependency.absolutePath,
                                      outputRedirection: .none)
                try process.launch()
                try process.waitUntilExit()

                if case .terminated(let errorCode) = process.result?.exitStatus, errorCode != 0 {
                    print("FINISHED WITH ERROR CODE - \(errorCode)")
                    if errorCode == 65 {
                        try run()
                    } else {
                        throw "Unable to build \(buildConfiguration.packageName)"
                    }
                }
            }
        }
    }
}
