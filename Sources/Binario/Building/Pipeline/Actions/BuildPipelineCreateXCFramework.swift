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
            let prefix = "Release-"
            
            var paths: [String: String] = [:]

            let enumerator = filesEnumerator(for: buildConfiguration.buildDirectory.pathString)

            while let url = enumerator?.nextObject() as? URL {
                guard let path = url.canonicalPath else { continue }
                
                let name = path.lastPathComponent
                
                if name.starts(with: prefix) {
                    paths[name.replacingOccurrences(of: prefix, with: "")] = path
                }
            }

            let fManager = FileManager.default
            
            for path in paths.values {
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
            
            for path in paths.values {
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
            
            prepareArtifacts(paths: paths)
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
        
        private func prepareArtifacts(paths: [String: String]) {
            let fManager = FileManager.default
            
            let artifactsExtensions: Set<String> = ["bundle"]
            let artifactsPath = buildConfiguration.artifactsPath
            
            for path in paths {
                let platform = path.key
                let path = path.value
                let platformArtifactsPath = artifactsPath.appending(component: platform)
                
                do {
                    try fManager.createDirectory(at: platformArtifactsPath.asURL, withIntermediateDirectories: true)
                    
                    let enumerator = filesEnumerator(for: path)

                    while let url = enumerator?.nextObject() as? URL {
                        guard let canonicalPath = url.canonicalPath else { continue }
                        
                        if artifactsExtensions.contains(url.pathExtension) {
                            let name = url.lastPathComponent
                            let srcPath = canonicalPath
                            let dstPath = platformArtifactsPath.appending(component: url.lastPathComponent).pathString
                            
                            try fManager.copyItem(atPath: srcPath, toPath: dstPath)
                        }
                    }
                } catch {
                    continue
                }
            }
        }
    }
}
