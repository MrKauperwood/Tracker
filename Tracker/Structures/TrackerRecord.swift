import Foundation

struct TrackerRecord {
    
    let trackerId : UUID
    let date: Date
    
    init(trackerId: UUID, daysCompleted: Int = 0, date: Date) {
        self.trackerId = trackerId
        self.date = date
    }
}
