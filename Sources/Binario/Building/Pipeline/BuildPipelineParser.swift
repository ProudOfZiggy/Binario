//
//  BuildPipelineParser.swift
//  
//
//  Created by Silvester on 10.08.2022.
//

import Foundation
import TSCBasic

class BuildPipelineParser {
    private let pipelineFileName = ".binario.build.pipeline"

    func parse(packagePath: AbsolutePath) -> [BuildPipeline.Action] {
        let data = try? Data(contentsOf: packagePath.appending(component: pipelineFileName).asURL)

        guard let data = data, data.count > 0 else {
            return [.defaultPipeline]
        }

        let texts = String(data: data, encoding: .utf8)?.components(separatedBy: .newlines)

        guard let texts = texts, !texts.isEmpty else { return [.defaultPipeline] }

        return texts.map { BuildPipeline.Action(string: $0) }
    }
}
