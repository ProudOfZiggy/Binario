//
//  File.swift
//  
//
//  Created by Silvester on 08.08.2022.
//

import TSCBasic
import Foundation

class Package {
    let absolutePath: AbsolutePath
    var name: String { absolutePath.basename }
    var binaryName: String { absolutePath.basename + "Binary" }

    var manifestPath: AbsolutePath { absolutePath.appending(component: "Package.swift") }
    var resolvedPath: AbsolutePath { absolutePath.appending(component: "Package.resolved") }

    var hasResolvedCache: Bool { FileManager.default.fileExists(atPath: resolvedPath.pathString) }
    var hasManifest: Bool { FileManager.default.fileExists(atPath: manifestPath.pathString) }

    convenience init?(path: String) {
        self.init(path: URL(fileURLWithPath: path, isDirectory: true))
    }

    convenience required init?(path: URL) {
        guard let canonicalPath = path.canonicalPath else {
            return nil
        }

        self.init(absolutePath: AbsolutePath(canonicalPath))
    }

    init?(absolutePath: AbsolutePath) {
        if !absolutePath.asURL.hasDirectoryPath { return nil }

        let packageManifest = absolutePath.appending(component: "Package.swift")
        if !FileManager.default.fileExists(atPath: packageManifest.pathString) { return nil }

        self.absolutePath = absolutePath
    }
}

extension Array where Element: Package {

    init(packagesPath: String) {
        let url = URL(fileURLWithPath: packagesPath, isDirectory: true)

        if !url.hasDirectoryPath { self = [] }

        let packagesPaths = try? FileManager.default.contentsOfDirectory(at: url,
                                                                         includingPropertiesForKeys: [],
                                                                         options: [.skipsHiddenFiles,
                                                                                   .skipsSubdirectoryDescendants])
        self = packagesPaths?.compactMap { Self.Element(path: $0) } ?? []
    }
}

extension Package: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return name
    }

    public var debugDescription: String {
        return "\nName: \(name)\nPath: \(absolutePath)\n"
    }
}

extension Package: Hashable {
    
    static func == (lhs: Package, rhs: Package) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(absolutePath)
    }
}
