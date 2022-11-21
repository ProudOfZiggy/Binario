//
//  PackageChecksumCache.swift
//  
//
//  Created by Nikita Rodionov on 01.11.2022.
//

import Foundation

class PackageChecksumCache {
    private let dependency: Dependency
    private let fileName = ".package.checksum.binario"
    
    private var filePath: URL { dependency.absolutePath.appending(component: fileName).asURL }
    
    var isEmpty: Bool {
        !FileManager.default.fileExists(atPath: filePath.absoluteString)
    }
    
    init(dependency: Dependency) {
        self.dependency = dependency
    }
    
    func read() -> PackageChecksum? {
        guard let checksum = try? String(contentsOf: filePath, encoding: .utf8) else {
            return nil
        }
        return PackageChecksum(packageName: dependency.name, value: checksum)
    }
    
    @discardableResult
    func write(checksum: PackageChecksum) -> Bool {
        do {
            try checksum.value.write(to: filePath, atomically: true, encoding: .utf8)
            return true
        } catch {
            return false
        }
    }
    
    func clean() {
        try? FileManager.default.removeItem(at: filePath)
    }
    
    static func clean(dependencies: [Dependency]) {
        dependencies.forEach {
            let cache = PackageChecksumCache(dependency: $0)
            cache.clean()
        }
    }
}
