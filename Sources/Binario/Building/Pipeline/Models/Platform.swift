//
//  File.swift
//  
//
//  Created by Nikita Rodionov on 01.11.2022.
//

import Foundation
import ArgumentParser

enum Platform: String, CaseIterable {
    case iOS
    case iOSSimulator
    
    var destination: String {
        switch self {
        case .iOS: return "generic/platform=iOS"
        case .iOSSimulator: return "generic/platform=iOS Simulator"
        }
    }
    
    var buildName: String {
        switch self {
        case .iOS: return "iphoneos"
        case .iOSSimulator: return "iphonesimulator"
        }
    }
    
    init?(libraryPlatform: String) {
        switch libraryPlatform {
        case "ios": self = .iOS
        case "iossimulator": self = .iOSSimulator
        default: return nil
        }
    }
}

extension Array where Element == Platform {
    
    init(string: String) {
        self = string
            .components(separatedBy: " ")
            .compactMap {
                let platform = Platform(rawValue: $0)
                
                if platform == nil {
                    print("Unknown platform \($0)")
                }
                return platform
            }
        
    }
}
