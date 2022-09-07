//
//  String+PathComponent.swift
//  
//
//  Created by Silvester on 31.07.2022.
//

import Foundation

extension String {
    var lastPathComponent: String { (self as NSString).lastPathComponent }

    var canonicalPath: String? { URL(fileURLWithPath: self).canonicalPath }
}
