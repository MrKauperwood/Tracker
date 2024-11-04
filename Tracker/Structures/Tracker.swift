import Foundation
import UIKit

struct Tracker {
    let id : UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]
    let trackerType: TrackerType
    let isPinned: Bool
    
    init(id: UUID, name: String, color: UIColor, emoji: String, schedule: [Weekday], trackerType: TrackerType, isPinned: Bool = false) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.trackerType = trackerType
        self.isPinned = isPinned
    }
}

enum Weekday: String, CaseIterable {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
    
    var shortName: String {
        switch self {
        case .monday:
            return "Пн"
        case .tuesday:
            return "Вт"
        case .wednesday:
            return "Ср"
        case .thursday:
            return "Чт"
        case .friday:
            return "Пт"
        case .saturday:
            return "Сб"
        case .sunday:
            return "Вс"
        }
    }
    
    // Метод для упорядочивания дней недели
    static let orderedWeekdays: [Weekday] = [
        .monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday
    ]
}

extension Weekday {
    static func from(date: Date) -> Weekday? {
        let calendar = Calendar.current
        let weekdayNumber = calendar.component(.weekday, from: date) // 1 - Воскресенье, 2 - Понедельник и т.д.
        
        switch weekdayNumber {
        case 1:
            return .sunday
        case 2:
            return .monday
        case 3:
            return .tuesday
        case 4:
            return .wednesday
        case 5:
            return .thursday
        case 6:
            return .friday
        case 7:
            return .saturday
        default:
            return nil
        }
    }
}

extension Tracker {
    func togglePinnedStatus() -> Tracker {
        return withPinnedStatus(!self.isPinned)
    }
    
    func withPinnedStatus(_ pinned: Bool) -> Tracker {
        return Tracker(
            id: self.id,
            name: self.name,
            color: self.color,
            emoji: self.emoji,
            schedule: self.schedule,
            trackerType: self.trackerType,
            isPinned: pinned
        )
    }
}
