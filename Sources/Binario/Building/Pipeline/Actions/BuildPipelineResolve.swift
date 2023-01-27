//
//  BuildPipelineResolve.swift
//  
//
//  Created by Silvester on 10.08.2022.
//

import Foundation
import TSCBasic

extension BuildPipeline {

    class Resolve: BuildPipelineAction {

        override func run() throws {
            let commandsBuilder = ResolveCommandBuilder(buildConfiguration: buildConfiguration)
            let command = commandsBuilder.buildCommand()

            let process: TSCBasic.Process

            process = Process(arguments: command.arguments,
                              workingDirectory: buildConfiguration.dependency.absolutePath,
                              outputRedirection: .none)

            try process.launch()
            let result = try process.waitUntilExit()

            if case .terminated(let errorCode) = result.exitStatus, errorCode != 0 {
                throw "Unable to resolve \(buildConfiguration.packageName)"
            }
        }
    }
}
