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
    
    @Option(name: .long,
            help: "Target platforms to build binaries for. Options are \(Platform.allCases.map { $0.rawValue }.joined(separator: ",")).")
    var platforms: String
    
    @Flag(name: .long,
          help: "Allow resolve binaries ignoring cache")
    var ignoreCache: Bool = false

    //Just for better semantic
    private var packagesPath: String { packages }
    private var outputPath: String { output }

    mutating func run() throws {
        do {
            let platforms = Array<Platform>(string: platforms)
            
            if platforms.isEmpty {
                print("No platforms specified. Options are \(Platform.allCases)")
                return
            }
            
            // Extract all packages
            let packages: [Dependency] = .init(dependenciesPath: packagesPath)

            if packages.isEmpty {
                print("No packages at \(packagesPath.canonicalPath ?? "")")
                return
            }
            
            let oldStorage = PackagesChecksumsCacheStorage(packagesPath: packagesPath)
            
            if ignoreCache {
                oldStorage.clean()
                PackageChecksumCache.clean(dependencies: packages)
            } else {
                oldStorage.migrateToInPackageStorage(dependencies: packages)
            }
            
            print("Found packages: \(packages)")

            // Attempt to resolve all packages
            let resolvedPackages = try resolve(dependencies: packages)

            if resolvedPackages.isEmpty {
                print("No resolved packages produced at \(packagesPath.canonicalPath ?? "")")
                return
            }

            // Figuring out what packages need to be build or re-build
            let packagesToBuild = ignoreCache ? resolvedPackages : packagesToBuild(dependencies: resolvedPackages)

            if packagesToBuild.isEmpty {
                print("All binaries up to date.")
                return
            }

            // Building packages that need to be build
            let builtPackages = build(dependencies: packagesToBuild, platforms: platforms)

            // Generating binaries from built packages
            let generatedPackages = generateBinaries(dependencies: builtPackages)

            // Caching newly build/generated packages and re-caching packages that no need to build
            let packagesToCache = Set(resolvedPackages).symmetricDifference(packagesToBuild).union(generatedPackages)
            let cachedPackages = cacheChecksum(dependencies: Array(packagesToCache))

            // Segregating packages into arrays by failure reason
            let failedToBuild = Set(packagesToBuild).symmetricDifference(builtPackages)
            let failedToGenerate = Set(builtPackages).symmetricDifference(generatedPackages)
            let failedToCache = Set(cachedPackages).symmetricDifference(packagesToCache)

            let hasErrors = [failedToBuild, failedToGenerate, failedToCache].contains { !$0.isEmpty }

            if hasErrors {
                print("Finished with errors.")
                printFailureReason("Unable to build:", dependencies: Array(failedToBuild))
                printFailureReason("Unable to generate binaries:", dependencies: Array(failedToGenerate))
                printFailureReason("Unable to cache:", dependencies: Array(failedToCache))
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

    private func resolve(dependencies: [Dependency]) throws -> [Dependency] {
        var resolvedPackages: [Dependency] = []

        for package in dependencies {
            print("Resolving \(package.name)")
            try package.resolve()

            if package.hasChecksumSource {
                resolvedPackages.append(package)
            } else {
                print("Skipping \(package.name) package. No files for checksum evaluation found.")
            }
        }
        return resolvedPackages
    }

    private func packagesToBuild(dependencies: [Dependency]) -> [Dependency] {
        let checksumsCache = Set(dependencies.compactMap { PackageChecksumCache(dependency: $0).read() })

        if checksumsCache.isEmpty { return dependencies }

        var packagesToBuild: [Dependency] = []
        let binaryPackages: [BinarySwiftPackage] = .init(dependenciesPath: outputPath).filter { $0.isValid }
        let binaryPackageNames = Set(binaryPackages.map { $0.name })

        for dependency in dependencies {
            if !binaryPackageNames.contains(dependency.binaryName) {
                packagesToBuild.append(dependency)
                continue
            }

            guard let checksum = try? dependency.resolvedChecksum else {
                packagesToBuild.append(dependency)
                continue
            }

            if !checksumsCache.contains(checksum) {
                packagesToBuild.append(dependency)
            }
        }
        return packagesToBuild
    }

    private func build(dependencies: [Dependency], platforms: [Platform]) -> [Dependency] {
        var builtPackages: [Dependency] = []

        for dependency in dependencies {
            let configuration = PackageBuildConfiguration(dependency: dependency, platforms: platforms)
            let pipeline = BuildPipeline(buildConfiguration: configuration)

            do {
                try pipeline.run()
                builtPackages.append(dependency)
            } catch let error {
                print("Unable to build package \"\(dependency)\"")
                print("Reason: \(error.localizedDescription)")
                continue
            }
        }
        return builtPackages
    }

    private func generateBinaries(dependencies: [Dependency]) -> [Dependency] {
        var generatedPackages: [Dependency] = []

        for dependency in dependencies {
            let configuration = PackageBuildConfiguration(dependency: dependency, platforms: [])

            let generator = BinaryPackageGenerator(sourceDependency: dependency,
                                                   binariesPath: outputPath,
                                                   frameworksPath: configuration.xcFrameworksOutputPath.pathString)


            do {
                try generator.gerenate()
                generatedPackages.append(dependency)
            } catch let error {
                print("Unable to generate pinary package for \"\(dependency)\"")
                print("Reason: \(error.localizedDescription)")
                continue
            }
        }
        return generatedPackages
    }

    private func cacheChecksum(dependencies: [Dependency]) -> [Dependency] {
        var cachedPackages: [Dependency] = []

        for dependency in dependencies {
            if let checksum = try? dependency.resolvedChecksum {
                let cache = PackageChecksumCache(dependency: dependency)
                cache.write(checksum: checksum)
                cachedPackages.append(dependency)
            }
        }

        return cachedPackages
    }

    private func printFailureReason(_ reason: String, dependencies: [Dependency]) {
        if dependencies.isEmpty { return }

        print(reason)

        for dependency in dependencies {
            print("\(dependency.name) at path: \(dependency.absolutePath)")
        }
    }
}
