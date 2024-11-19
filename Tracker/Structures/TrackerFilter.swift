import Foundation

enum TrackerFilter {
    case allTrackers
    case today
    case completed
    case uncompleted

    var description: String {
        switch self {
        case .allTrackers:
            return NSLocalizedString("tracker_filter.all_trackers", comment: "")
        case .today:
            return NSLocalizedString("tracker_filter.today", comment: "")
        case .completed:
            return NSLocalizedString("tracker_filter.completed", comment: "")
        case .uncompleted:
            return NSLocalizedString("tracker_filter.uncompleted", comment: "")
        }
    }
}
