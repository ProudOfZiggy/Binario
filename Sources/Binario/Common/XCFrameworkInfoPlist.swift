//
//  XCFrameworkInfoPlist.swift
//  
//
//  Created by Nikita Rodionov on 20.02.2023.
//

import Foundation
import TSCBasic

struct XCFrameworkInfoPlist: Decodable {
    var libraries: [Library]
    
    private enum CodingKeys : String, CodingKey {
        case libraries = "AvailableLibraries"
    }
}

extension XCFrameworkInfoPlist {
    
    struct Library: Decodable {
        var identifier: String?
        var os: String?
        var variant: String?
        var path: String?
        
        var platform: String? { [os, variant].compactMap { $0 }.joined() }
        
        private enum CodingKeys: String, CodingKey {
            case identifier = "LibraryIdentifier"
            case os = "SupportedPlatform"
            case variant = "SupportedPlatformVariant"
            case path = "LibraryPath"
        }
    }
}

class XCFrameworkInfoPlistParser {
    private var path: AbsolutePath
    
    init(path: AbsolutePath) {
        self.path = path.appending(component: "Info.plist")
    }
    
    func plist() -> XCFrameworkInfoPlist? {
        guard let data = try? Data(contentsOf: path.asURL) else { return nil }
        
        let decoder = PropertyListDecoder()
        return try? decoder.decode(XCFrameworkInfoPlist.self, from: data)
    }
}
