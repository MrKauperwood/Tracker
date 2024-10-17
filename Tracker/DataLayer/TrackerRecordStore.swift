import Foundation
import CoreData

// Протокол для передачи обновлений в контроллер
protocol TrackerRecordStoreDelegate: AnyObject {
    func store(_ store: TrackerRecordStore, didUpdate update: TrackerRecordStoreUpdate)
}

// Структура для передачи информации об изменениях
struct TrackerRecordStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>!
    
    // Делегат для передачи обновлений в контроллер
    weak var delegate: TrackerRecordStoreDelegate?
    
    // Индексы для отслеживания изменений
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerRecordStoreUpdate.Move>?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    // Настройка NSFetchedResultsController
    private func setupFetchedResultsController() {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: true)
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
            print("Ошибка при выборке записей трекеров: \(error)")
        }
    }
    
    // Получение всех записей из Core Data
    var records: [TrackerRecord] {
        guard let objects = fetchedResultsController.fetchedObjects else { return [] }
        return objects.compactMap { self.record(from: $0) }
    }
    
    // Метод для добавления записи о выполнении трекера
    func addRecord(_ record: TrackerRecord) throws {
        let recordEntity = TrackerRecordCoreData(context: context)
        recordEntity.date = record.date
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", record.trackerId as CVarArg)
        if let trackerEntity = try context.fetch(fetchRequest).first {
            recordEntity.trackerId = trackerEntity
        }
        try context.save()
        Logger.log("Новая запись для трекера с ID: \(record.trackerId) на дату \(record.date) добавлена в CoreData")
    }
    
    // Метод для удаления записи
    func deleteRecord(_ record: TrackerRecord) throws {
        let request = TrackerRecordCoreData.fetchRequest()
        
        // Преобразуем дату к началу дня (игнорируем время)
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: record.date)
        
        // Используем NSPredicate для поиска записей с одинаковым trackerId и той же датой (без учета времени)
        request.predicate = NSPredicate(format: "trackerId.id == %@ AND date >= %@ AND date < %@",
                                        record.trackerId as CVarArg,
                                        startOfDay as CVarArg,
                                        calendar.date(byAdding: .day, value: 1, to: startOfDay)! as CVarArg)
        if let result = try context.fetch(request).first {
            context.delete(result)
            try context.save()
        }
    }
    
    // Преобразование Core Data объекта в модель TrackerRecord
    private func record(from entity: TrackerRecordCoreData) -> TrackerRecord? {
        guard let trackerEntity = entity.trackerId,
              let date = entity.date else {
            return nil
        }
        guard let trackerId = trackerEntity.id else { return nil }
        return TrackerRecord(trackerId: trackerId, date: date)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    
    // Этот метод вызывается перед изменениями в содержимом контроллера
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerRecordStoreUpdate.Move>()
    }
    
    // Вызывается после завершения изменений
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store(
            self,
            didUpdate: TrackerRecordStoreUpdate(
                insertedIndexes: insertedIndexes ?? IndexSet(),
                deletedIndexes: deletedIndexes ?? IndexSet(),
                updatedIndexes: updatedIndexes ?? IndexSet(),
                movedIndexes: movedIndexes ?? Set<TrackerRecordStoreUpdate.Move>()
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
