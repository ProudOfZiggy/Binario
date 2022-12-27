//
//  File.swift
//  
//
//  Created by Silvester on 03.08.2022.
//

import Foundation
import TSCBasic
import PackageModel

class BinaryPackageGenerator {
    let sourceDependency: Dependency
    let binariesPath: String
    let frameworksPath: String

    init(sourceDependency: Dependency,
         binariesPath: String,
         frameworksPath: String) {
        self.sourceDependency = sourceDependency
        self.binariesPath = binariesPath
        self.frameworksPath = frameworksPath
    }

    func gerenate() throws {
        let binaryPackageName = "\(sourceDependency.name)Binary"
        let binaryPackagePath = "\(binariesPath)/\(binaryPackageName)"
        let binaryPackageFrameworksPath = binaryPackagePath
        let sourcesPath = "\(binaryPackagePath)/Sources/\(binaryPackageName)"
        
        let fManager = FileManager.default
        
        try? fManager.removeItem(atPath: binaryPackagePath)
        try fManager.createDirectory(atPath: sourcesPath,
                                     withIntermediateDirectories: true,
                                     attributes: nil)
        fManager.createFile(atPath: "\(sourcesPath)/Dummy.swift", contents: nil)
        
        let frameworksURL = URL(fileURLWithPath: frameworksPath, isDirectory: true)
        
        let enumerator = fManager.enumerator(at: frameworksURL,
                                             includingPropertiesForKeys: [],
                                             options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants],
                                             errorHandler: nil)
        
        while let url = enumerator?.nextObject() as? URL {
            let name = url.lastPathComponent
            
            if url.pathExtension == "xcframework" || sourceDependency.configuration.includeFiles.contains(name) || name == "artifacts" {
                try fManager.copyItem(at: url,
                                      to: URL(fileURLWithPath: "\(binaryPackageFrameworksPath)/\(name)",
                                              isDirectory: true))
            }
        }

        let manifestPath = "\(binaryPackagePath)/Package.swift"

        let binaryPackageFrameworksURL = URL(fileURLWithPath: binaryPackageFrameworksPath, isDirectory: true)

        let frameworks = try fManager.contentsOfDirectory(at: binaryPackageFrameworksURL,
                                                          includingPropertiesForKeys: [],
                                                          options: [.skipsHiddenFiles,
                                                                    .skipsSubdirectoryDescendants])
            .filter { $0.pathExtension == "xcframework" }
            .compactMap { URL(string: $0.lastPathComponent) }

        let targets = [binaryPackageName] + frameworks.map { $0.deletingPathExtension().lastPathComponent }
        
        let product = try ProductDescription(name: binaryPackageName,
                                             type: .library(.automatic),
                                             targets: targets)

        let mainTarget = try TargetDescription(name: binaryPackageName)
        let binaryTargets = try frameworks.map {
            try TargetDescription(name: $0.deletingPathExtension().lastPathComponent,
                                  path: "\($0)",
                                  type: .binary)
        }

        let manifest = Manifest(displayName: binaryPackageName,
                                path: .init("/"),
                                packageKind: .localSourceControl(.init("/")),
                                packageLocation: "/",
                                platforms: [],
                                toolsVersion: .current,
                                dependencies: [],
                                products: [product],
                                targets: [mainTarget] + binaryTargets)
        let manifestContent = try manifest.generateManifestFileContents()

        fManager.createFile(atPath: manifestPath,
                            contents: manifestContent.data(using: .utf8),
                            attributes: nil)
    }
}
