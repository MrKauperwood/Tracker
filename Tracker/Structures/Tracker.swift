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
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday

    var localizedName: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
    
    var shortName: String {
        switch self {
        case .monday:
            return NSLocalizedString("monday_short", comment: "")
        case .tuesday:
            return NSLocalizedString("tuesday_short", comment: "")
        case .wednesday:
            return NSLocalizedString("wednesday_short", comment: "")
        case .thursday:
            return NSLocalizedString("thursday_short", comment: "")
        case .friday:
            return NSLocalizedString("friday_short", comment: "")
        case .saturday:
            return NSLocalizedString("saturday_short", comment: "")
        case .sunday:
            return NSLocalizedString("sunday_short", comment: "")
        }
    }
    
    static let orderedWeekdays: [Weekday] = [
        .monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday
    ]
}

extension Weekday {
    static func from(date: Date) -> Weekday? {
        let calendar = Calendar.current
        let weekdayNumber = calendar.component(.weekday, from: date)
        
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
