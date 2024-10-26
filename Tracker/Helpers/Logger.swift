import Foundation

enum LogLevel: String {
    case info = "INFO"
    case debug = "DEBUG"
    case warning = "WARNING"
    case error = "ERROR"
}

final class Logger {
    
    static func log(_ message: String, level: LogLevel = .info, fileID: String = #fileID, functionName: String = #function) {
        let formattedTime = currentTimestamp()
        let fileName = extractFileName(from: fileID)
        
        print("[\(formattedTime)] [\(level.rawValue)] [\(fileName)] [\(functionName)] - \(message)")
    }
    
    private static func currentTimestamp() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        return dateFormatter.string(from: Date())
    }
    
    private static func extractFileName(from fileID: String) -> String {
        return (fileID as NSString).lastPathComponent.replacingOccurrences(of: ".swift", with: "")
    }
}
