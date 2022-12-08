//
//  File.swift
//  
//
//  Created by Silvester on 08.08.2022.
//

import TSCBasic
import Foundation

class SwiftPackage: Dependency {
    var manifestPath: AbsolutePath { absolutePath.appending(component: "Package.swift") }
    var resolvedPath: AbsolutePath { absolutePath.appending(component: "Package.resolved") }

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
        
        configuration.checksumSource = configuration.checksumSource ?? resolvedPath
    }
    
    override func resolve() throws {
        let resolver = PackagesResolver()
        try resolver.resolve(package: self)
        
        isResolved = true
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
