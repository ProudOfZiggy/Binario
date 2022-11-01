//
//  PackageChecksumCache.swift
//  
//
//  Created by Nikita Rodionov on 01.11.2022.
//

import Foundation

class PackageChecksumCache {
    private let package: Package
    private let fileName = ".package.checksum.binario"
    
    private var filePath: URL { package.absolutePath.appending(component: fileName).asURL }
    
    init(package: Package) {
        self.package = package
    }
    
    func read() -> PackageChecksum? {
        guard let checksum = try? String(contentsOf: filePath, encoding: .utf8) else {
            return nil
        }
        return PackageChecksum(packageName: package.name, value: checksum)
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
}
