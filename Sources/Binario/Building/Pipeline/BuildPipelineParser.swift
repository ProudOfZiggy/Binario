//
//  BuildPipelineParser.swift
//  
//
//  Created by Silvester on 10.08.2022.
//

import Foundation
import TSCBasic

class BuildPipelineParser {
    private struct Pipeline {
        let fileName: String
        let data: Data?
    }
    
    private let pipelineFileNames = [
        ".binario.build.pipeline", // This one is deprecated
        "pipeline.binario"]

    func parse(packagePath: AbsolutePath) -> [BuildPipeline.Action] {
        let pipelines = pipelineFileNames.compactMap {
            Pipeline(fileName: $0,
                     data: try? Data(contentsOf: packagePath.appending(component: $0).asURL))
        }
        
        if pipelines.isEmpty { return [.defaultPipeline] }
        
        let pipeline = pipelines.first
        
        if pipelines.count > 1 {
            print("⚠️ Found more than one pipeline file at \(packagePath). Reading from \(pipeline?.fileName ?? "")")
        }
        
        guard let data = pipeline?.data, data.count > 0 else {
            return [.defaultPipeline]
        }

        let texts = String(data: data, encoding: .utf8)?.components(separatedBy: .newlines)

        guard let texts = texts, !texts.isEmpty else { return [.defaultPipeline] }

        return texts.map { BuildPipeline.Action(string: $0) }
    }
}
