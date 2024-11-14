enum TrackerFilter {
    case allTrackers
    case today
    case completed
    case uncompleted

    var description: String {
        switch self {
        case .allTrackers: return "Все трекеры"
        case .today: return "Трекеры на сегодня"
        case .completed: return "Завершённые"
        case .uncompleted: return "Незавершённые"
        }
    }
}
