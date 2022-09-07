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
            var command: [String] = [
                "xcrun",
                "xcodebuild",
                "-create-xcframework"
            ]

            let packageName = buildConfiguration.packageName
            let paths = ["iphoneos", "iphonesimulator"].map { "\(buildConfiguration.buildDirectory)/Release-\($0)" }

            let fManager = FileManager.default

            for path in paths {
                let url = URL(fileURLWithPath: path, isDirectory: true)

                let keys: [URLResourceKey] = [.canonicalPathKey]

                let enumerator = fManager.enumerator(at: url,
                                                     includingPropertiesForKeys: keys,
                                                     options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants],
                                                     errorHandler: nil)

                let frameworkExtension = "framework"

                while let url = enumerator?.nextObject() as? URL {
                    if url.pathExtension == frameworkExtension && url.deletingPathExtension().lastPathComponent != packageName {
                        if let framework = try? url.resourceValues(forKeys: Set(keys)).canonicalPath {
                            command.append("-framework")
                            command.append(framework)
                        }
                    }
                }
            }

            command.append("-output")
            command.append("\(buildConfiguration.xcFrameworksOutputPath)/\(packageName).xcframework")

            try? fManager.removeItem(at: buildConfiguration.xcFrameworksOutputPath.asURL)

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
