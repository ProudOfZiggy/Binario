//
//  PackageChecksumEvaluator.swift
//  
//
//  Created by Silvester on 31.07.2022.
//

import Foundation
import CryptoKit
import TSCBasic

class PackageChecksumEvaluator {

    func evaluateChecksum(dependency: Dependency) throws -> PackageChecksum? {
        guard let checksumSource = dependency.configuration.checksumSource else {
            return PackageChecksum(packageName: dependency.name, value: "-")
        }
        
        guard let input = try? FileHandle(forReadingFrom: checksumSource.asURL) else {
            throw "File not found: \(checksumSource)"
        }

        var hasher = CryptoKit.SHA256()
        let length = 8192

        while true {
            let data = input.readData(ofLength: length)

            if data.count <= 0 { break }

            hasher.update(data: data)
        }
        let checksum = hasher.finalize().compactMap { String(format: "%02x", $0) }.joined()
        return PackageChecksum(packageName: dependency.name, value: checksum)
    }
}

extension Dependency {

    var resolvedChecksum: PackageChecksum? {
        get throws {
            let eval = PackageChecksumEvaluator()
            return try eval.evaluateChecksum(dependency: self)
        }
    }
}
