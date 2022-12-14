//
//  BuildPipelineResolve.swift
//  
//
//  Created by Silvester on 10.08.2022.
//

import Foundation

extension BuildPipeline {

    class Resolve: BuildPipelineAction {
        private let resovler = PackagesResolver()

        override func run() throws {
            try buildConfiguration.dependency.resolve()
        }
    }
}
