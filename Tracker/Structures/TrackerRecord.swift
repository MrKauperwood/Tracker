//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Aleksei Bondarenko on 20.9.2024.
//

import Foundation

struct TrackerRecord {
    
    let trackerId : UUID
    let date: Date
    var daysCompleted: Int
    
    init(trackerId: UUID, daysCompleted: Int = 0, date: Date) {
        self.trackerId = trackerId
        self.daysCompleted = daysCompleted
        self.date = date
    }
}
