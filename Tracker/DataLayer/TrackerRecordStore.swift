//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Aleksei Bondarenko on 3.10.2024.
//

import Foundation
import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // Метод для добавления записи о выполнении трекера
    func addRecord(_ record: TrackerRecord) throws {
        let recordEntity = TrackerRecordCoreData(context: context)
        recordEntity.trackerId = record.trackerId
        recordEntity.date = record.date
        try context.save()
    }

    // Метод для получения всех записей
    func getAllRecords() throws -> [TrackerRecord] {
        let request = TrackerRecordCoreData.fetchRequest()
        let results = try context.fetch(request)
        return results.compactMap { entity in
            guard let trackerId = entity.trackerId,
                  let date = entity.date else { return nil }
            return TrackerRecord(trackerId: trackerId, date: date)
        }
    }

    // Метод для удаления записи
    func deleteRecord(_ record: TrackerRecord) throws {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "trackerId == %@ AND date == %@", record.trackerId as CVarArg, record.date as CVarArg)
        if let result = try context.fetch(request).first {
            context.delete(result)
            try context.save()
        }
    }
}
