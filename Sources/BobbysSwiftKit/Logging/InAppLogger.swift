//
//  InAppLogger.swift
//  GitGo
//
//  Created by Bobby Skinner on 3/10/25.
//

import Foundation

public class InAppLoggerNode: Identifiable, Codable
{
    public var id: UUID = UUID()
    public var timestamp: Date = Date()
    public var message: String = ""
    public var level: String = ""
    public var icon: String = ""
}

public class InAppLogger
{
    public static var shared = InAppLogger()
    public var max: Int = 200
    public var nodes: [InAppLoggerNode] = []
    
    public func log(_ message: String)
    {
        print("InAppLogger: \(message)")
    }
    
    public func standardLoggerDestination(_ logger: Logger, _ message: String, _ level: String )
    {
        let node = InAppLoggerNode()
        node.message = message
        node.level = level
        node.icon = logger.icons[level] ?? "🟢"
        
        nodes.append( node )
        
        while nodes.count > max
        {
            nodes.removeFirst()
        }
    }
}
