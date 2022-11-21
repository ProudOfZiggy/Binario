//
//  BuildPipelineGenerateXCProject.swift
//  
//
//  Created by Silvester on 10.08.2022.
//

import Foundation
import TSCBasic

extension BuildPipeline {

    class GenerateXCProject: BuildPipelineAction {

        override func run() throws {
            let process = Process(arguments: ["swift", "package", "generate-xcodeproj"],
                                  workingDirectory: buildConfiguration.dependency.absolutePath,
                                  outputRedirection: .pretty)
            try process.launch()
            try process.waitUntilExit()

            if case .terminated(let errorCode) = process.result?.exitStatus, errorCode != 0 {
                throw "Unable to generate .xcodeproj for \(buildConfiguration.packageName)"
            }
        }
    }
}
