//
//  DependencyConfiguration.swift
//  
//
//  Created by Nikita Rodionov on 20.11.2022.
//

import Foundation
import TSCBasic

struct DependencyConfiguration: Decodable {
    private var _checksumSource: String?
    var checksumSource: AbsolutePath?
    
    static var empty: DependencyConfiguration { DependencyConfiguration() }
    
    enum CodingKeys: CodingKey {
        case checksumSource
    }
    
    private init() {}
    
    init(dependency: Dependency) {
        let fileName = "config.binario"
        let decoder = JSONDecoder()
        
        let path = dependency.absolutePath.appending(component: fileName)
        let data = try? Data(contentsOf: path.asURL)
        
        self = data.flatMap { try? decoder.decode(Self.self, from: $0) } ?? .empty
        
        if let checksumSource = self._checksumSource {
            self.checksumSource = AbsolutePath(checksumSource, relativeTo: dependency.absolutePath)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        _checksumSource = try? container.decodeIfPresent(String.self, forKey: .checksumSource)
    }
}
