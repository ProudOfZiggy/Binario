//
//  PackageBuildConfiguration.swift
//  
//
//  Created by Silvester on 10.08.2022.
//

import Foundation
import TSCBasic

struct PackageBuildConfiguration {
    let dependency: Dependency
    let platforms: [Platform]
    
    init(dependency: Dependency, platforms: [Platform] = []) {
        self.dependency = dependency
        self.platforms = platforms
    }
    
    var packageName: String { dependency.name }
    var buildDirectory: AbsolutePath { dependency.absolutePath.appending(component: ".build") }
    var archivesPath: AbsolutePath { buildDirectory.appending(component: "archives") }
    var xcodeproj: AbsolutePath { dependency.absolutePath.appending(component: "\(packageName).xcodeproj") }
    var xcFrameworksOutputPath: AbsolutePath { buildDirectory.appending(component: "xcframeworks") }
    var artifactsPath: AbsolutePath { xcFrameworksOutputPath.appending(component: "artifacts") }
}
