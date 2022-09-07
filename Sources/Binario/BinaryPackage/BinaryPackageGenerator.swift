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
    let packageName: String
    let binariesPath: String
    let frameworksPath: String

    init(packageName: String,
         binariesPath: String,
         frameworksPath: String) {
        self.packageName = packageName
        self.binariesPath = binariesPath
        self.frameworksPath = frameworksPath
    }

    func gerenate() throws {
        let binaryPackageName = "\(packageName)Binary"
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
            if url.pathExtension == "xcframework" {
                let name = url.lastPathComponent
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
        debugPrint(targets)
        let product = ProductDescription(name: binaryPackageName,
                                         type: .library(.automatic),
                                         targets: targets)

        let mainTarget = try TargetDescription(name: binaryPackageName)
        let binaryTargets = try frameworks.map {
            try TargetDescription(name: $0.deletingPathExtension().lastPathComponent,
                                  path: "\($0)",
                                  type: .binary)
        }

        let manifest = Manifest(name: binaryPackageName,
                                path: .init("/"),
                                packageKind: .local,
                                packageLocation: "/",
                                platforms: [],
                                toolsVersion: .currentToolsVersion,
                                dependencies: [],
                                products: [product],
                                targets: [mainTarget] + binaryTargets)
        let manifestContent = try manifest.generateManifestFileContents()

        fManager.createFile(atPath: manifestPath,
                            contents: manifestContent.data(using: .utf8),
                            attributes: nil)
    }
}
