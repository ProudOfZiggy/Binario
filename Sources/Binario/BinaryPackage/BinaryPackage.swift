//
//  BinaryPackage.swift
//  
//
//  Created by Silvester on 03.08.2022.
//

import Foundation

class BinaryPackage: Package {
    override var binaryName: String { name }

    var hasXCFrameworks: Bool {
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

    var isValid: Bool { hasXCFrameworks }
}
