//
//  Logger.swift
//  GitGo
//
//  Created by Bobby Skinner on 3/7/25.
//

import Foundation

public enum LogLevel: String
{
    case none = ""
    case error = "ERROR WARNING "
    case info = "ERROR WARNING INFO "
    case commands = "ERROR WARNING INFO COMMAND RESULT "
    case debug = "ERROR WARNING INFO COMMAND RESULT DEBUG "
    case comm = "ERROR WARNING INFO COMMAND RESULT DEBUG COMM "
}

// public static var logger: (( _ request: URLRequest?, _ response: URLResponse?, _ message: String?, _ data: Data?, _ dataString: String?, _ error: Error? ) -> Void)?

public class Logger
{
    nonisolated(unsafe) public static let shared = Logger()
    
    public static let INFO: String = "INFO"
    public static let COMMAND: String = "COMMAND"
    public static let RESULT: String = "RESULT"
    public static let DEBUG: String = "DEBUG"
    public static let WARNING: String = "WARNING"
    public static let ERROR: String = "ERROR"
    public static let COMM: String = "COMM"
    
    public var logLevel: LogLevel = .comm
    
    public var useColor: Bool = false
    
    public var loggerDestinations: [((_ logger: Logger, _ message: String, _ level: String ) -> Void)] = []
    
    public var colors: [String: String] = [
                                            "INFO": "\u{001B}[32m",
                                            "COMMAND": "\u{001B}[36m",
                                            "RESULT": "\u{001B}[35m",
                                            "DEBUG": "\u{001B}[34m",
                                            "WARNING": "\u{001B}[33m",
                                            "ERROR": "\u{001B}[31m"
                                          ]
    public var offString = "\u{001B}[0m"
    
    public var icons: [String: String] = [
                                            "INFO": "⚫",
                                            "COMM": "🟦",
                                            "COMMAND": "🟣",
                                            "RESULT": "🟢",
                                            "DEBUG": "🪲",
                                            "WARNING": "🟡",
                                            "ERROR": "🔴"
                                          ]
    
//    🔴: Large Red Circle (U+1F534)
//    🔵: Large Blue Circle (U+1F535)
//    🟠: Orange Circle (U+1F7E0)
//    🟡: Yellow Circle (U+1F7E1)
//    🟢: Green Circle (U+1F7E2)
//    🟣: Purple Circle (U+1F7E3)
//    🟤: Brown Circle (U+1F7E4)
//    ⚫: Black Circle (U+26AB)
//    
//    Unicode Explorer
//    https://unicode-explorer.com › Symbol Lists
//    Colored Squares ; 🟥. U+1F7E5 ; 🟦. U+1F7E6 ; 🟧. U+1F7E7 ; 🟨. U+1F7E8 ; 🟩. U+1F7E9.
//    Geometric Shapes (Unicode block)
//
//      🪲
//

    public var logComms: Bool = false
    public var logCommData: Bool = false
    public var logCommDataMax: Int = 1 * 512
    public var messageMax: Int = 12 * 1024
    
    public init()
    {
        loggerDestinations.append(standardLoggerDestination)
    }
    
    public func debug(_ message: String)
    {
        log(message, level: Logger.DEBUG)
    }
    
    public func info(_ message: String)
    {
        log(message, level: Logger.INFO)
    }
    
    public func warning(_ message: String)
    {
        log(message, level: Logger.WARNING)
    }
    
    public func command(_ command: String, _ result: String? = nil )
    {
        log( command, level: Logger.COMMAND )
        
        if let result
        {
            log( result, level: Logger.RESULT )
        }
    }
    
    
    public func error(_ message: String)
    {
        log(message, level: Logger.ERROR)
    }
    
    public func error(_ error: Error )
    {
        log( "\(error)", level: Logger.ERROR)
    }
    
    public func comm(_ message: String )
    {
        log(message, level: Logger.COMM )
    }
    
