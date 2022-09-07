//
//  BuildPipelineActionType.swift
//  
//
//  Created by Silvester on 10.08.2022.
//

import Foundation

extension BuildPipeline {

    enum Action {
        case clean
        case resolve
        case generate
        case build
        case createXCFrameworks
        case defaultPipeline
        case script(path: String)

        init(string: String) {
            switch string {
            case "clean": self = .clean
            case "resolve": self = .resolve
            case "generate": self = .generate
            case "build": self = .build
            case "create-xcframeworks": self = .createXCFrameworks
            case "default-pipeline": self = .defaultPipeline
            default: self = .script(path: string)
            }
        }
    }
}
