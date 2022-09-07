//
//  BuildPipelineAction.swift
//  
//
//  Created by Silvester on 10.08.2022.
//

import Foundation

class BuildPipelineAction {
    let buildConfiguration: PackageBuildConfiguration

    init(buildConfiguration: PackageBuildConfiguration) {
        self.buildConfiguration = buildConfiguration
    }

    func run() throws {}
}
