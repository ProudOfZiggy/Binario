//
//  Dependency.swift
//  
//
//  Created by Nikita Rodionov on 20.11.2022.
//

import TSCBasic
import Foundation

class Dependency {
    let absolutePath: AbsolutePath
    var name: String { absolutePath.basename }
    var binaryName: String { absolutePath.basename + "Binary" }
    
    var hasChecksumSource: Bool {
        return configuration.checksumSource.flatMap { FileManager.default.fileExists(atPath: $0.pathString) } ?? false
    }
    
    var configuration: DependencyConfiguration = .empty
    
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
        
        self.absolutePath = absolutePath
        self.configuration = DependencyConfiguration(dependency: self)
    }
    
    static func at(path: String) -> Dependency? {
        let url = URL(fileURLWithPath: path, isDirectory: true)
        
        return .at(path: url)
    }
    
    static func at(path: URL) -> Dependency? {
        BinarySwiftPackage(path: path) ?? SwiftPackage(path: path) ?? Dependency(path: path)
    }
    
    func resolve() throws {}
}

extension Dependency: Hashable {
    
    static func == (lhs: Dependency, rhs: Dependency) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(absolutePath)
    }
}

extension Array where Element: Dependency {

    init(dependenciesPath: String) {
        let url = URL(fileURLWithPath: dependenciesPath, isDirectory: true)

        if !url.hasDirectoryPath { self = [] }

        let packagesPaths = try? FileManager.default.contentsOfDirectory(at: url,
                                                                         includingPropertiesForKeys: [],
                                                                         options: [.skipsHiddenFiles,
                                                                                   .skipsSubdirectoryDescendants])
        self = packagesPaths?.compactMap { Dependency.at(path: $0) as? Element } ?? []
    }
}
