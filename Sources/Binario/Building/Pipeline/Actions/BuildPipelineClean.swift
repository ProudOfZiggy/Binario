//
//  BuildPipelineClean.swift
//  
//
//  Created by Silvester on 10.08.2022.
//

import Foundation

extension BuildPipeline {

    class Clean: BuildPipelineAction {

        override func run() throws {
            print("Cleaning \(buildConfiguration.packageName) package")

            let fManager = FileManager.default

            try? fManager.removeItem(at: buildConfiguration.buildDirectory.asURL)
            try? fManager.removeItem(at: buildConfiguration.xcodeproj.asURL)
        }
    }
}
