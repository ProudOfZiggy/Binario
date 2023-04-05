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
    /*
     Seed can be changed if there was a breaking changes in Binario.
     In this case we must be sure that all dependencies adapted new changes after updating Binario.
     In most cases seed is equal to last version that contains breaking changes.
    */
    private let seed: Int? = 0_9_45
    
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
        
        if var seed {
            let data = withUnsafeBytes(of: &seed, { Data($0) })
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
