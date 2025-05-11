//
//  AnyObjectHelper.swift
//  BobbysSwiftKit
//
//  Created by Bobby Skinner on 5/10/25.
//

import Foundation

public class AnyObjectHelper
{
    public static func getMemoryAddressAsString( _ obj: AnyObject ) -> String {
        let address = Unmanaged.passUnretained( obj ).toOpaque()
        return String( describing: address )
    }
}
