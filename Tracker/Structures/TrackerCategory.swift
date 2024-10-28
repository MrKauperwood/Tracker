//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Aleksei Bondarenko on 20.9.2024.
//

import Foundation

struct TrackerCategory: Equatable {
    
    let title: String
    let trackers : [Tracker]
    
    init(title: String, trackers: [Tracker]) {
        self.title = title
        self.trackers = trackers
    }
    
    // Реализация протокола Equatable, позволяющая сравнивать две категории
    static func == (lhs: TrackerCategory, rhs: TrackerCategory) -> Bool {
        return lhs.title == rhs.title
    }
}
