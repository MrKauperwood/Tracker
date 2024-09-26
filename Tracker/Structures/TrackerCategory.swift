//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Aleksei Bondarenko on 20.9.2024.
//

import Foundation

struct TrackerCategory {
    
    let title: String
    var trackers : [Tracker]
    
    init(title: String, trackers: [Tracker]) {
        self.title = title
        self.trackers = trackers
    }
}
