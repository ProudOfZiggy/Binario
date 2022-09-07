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

    func evaluateChecksum(package: Package) throws -> PackageChecksum? {
        guard let input = try? FileHandle(forReadingFrom: package.resolvedPath.asURL) else {
            throw "File not found: \(package.resolvedPath)"
        }

        var hasher = CryptoKit.SHA256()
        let length = 8192

        while true {
            let data = input.readData(ofLength: length)

            if data.count <= 0 { break }

            hasher.update(data: data)
        }
        let checksum = hasher.finalize().compactMap { String(format: "%02x", $0) }.joined()
        return PackageChecksum(packageName: package.name, value: checksum)
    }
}

extension Package {

    var resolvedChecksum: PackageChecksum? {
        get throws {
            let eval = PackageChecksumEvaluator()
            return try eval.evaluateChecksum(package: self)
        }
    }
}
