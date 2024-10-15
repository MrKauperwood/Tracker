//
//  TrackerStore.swift
//  Tracker
//
//  Created by Aleksei Bondarenko on 3.10.2024.
//

import Foundation
import CoreData

// Протокол для передачи обновлений в контроллер
protocol TrackerStoreDelegate: AnyObject {
    func store(_ store: TrackerStore, didUpdate update: TrackerStoreUpdate)
}

// Структура для передачи информации об изменениях
struct TrackerStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

final class TrackerStore: NSObject {
    // Контекст Core Data
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    
    // Делегат для передачи обновлений в контроллер
    weak var delegate: TrackerStoreDelegate?
    
    // Индексы для отслеживания изменений
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerStoreUpdate.Move>?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    // Настройка NSFetchedResultsController
    private func setupFetchedResultsController() {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Ошибка при выборке трекеров: \(error)")
        }
    }
    
    // Получение всех трекеров из Core Data
    var trackers: [Tracker] {
        guard let objects = fetchedResultsController.fetchedObjects else { return [] }
        return objects.compactMap { self.tracker(from: $0) }
    }
    
    // Метод для добавления нового трекера
    func addTracker(_ tracker: Tracker, to category: TrackerCategory) throws {
        let trackerEntity = TrackerCoreData(context: context)
        
        trackerEntity.id = tracker.id
        trackerEntity.name = tracker.name
        trackerEntity.color = UIColorMarshalling().hexString(from: tracker.color)
        trackerEntity.emoji = tracker.emoji
        
        // Сохраняем schedule как массив строк, который будет автоматически преобразован трансформером
        trackerEntity.schedule = tracker.schedule.map { $0.rawValue } as NSObject
        trackerEntity.trackerType = tracker.trackerType == .habit ? "habit" : "irregular"
        
        // Проверка на существование категории
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", category.title)
        
        if let existingCategory = try context.fetch(fetchRequest).first {
            trackerEntity.category = existingCategory
        } else {
            // Создаем новую категорию, если не найдена существующая
            let categoryEntity = TrackerCategoryCoreData(context: context)
            categoryEntity.title = category.title
            trackerEntity.category = categoryEntity
        }
        try context.save()
        
        Logger.log("Новый трекер c именем : \"\(tracker.name)\" и категорией \"\(category.title)\" добавлен в CoreData")
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
    
    // Преобразование Core Data объекта в модель Tracker
    private func tracker(from entity: TrackerCoreData) -> Tracker? {
        guard let id = entity.id,
              let name = entity.name,
              let colorHex = entity.color,
              let emoji = entity.emoji,
              let schedule = entity.schedule as? [Weekday] else {
            return nil
        }
        
        let color = UIColorMarshalling().color(from: colorHex)
        let trackerType = entity.trackerType == "habit" ? TrackerType.habit : TrackerType.irregular
        
        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule, trackerType: trackerType)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    
    // Этот метод вызывается перед изменениями в содержимом контроллера
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerStoreUpdate.Move>()
    }
    
    // Вызывается после завершения изменений
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store(
            self,
            didUpdate: TrackerStoreUpdate(
                insertedIndexes: insertedIndexes ?? IndexSet(),
                deletedIndexes: deletedIndexes ?? IndexSet(),
                updatedIndexes: updatedIndexes ?? IndexSet(),
                movedIndexes: movedIndexes ?? Set<TrackerStoreUpdate.Move>()
            )
        )
        insertedIndexes = nil
        deletedIndexes = nil
        updatedIndexes = nil
        movedIndexes = nil
    }
    
    // Обработка каждого изменения в контроллере
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { return }
            insertedIndexes?.insert(indexPath.row)
        case .delete:
            guard let indexPath = indexPath else { return }
            deletedIndexes?.insert(indexPath.row)
        case .update:
            guard let indexPath = indexPath else { return }
            updatedIndexes?.insert(indexPath.row)
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { return }
            movedIndexes?.insert(.init(oldIndex: oldIndexPath.row, newIndex: newIndexPath.row))
        @unknown default:
            fatalError("Неподдерживаемый тип изменения в NSFetchedResultsController")
        }
    }
}

