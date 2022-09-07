//
//  File.swift
//  
//
//  Created by Silvester on 08.08.2022.
//

import Foundation

extension URL {
    var canonicalPath: String? {
        try? self.resourceValues(forKeys: [.canonicalPathKey]).canonicalPath
    }
}
