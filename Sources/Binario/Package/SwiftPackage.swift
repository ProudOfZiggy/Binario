//
//  File.swift
//  
//
//  Created by Silvester on 08.08.2022.
//

import TSCBasic
import Foundation

class SwiftPackage: Dependency {
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

    override init?(absolutePath: AbsolutePath) {
        super.init(absolutePath: absolutePath)
        
        if !FileManager.default.fileExists(atPath: manifestPath.pathString) { return nil }
    }
}

extension SwiftPackage: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return name
    }

    public var debugDescription: String {
        return "\nName: \(name)\nPath: \(absolutePath)\n"
    }
}

extension SwiftPackage: Hashable {
    
    static func == (lhs: SwiftPackage, rhs: SwiftPackage) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(absolutePath)
    }
}
