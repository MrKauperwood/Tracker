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
    
    init(id: UUID, name: String, color: UIColor, emoji: String, schedule: [Weekday]) {
        self.id = UUID()
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
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
}