    public func log(_ message: String, level: String = INFO )
    {
        var message = message
        if message.count > messageMax {
            message = String(message.prefix( messageMax )) + "..."
        }
        if logLevel.rawValue.contains(level.uppercased()) {
            for destination in loggerDestinations {
                destination(self, message, level)
            }
        }
    }
    
    public static func getShortDateTimeString( date: Date = Date()) -> String {
        let formatter = DateFormatter() // Create a formatter
        formatter.dateStyle = .short // Use short date style (e.g., MM/dd/yy)
        formatter.timeStyle = .short // Use short time style (e.g., h:mm a)
        
        return formatter.string(from: date) // Format the date and time
    }
    
    public func addLoggerDestination(_ destination: @escaping (Logger, String, String) -> Void )
    {
        loggerDestinations.append(destination)
    }

    public func standardLoggerDestination(_ logger: Logger, _ message: String, _ level: String )
    {
        var lines = message.split(separator: "\n")
        var color = ""
        var off = ""
        let icon = icons[level] ?? "🟢"
        
        if useColor
        {
            color = colors[level] ?? offString
            off = offString
        }
        
        print( "\(Logger.getShortDateTimeString().lset(19)) [\(color)\(level.lset(7))\(off)] \(icon) \(color)\(lines.first ?? "")\(off)")
        
        if lines.count > 0 {
            lines.remove(at: 0 )
            for line in lines
            {
                print( " ".lset(33) + line )
            }
        }
    }
    
    public func logComm( _ request: URLRequest?,
                         _ response: URLResponse?,
                         _ message: String?,
                         _ data: Data?,
                         _ dataString: String?,
                         _ error: Error? )
    {
        if logComms {
            let urlString = request?.url?.absoluteString ?? "<none>"
            var logMessage = "HTTP "
            
            if let method = request?.httpMethod {
                logMessage += "(\(method)) "
            }
            
            logMessage += "\(urlString) "
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                logMessage += "(\(statusCode)) "
            }
            
            if let message {
                logMessage += "\(message) "
            }
            
            if let dataString {
                logMessage += "\(dataString.count) bytes recieved "
            }
            
            if logCommData {
                var commData: String = dataString ?? ""
                
                if commData.isEmpty, let data {
                    commData = String(data: data, encoding: .utf8) ?? ""
                    
                    if commData.isEmpty {
                        commData = data.toHexWithASCII(bytesPerLine: 32 )
                    }
                    
                    if commData.count > logCommDataMax {
                        commData = String( commData.prefix( logCommDataMax ) )
                    }
                }
                
                if !commData.isEmpty {
                    if commData.count > logCommDataMax {
                        commData = String( commData.prefix( logCommDataMax ) )
                    }
                    logMessage += "\n\(commData)"
                }
            }
            
            comm( logMessage )
        }
    }
}

extension Data {
    func toHexWithASCII(bytesPerLine: Int = 32) -> String {
        var result = ""
        
        // Iterate through the data in chunks of bytesPerLine
        for offset in stride(from: 0, to: self.count, by: bytesPerLine)
        {
            // Take the current chunk of bytes
            let chunk = self.dropFirst(offset).prefix(bytesPerLine)
            
            // Convert the bytes to hex
            let hexBytes = chunk.map { String(format: "%02X", $0) }.joined(separator: " ")
            
            // Convert the bytes to ASCII, replacing non-printable characters with `.`
            let asciiBytes = chunk.map { byte -> String in
                let scalar = Unicode.Scalar(byte)
                
                if scalar.isASCII && ( byte >= 32 && byte <= 126 ) // && scalar.properties.printable
                {
                    return String(scalar)
                }
                else
                {
                    return "."
                }
            }.joined()
            
            // Format the line and append it to the result
            result += String(format: "%-96s | %s", hexBytes, asciiBytes) + "\n"
        }
        
        return result
    }
}

