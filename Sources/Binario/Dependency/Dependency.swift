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
    
    var configuration: DependencyConfiguration?
    
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
        self = packagesPaths?.compactMap { Self.Element(path: $0) } ?? []
    }
}
