//
//  BuildPipelineExtractXCFrameworksBundles.swift
//  
//
//  Created by Nikita Rodionov on 19.02.2023.
//

import Foundation
import TSCBasic

extension BuildPipeline {

    class ExtractXCFrameworksBundles: BuildPipelineAction {

        override func run() throws {
            let fManager = FileManager.default

            let enumerator = filesEnumerator(for: buildConfiguration.xcFrameworksOutputPath.pathString)
            
            var xcframeworks: [AbsolutePath] = []
            
            while let url = enumerator?.nextObject() as? URL {
                if url.pathExtension == "xcframework" {
                    url.canonicalPath.map { xcframeworks.append(AbsolutePath($0)) }
                }
            }
            
            var platformsBundles: [Platform: [String]] = [:]
            
            for path in xcframeworks {
                let plistParser = XCFrameworkInfoPlistParser(path: path)
                
                guard let plist = plistParser.plist() else { continue }

                
                for library in plist.libraries {
                    let platform = library.platform.flatMap { Platform(libraryPlatform: $0) }
                
                    guard let libID = library.identifier,
                          let libPath = library.path,
                          let platform else { continue }
                    
                    let libFullPath = path.appending(component: libID).appending(component: libPath)
                    
                    if libFullPath.extension != "framework" { continue }
                    
                    let binary = libFullPath.appending(component: libFullPath.basenameWithoutExt)
                    
                    if fManager.isExecutableFile(atPath: binary.pathString) { continue }
                    
                    platformsBundles[platform, default: []].append(contentsOf: bundles(at: libFullPath))
                }
            }
            
            copyBundles(platformsBundles: platformsBundles)
        }
        
        private func bundles(at path: AbsolutePath) -> [String] {
            let url = URL(fileURLWithPath: path.pathString, isDirectory: true)
            
            let keys: [URLResourceKey] = [.canonicalPathKey]

            let enumerator = FileManager.default.enumerator(at: url,
                                                            includingPropertiesForKeys: keys,
                                                            errorHandler: nil)
            
            var bundles: [String] = []
            
            while let url = enumerator?.nextObject() as? URL {
                if url.pathExtension == "bundle" {
                    
                    url.canonicalPath.map { bundles.append($0) }
                }
            }
            return bundles
        }
        
        private func filesEnumerator(for path: String) -> FileManager.DirectoryEnumerator? {
            let url = URL(fileURLWithPath: path, isDirectory: true)

            let keys: [URLResourceKey] = [.canonicalPathKey]

            return FileManager.default.enumerator(at: url,
                                                  includingPropertiesForKeys: keys,
                                                  options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants],
                                                  errorHandler: nil)
        }
        
        private func copyBundles(platformsBundles: [Platform: [String]]) {
            let fManager = FileManager.default
            
            for platform in platformsBundles {
                let outputPath = buildConfiguration.artifactsPath(for: platform.key)
                
                if !fManager.fileExists(atPath: outputPath.pathString) {
                    do {
                        try fManager.createDirectory(at: outputPath.asURL, withIntermediateDirectories: true)
                    } catch {
                        continue
                    }
                }
                
                for bundle in platform.value {
                    try? fManager.copyItem(atPath: bundle,
                                           toPath: outputPath.appending(component: bundle.lastPathComponent).pathString)
                }
            }
        }
    }
}
