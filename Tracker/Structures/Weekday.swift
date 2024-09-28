//
//  Weekday.swift
//  Tracker
//
//  Created by Aleksei Bondarenko on 27.9.2024.
//

import Foundation

enum TrackerWeekday: String, CaseIterable {
    case sunday, monday, tuesday, wednesday, thursday, friday, saturday

    // Метод для преобразования даты в день недели
    static func from(date: Date) -> TrackerWeekday? {
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
