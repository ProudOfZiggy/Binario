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
//            if buildConfiguration.dependency.isResolved { return }
            
            try buildConfiguration.dependency.resolve()
        }
    }
}
