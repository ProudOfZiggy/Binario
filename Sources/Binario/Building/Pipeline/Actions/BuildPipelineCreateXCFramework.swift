//
//  BuildPipelineCreateXCFramework.swift
//  
//
//  Created by Silvester on 10.08.2022.
//

import Foundation
import TSCBasic

extension BuildPipeline {

    class CreateXCFramework: BuildPipelineAction {

        override func run() throws {
            let baseCommand: [String] = [
                "xcrun",
                "xcodebuild",
                "-create-xcframework"
            ]

            let packageName = buildConfiguration.packageName
            let paths = ["iphoneos", "iphonesimulator"].map { "\(buildConfiguration.buildDirectory)/Release-\($0)" }

            let fManager = FileManager.default

            var commands: [[String]] = []
            var frameworks: [String: [String]] = [:]
            
            for path in paths {
                let url = URL(fileURLWithPath: path, isDirectory: true)

                let keys: [URLResourceKey] = [.canonicalPathKey]

                let enumerator = fManager.enumerator(at: url,
                                                     includingPropertiesForKeys: keys,
                                                     options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants],
                                                     errorHandler: nil)

                let frameworkExtension = "framework"

                while let url = enumerator?.nextObject() as? URL {
                    let frameworkName = url.deletingPathExtension().lastPathComponent
                    
                    if url.pathExtension == frameworkExtension && frameworkName != packageName {
                        if let framework = try? url.resourceValues(forKeys: Set(keys)).canonicalPath {
                            frameworks[frameworkName, default: []].append(framework)
                        }
                    }
                }
            }
            
            for (name, paths) in frameworks {
                var command = baseCommand

                for path in paths {
                    command.append("-framework")
                    command.append(path)
                }

                command.append("-output")
                command.append("\(buildConfiguration.xcFrameworksOutputPath)/\(name).xcframework")
                
                commands.append(command)
            }

            try? fManager.removeItem(at: buildConfiguration.xcFrameworksOutputPath.asURL)

            for command in commands {
                let process = Process(arguments: command,
                                      outputRedirection: .pretty)
                try process.launch()
                try process.waitUntilExit()

                if case .terminated(let errorCode) = process.result?.exitStatus, errorCode != 0 {
                    throw "Unable to create XCFramework for \(packageName) pacakge"
                }
            }
        }
    }
}
