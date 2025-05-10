//
//  StringExtension.swift
//  GitGo
//
//  Created by Bobby Skinner on 3/7/25.
//

import Foundation

public extension String {
    var isEmptyOrWhitespace: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func lset( _ length: Int ) -> String
    {
        if self.count < length {
               return self.padding(toLength: length, withPad: " ", startingAt: 0) // Fill with spaces
           } else {
               return String(self.prefix(length))
           }

    }
}
