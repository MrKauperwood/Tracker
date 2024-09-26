//
//  Tracker.swift
//  Tracker
//
//  Created by Aleksei Bondarenko on 20.9.2024.
//

import Foundation
import UIKit

struct Tracker {
    let id : UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]
    
    var completedDates: [Date]
    
    init(id: UUID, name: String, color: UIColor, emoji: String, schedule: [Weekday], completedDates: [Date] = []) {
        self.id = id 
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.completedDates = completedDates
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
