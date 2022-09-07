//
//  BuildPipelineRunScript.swift
//  
//
//  Created by Silvester on 10.08.2022.
//

import Foundation
import TSCBasic

extension BuildPipeline {

    class RunScript: BuildPipelineAction {
        let scriptPath: String

        init(buildConfiguration: PackageBuildConfiguration, scriptPath: String) {
            self.scriptPath = scriptPath

            super.init(buildConfiguration: buildConfiguration)
        }

        override func run() throws {
            if scriptPath.isEmpty { return }

            let script = AbsolutePath(scriptPath,
                                      relativeTo: buildConfiguration.package.absolutePath)
            let process = Process(arguments: ["sh", script.basename],
                                  workingDirectory: script.parentDirectory,
                                  outputRedirection: .pretty)

            try process.launch()
            try process.waitUntilExit()

            if case .terminated(let errorCode) = process.result?.exitStatus, errorCode != 0 {
                print("Unable to run script at path \(scriptPath)")
                return
            }
        }
    }
}
