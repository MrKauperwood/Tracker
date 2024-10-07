//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Aleksei Bondarenko on 3.10.2024.
//

import Foundation
import CoreData

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // Метод для добавления категории трекеров
    func addCategory(_ category: TrackerCategory) throws {
        let categoryEntity = TrackerCategoryCoreData(context: context)
        categoryEntity.title = category.title
        try context.save()
    }

    // Метод для получения всех категорий
    func getAllCategories() throws -> [TrackerCategory] {
        let request = TrackerCategoryCoreData.fetchRequest()
        let results = try context.fetch(request)
        return results.compactMap { entity in
            guard let title = entity.title else { return nil }
            let trackers = try? TrackerStore(context: context).getAllTrackers()
            return TrackerCategory(title: title, trackers: trackers ?? [])
        }
    }
}
