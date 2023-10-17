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
                                      relativeTo: buildConfiguration.dependency.absolutePath)
            let process = Process(arguments: ["sh", script.basename],
                                  environment: buildConfiguration.scriptEnvironment,
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

private extension PackageBuildConfiguration {
    var scriptEnvironment: [String: String] {
        var env: [String: String] = ProcessEnv.vars
        
        env["DEPENDENCY_NAME"] = packageName
        env["DEPENDENCY_BINARY_NAME"] = dependency.binaryName
        env["DEPENDENCY_PATH"] = dependency.absolutePath.pathString
        env["BUILD_PATH"] = buildDirectory.pathString
        env["ARCHIVES_PATH"] = archivesPath.pathString
        env["XCFRAMEWORKS_PATH"] = xcFrameworksOutputPath.pathString
        env["TARGET_PLATFORMS"] = platforms.map { $0.rawValue }.joined(separator: ",")
        
        return env
    }
}
