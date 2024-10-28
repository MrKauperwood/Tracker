import Foundation
import CoreData

// Протокол для передачи обновлений в контроллер
protocol TrackerCategoryStoreDelegate: AnyObject {
    func store(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate)
}

struct TrackerCategoryStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>!
    
    // Делегат для передачи обновлений в контроллер
    weak var delegate: TrackerCategoryStoreDelegate?
    
    // Индексы для отслеживания изменений
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerCategoryStoreUpdate.Move>?
    
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
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
            print("Ошибка при выборке категорий: \(error)")
        }
    }
    
    var categories: [TrackerCategory] {
        guard let objects = fetchedResultsController.fetchedObjects else { return [] }
        return objects.compactMap { self.category(from: $0) }
    }
    
    func addCategory(title: String) throws {
        let categoryEntity = TrackerCategoryCoreData(context: context)
        categoryEntity.title = title
        
        do {
            try context.save()
            try fetchedResultsController.performFetch()
        } catch {
            print("Ошибка при сохранении категории: \(error)")
            throw error
        }
    }
    
    func getCategories() -> [TrackerCategory] {
        guard let objects = fetchedResultsController.fetchedObjects else { return [] }
        return objects.map { TrackerCategory(title: $0.title ?? "", trackers: []) }
    }
    
    // Преобразование Core Data объекта в модель TrackerCategory
    private func category(from entity: TrackerCategoryCoreData) -> TrackerCategory? {
        guard let title = entity.title else {
            return nil
        }
        
        // Получаем массив трекеров из отношения
        let trackers: [Tracker] = (entity.trackers as? Set<TrackerCoreData>)?.compactMap { trackerEntity in
            guard let id = trackerEntity.id,
                  let name = trackerEntity.name,
                  let colorHex = trackerEntity.color,
                  let emoji = trackerEntity.emoji else {
                return nil
            }
            let color = UIColorMarshalling().color(from: colorHex)
            
            
            // Извлечение schedule как массив строк и преобразование в массив Weekday
            let schedule: [Weekday] = (trackerEntity.schedule as? [String])?.compactMap { Weekday(rawValue: $0) } ?? []
            
            let trackerType = trackerEntity.trackerType == TrackerType.habit.rawValue ? TrackerType.habit : TrackerType.irregular
            
            return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule, trackerType: trackerType)
        } ?? []
        
        return TrackerCategory(title: title, trackers: trackers)
    }
    
    func deleteCategory(_ category: TrackerCategory) throws {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", category.title)
        if let result = try context.fetch(request).first {
            context.delete(result)
            do {
                try context.save()
            } catch {
                Logger.log("Ошибка при сохранении категории: \(error)", level: .error)
                throw error
            }
        }
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    
}
