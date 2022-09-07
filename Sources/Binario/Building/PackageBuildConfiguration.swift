//
//  PackageBuildConfiguration.swift
//  
//
//  Created by Silvester on 10.08.2022.
//

import Foundation
import TSCBasic

struct PackageBuildConfiguration {
    let package: Package

    var packageName: String { package.name }
    var buildDirectory: AbsolutePath { package.absolutePath.appending(component: ".build") }
    var archivesPath: AbsolutePath { buildDirectory.appending(component: "archives") }
    var xcodeproj: AbsolutePath { package.absolutePath.appending(component: "\(packageName).xcodeproj") }
    var xcFrameworksOutputPath: AbsolutePath { buildDirectory.appending(component: "xcframeworks") }
}
