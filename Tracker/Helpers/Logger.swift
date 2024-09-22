//
//  Logger.swift
//  Tracker
//
//  Created by Aleksei Bondarenko on 22.9.2024.
//

import Foundation

// Перечисление для уровней логирования
enum LogLevel: String {
    case info = "INFO"
    case debug = "DEBUG"
    case warning = "WARNING"
    case error = "ERROR"
}

class Logger {
    
    // Основной метод логирования
    static func log(_ message: String, level: LogLevel = .info, fileID: String = #fileID, functionName: String = #function) {
        let formattedTime = currentTimestamp()
        let fileName = extractFileName(from: fileID)
        
        // Формат вывода лога
        print("[\(formattedTime)] [\(level.rawValue)] [\(fileName)] [\(functionName)] - \(message)")
    }
    
    // Метод для получения текущего времени в формате "dd.MM.yyyy HH:mm:ss"
    private static func currentTimestamp() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        return dateFormatter.string(from: Date())
    }
    
    // Метод для извлечения имени файла из fileID
    private static func extractFileName(from fileID: String) -> String {
        return (fileID as NSString).lastPathComponent.replacingOccurrences(of: ".swift", with: "")
    }
}
