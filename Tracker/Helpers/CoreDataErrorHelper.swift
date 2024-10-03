//
//  CoreDataErrorHelper.swift
//  Tracker
//
//  Created by Aleksei Bondarenko on 1.10.2024.
//

import Foundation
import CoreData

class CoreDataErrorHelper {
    static func handlePersistentStoreError(error: NSError) {
        // Вызов методов для обработки конкретных типов ошибок
        handleFileSystemError(error: error)
        handlePermissionError(error: error)
        handleOutOfSpaceError(error: error)
        Logger.log("Не удалось загрузить хранилище: \(error), \(error.userInfo)", level: .error)
    }
    
    // Логика, связанная с файловыми ошибками
    private static func handleFileSystemError(error: NSError) {
        if error.domain == NSCocoaErrorDomain {
            switch error.code {
            case NSPersistentStoreIncompatibleVersionHashError:
                Logger.log("Ошибка: неподдерживаемая версия хранилища", level: .error)
            case NSPersistentStoreIncompatibleSchemaError:
                Logger.log("Ошибка: неподдерживаемая версия схемы. Обновите приложение или базу данных", level: .error)
            default:
                Logger.log("Неизвестная ошибка файловой системы: \(error.localizedDescription)", level: .error)
            }
        }
    }
    
    // Логика обработки прав доступа
    private static func handlePermissionError(error: NSError) {
        if error.code == NSFileReadNoPermissionError || error.code == NSFileWriteNoPermissionError {
            Logger.log("Ошибка: недостаточно прав для чтения/записи файла. Проверьте права доступа.", level: .error)
        }
    }
    
    // Логика обработки ошибок нехватки места
    private static func handleOutOfSpaceError(error: NSError) {
        if error.code == NSFileWriteOutOfSpaceError {
            Logger.log("Ошибка: на устройстве недостаточно места. Освободите место для базы данных.", level: .error)
        }
    }
}
