//
//  OutputRedirection+Pretty.swift
//  
//
//  Created by Silvester on 31.07.2022.
//

import Foundation
import TSCBasic

extension TSCBasic.Process.OutputRedirection {
    static var pretty: Self {
        Process.OutputRedirection.stream(stdout: { print(String(data: Data($0), encoding: .utf8) ?? "") },
                                         stderr: { _ in },
                                         redirectStderr: true)
    }
}
