//
//  BuildPipeline.swift
//  
//
//  Created by Silvester on 01.08.2022.
//

import Foundation
import TSCBasic

class BuildPipeline {
    let buildConfiguration: PackageBuildConfiguration

    init(buildConfiguration: PackageBuildConfiguration) {
        self.buildConfiguration = buildConfiguration
    }

    func run() throws {
        let parser = BuildPipelineParser()
        let actions = parser.parse(packagePath: buildConfiguration.dependency.absolutePath)

        for action in actions {
            switch action {
            case .clean: try clean()
            case .resolve: try resolve()
            case .build: try build()
            case .createXCFrameworks: try createXCFrameworks()
            case .script(let path): try runScript(path: path)
            case .defaultPipeline:
                try clean()
                try resolve()
                try build()
                try createXCFrameworks()
            }
        }
    }

    private func clean() throws {
        let action = Clean(buildConfiguration: buildConfiguration)
        try action.run()
    }

    private func resolve() throws {
        let action = Resolve(buildConfiguration: buildConfiguration)
        try action.run()
    }

    private func build() throws {
        let action = Build(buildConfiguration: buildConfiguration)
        try action.run()
    }

    private func createXCFrameworks() throws {
        let action = CreateXCFramework(buildConfiguration: buildConfiguration)
        try action.run()
    }

    private func runScript(path: String) throws {
        let action = RunScript(buildConfiguration: buildConfiguration, scriptPath: path)
        try action.run()
    }
}
