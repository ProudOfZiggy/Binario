//
//  Resolve.swift
//  
//
//  Created by Silvester on 30.07.2022.
//

import Foundation
import ArgumentParser
import PackageModel

struct ResolveCommand: ParsableCommand {
    public static let configuration = CommandConfiguration(commandName: "resolve")

    @Option(name: .long, help: "Directory with packages containing sources.")
    var packages: String

    @Option(name: .long, help: "Target directory to store binary packages.")
    var output: String

    //Just for better semantic
    private var packagesPath: String { packages }
    private var outputPath: String { output }

    mutating func run() throws {
        do {
            // Extract all packages
            let packages: [Package] = .init(packagesPath: packagesPath)

            if packages.isEmpty {
                print("No packages at \(packagesPath.canonicalPath ?? "")")
                return
            }
            
            let oldStorage = PackagesChecksumsCacheStorage(packagesPath: packagesPath)
            oldStorage.migrateToInPackageStorage(packages: packages)
            
            print("Found packages: \(packages)")

            // Attempt to resolve all packages
            let resolvedPackages = try resolve(packages: packages)

            if resolvedPackages.isEmpty {
                print("No resolved packages produced at \(packagesPath.canonicalPath ?? "")")
                return
            }

            // Figuring out what packages need to be build or re-build
            let packagesToBuild = packagesToBuild(packages: resolvedPackages)

            if packagesToBuild.isEmpty {
                print("All binaries up to date.")
                return
            }

            // Building packages that need to be build
            let builtPackages = build(packages: packagesToBuild)

            // Generating binaries from built packages
            let generatedPackages = generateBinaries(packages: builtPackages)

            // Caching newly build/generated packages and re-caching packages that no need to build
            let packagesToCache = Set(resolvedPackages).symmetricDifference(packagesToBuild).union(generatedPackages)
            let cachedPackages = cacheChecksum(packages: Array(packagesToCache))

            // Segregating packages into arrays by failure reason
            let failedToBuild = Set(packagesToBuild).symmetricDifference(builtPackages)
            let failedToGenerate = Set(builtPackages).symmetricDifference(generatedPackages)
            let failedToCache = Set(cachedPackages).symmetricDifference(packagesToCache)

            let hasErrors = [failedToBuild, failedToGenerate, failedToCache].contains { !$0.isEmpty }

            if hasErrors {
                print("Finished with errors.")
                printFailureReason("Unable to build:", packages: Array(failedToBuild))
                printFailureReason("Unable to generate binaries:", packages: Array(failedToGenerate))
                printFailureReason("Unable to cache:", packages: Array(failedToCache))
                print("Check reasons in logs")
                return
            }
            print("Successfully finished.")

            /* -----------------------------------------------*/
        } catch let error {
            print("Unable to fetch packages in sources_path \"\(output)\"")
            print("Reason: \(error.localizedDescription)")
        }
    }

    private func resolve(packages: [Package]) throws -> [Package] {
        var resolvedPackages: [Package] = []

        for package in packages {
            print("Resolving \(package.name)")
            try package.resolve()

            // Need to support packages w/o dependencies (e.g. no generated Package.resolved)
            if package.hasResolvedCache {
                resolvedPackages.append(package)
            } else {
                print("Skipping \(package.name) package. No Package.resolved found.")
            }
        }
        return resolvedPackages
    }

    private func packagesToBuild(packages: [Package]) -> [Package] {
        let checksumsCache = Set(packages.compactMap { PackageChecksumCache(package: $0).read() })

        if checksumsCache.isEmpty { return packages }

        var packagesToBuild: [Package] = []
        let binaryPackages: [BinaryPackage] = .init(packagesPath: outputPath).filter { $0.isValid }
        let binaryPackageNames = Set(binaryPackages.map { $0.name })

        for package in packages {
            if !binaryPackageNames.contains(package.binaryName) {
                packagesToBuild.append(package)
                continue
            }

            guard let checksum = try? package.resolvedChecksum else {
                packagesToBuild.append(package)
                continue
            }

            if !checksumsCache.contains(checksum) {
                packagesToBuild.append(package)
            }
        }
        return packagesToBuild
    }

    private func build(packages: [Package]) -> [Package] {
        var builtPackages: [Package] = []

        for package in packages {
            let configuration = PackageBuildConfiguration(package: package)
            let pipeline = BuildPipeline(buildConfiguration: configuration)

            do {
                try pipeline.run()
                builtPackages.append(package)
            } catch let error {
                print("Unable to build package \"\(package)\"")
                print("Reason: \(error.localizedDescription)")
                continue
            }
        }
        return builtPackages
    }

    private func generateBinaries(packages: [Package]) -> [Package] {
        var generatedPackages: [Package] = []

        for package in packages {
            let configuration = PackageBuildConfiguration(package: package)

            let generator = BinaryPackageGenerator(packageName: package.name,
                                                   binariesPath: outputPath,
                                                   frameworksPath: configuration.xcFrameworksOutputPath.pathString)


            do {
                try generator.gerenate()
                generatedPackages.append(package)
            } catch let error {
                print("Unable to generate pinary package for \"\(package)\"")
                print("Reason: \(error.localizedDescription)")
                continue
            }
        }
        return generatedPackages
    }

    private func cacheChecksum(packages: [Package]) -> [Package] {
        var cachedPackages: [Package] = []

        var checksums: [PackageChecksum] = []

        for package in packages {
            if let checksum = try? package.resolvedChecksum {
                checksums.append(checksum)
                cachedPackages.append(package)
            }
        }

        let cache = PackagesChecksumsCacheStorage(packagesPath: packagesPath)
        cache.write(checksums: checksums)

        return cachedPackages
    }

    private func printFailureReason(_ reason: String, packages: [Package]) {
        if packages.isEmpty { return }

        print(reason)

        for package in packages {
            print("\(package.name) at path: \(package.absolutePath)")
        }
    }
}
