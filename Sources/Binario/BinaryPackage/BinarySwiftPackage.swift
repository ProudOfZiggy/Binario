//
//  BinarySwiftPackage.swift
//  
//
//  Created by Silvester on 03.08.2022.
//

import Foundation
import TSCBasic

class BinarySwiftPackage: SwiftPackage {
    override var binaryName: String { name }

    var hasFrameworks: Bool {
        guard let enumerator = FileManager.default.enumerator(at: absolutePath.asURL,
                                                              includingPropertiesForKeys: nil,
                                                              options: [.skipsSubdirectoryDescendants,
                                                                        .skipsHiddenFiles]) else {
            return false
        }
        for url in enumerator {
            if (url as? URL)?.pathExtension == "xcframework" { return true }
        }
        return false
    }

    var isValid: Bool { hasFrameworks }
    
    override init?(absolutePath: AbsolutePath) {
        super.init(absolutePath: absolutePath)
        
        if !isValid { return nil }
    }
    
    override func resolve() throws {}
}
