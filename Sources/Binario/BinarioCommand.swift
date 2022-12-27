//
//  BinarioCommand.swift
//  
//
//  Created by Silvester on 31.07.2022.
//

import ArgumentParser

public struct BinarioCommand: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "binario",
        abstract: "A Swift command-line tool manage binaries",
        version: "0.9.4",
        subcommands: [ResolveCommand.self,
                      ChecksumCommand.self,
                      PackagesListCommand.self,
                      BuildCommand.self]
    )

    public init() { }
}
