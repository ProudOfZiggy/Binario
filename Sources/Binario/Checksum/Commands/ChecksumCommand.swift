//
//  ChecksumCommand.swift
//  
//
//  Created by Silvester on 31.07.2022.
//

import Foundation
import ArgumentParser

struct ChecksumCommand: ParsableCommand {
    public static let configuration = CommandConfiguration(commandName: "checksum",
                                                           subcommands: [Clean.self, Evaluate.self, Write.self],
                                                           defaultSubcommand: Evaluate.self)
}




