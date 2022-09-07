//
//  PackagesChecksumsCacheStorage.swift
//  
//
//  Created by Silvester on 31.07.2022.
//

import Foundation

class PackagesChecksumsCacheStorage {
    let packagesPath: String

    private let cacheFileName = ".packages.resolved.checksums"

    init(packagesPath: String) {
        self.packagesPath = packagesPath
    }

    func read() -> [PackageChecksum]? {
        let url = cacheFileURL()

        do {
            let data = try Data(contentsOf: url)
            let cache = try JSONDecoder().decode([String: String].self, from: data)
            return cache.map { PackageChecksum(packageName: $0, value: $1) }
        } catch {
            return nil
        }
    }

    @discardableResult
    func write(checksums: [PackageChecksum]) -> Bool {
        let cache = checksums.reduce([:]) { result, element in
            result.merging([element.packageName: element.value],
                           uniquingKeysWith: { $1 })
        }

        do {
            let data = try JSONEncoder().encode(cache)
            try data.write(to: cacheFileURL())
            return true
        } catch {
            return false
        }
    }

    func clean() {
        try? FileManager.default.removeItem(at: cacheFileURL())
    }

    private func cacheFileURL() -> URL {
        let url = URL(fileURLWithPath: packagesPath,
                      isDirectory: true).appendingPathComponent(cacheFileName)
        return url
    }
}
