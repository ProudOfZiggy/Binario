//
//  String+LocalizedError.swift
//  
//
//  Created by Silvester on 31.07.2022.
//

import Foundation

extension String: LocalizedError {
    public var errorDescription: String? { self }
}
