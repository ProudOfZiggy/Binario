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
