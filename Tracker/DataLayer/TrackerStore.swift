//
//  TrackerStore.swift
//  Tracker
//
//  Created by Aleksei Bondarenko on 3.10.2024.
//

import Foundation
import CoreData

final class TrackerStore {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // Метод для добавления нового трекера
    func addTracker(_ tracker: Tracker) throws {
        let trackerEntity = TrackerCoreData(context: context)
        
        trackerEntity.id = tracker.id
        trackerEntity.name = tracker.name
        trackerEntity.color = UIColorMarshalling().hexString(from: tracker.color)
        trackerEntity.emoji = tracker.emoji
        trackerEntity.schedule = tracker.schedule.map { $0.rawValue } as NSObject
        trackerEntity.trackerType = tracker.trackerType == .habit ? "habit" : "irregular"
        try context.save()
    }
    
    // Новый метод: Получение трекера по id
    func getTracker(by id: UUID) throws -> Tracker? {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        if let entity = try context.fetch(request).first {
            guard let id = entity.id,
                  let name = entity.name,
                  let colorHex = entity.color,  // Разворачиваем значение цвета
                  let emoji = entity.emoji else { return nil }
            
            let color = UIColorMarshalling().color(from: colorHex)
            
            // Извлекаем schedule как массив строк и преобразуем обратно в Weekday
            let scheduleRaw = entity.schedule as? [String] ?? []
            let schedule = scheduleRaw.compactMap { Weekday(rawValue: $0) }
            
            let trackerType = entity.trackerType == "habit" ? TrackerType.habit : TrackerType.irregular
            
            return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule, trackerType: trackerType)
        }
        
        return nil
    }
    
    // Метод для получения всех трекеров
    func getAllTrackers() throws -> [Tracker] {
        let request = TrackerCoreData.fetchRequest()
        let results = try context.fetch(request)
        
        return results.compactMap { entity in
            // Безопасно разворачиваем обязательные поля
            guard let id = entity.id,
                  let name = entity.name,
                  let colorHex = entity.color,
                  let emoji = entity.emoji else {
                Logger.log("Значения для трекера - nil в базе данных", level: .error)
                return nil
            }
            
            // Конвертируем цвет
            let color = UIColorMarshalling().color(from: colorHex)
            
            // Извлекаем schedule как массив строк и преобразуем обратно в Weekday
            let scheduleRaw = entity.schedule as? [String] ?? []
            let schedule = scheduleRaw.compactMap { Weekday(rawValue: $0) }
            
            // Определяем тип трекера
            let trackerType = entity.trackerType == "habit" ? TrackerType.habit : TrackerType.irregular
            
            // Возвращаем объект Tracker
            return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule, trackerType: trackerType)
        }
    }
    
    // Метод для удаления трекера
    func deleteTracker(_ tracker: Tracker) throws {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        if let result = try context.fetch(request).first {
            context.delete(result)
            try context.save()
        }
    }
    
    // Новый метод: Удаление всех трекеров
    func deleteAllTrackers() throws {
        let request = TrackerCoreData.fetchRequest()
        let results = try context.fetch(request)
        results.forEach { context.delete($0) }
        try context.save()
    }
    
}

