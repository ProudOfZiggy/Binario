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
        private var maxAttempts = 2
        private var attempts = 0
        
        override func run() throws {
            let commandsBuilder = BuildCommandsBuilder(buildConfiguration: buildConfiguration)
            let commands = commandsBuilder.buildCommands()
            
            for command in commands {
                attempts += 1
                
                let process = Process(arguments: command.arguments,
                                      workingDirectory: buildConfiguration.dependency.absolutePath,
                                      outputRedirection: .none)
                try process.launch()
                try process.waitUntilExit()

                if case .terminated(let errorCode) = process.result?.exitStatus, errorCode != 0 {
                    // Handle floating issue with SPM resolver
                    // https://github.com/apple/swift-package-manager/issues/5767
                    if errorCode == 65 && attempts <= maxAttempts {
                        try run()
                    } else {
                        throw "Unable to build \(buildConfiguration.packageName)"
                    }
                }
            }
        }
    }
}
