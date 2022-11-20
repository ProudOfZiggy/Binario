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
            
            for path in paths {
                let enumerator = filesEnumerator(for: path)
                
                let objectExtension = "o"
                
                while let url = enumerator?.nextObject() as? URL {
                    let objectName = url.deletingPathExtension().lastPathComponent
                    
                    if url.pathExtension == objectExtension && objectName != packageName {
                        try? convert(object: objectName, at: AbsolutePath(path))
                    }
                }
            }
            
            var commands: [[String]] = []
            var frameworks: [String: [String]] = [:]
            var libraries: [String: [String]] = [:]
            
            for path in paths {
                let url = URL(fileURLWithPath: path, isDirectory: true)

                let keys: [URLResourceKey] = [.canonicalPathKey]

                let enumerator = fManager.enumerator(at: url,
                                                     includingPropertiesForKeys: keys,
                                                     options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants],
                                                     errorHandler: nil)

                let frameworkExtension = "framework"
                let libraryExtension = "a"

                while let url = enumerator?.nextObject() as? URL {
                    let fileName = url.deletingPathExtension().lastPathComponent
                    
                    if fileName != packageName {
                        if let file = try? url.resourceValues(forKeys: Set(keys)).canonicalPath {
                            if url.pathExtension == frameworkExtension {
                                frameworks[fileName, default: []].append(file)
                            }
                            if url.pathExtension == libraryExtension {
                                libraries[fileName, default: []].append(file)
                            }
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
            
            for (name, paths) in libraries {
                var command = baseCommand

                for path in paths {
                    command.append("-library")
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
        
        private func convert(object: String, to staticName: String? = nil, at path: AbsolutePath) throws {
            let staticName = staticName ?? object
            
            let command = [
                "ar", "-crs", "\(staticName).a", "\(object).o"
            ]
            let process = Process(arguments: command,
                                  workingDirectory: path,
                                  outputRedirection: .pretty)
            
            try process.launch()
            try process.waitUntilExit()
        }
        
        private func filesEnumerator(for path: String) -> FileManager.DirectoryEnumerator? {
            let url = URL(fileURLWithPath: path, isDirectory: true)

            let keys: [URLResourceKey] = [.canonicalPathKey]

            return FileManager.default.enumerator(at: url,
                                                  includingPropertiesForKeys: keys,
                                                  options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants],
                                                  errorHandler: nil)
        }
    }
}
