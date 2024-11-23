import Foundation

struct DateHelper {
    static let shared = DateHelper()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "dd.MM.yy"
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    func formattedDate(from date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    func weekday(from date: Date) -> Weekday? {
        return Weekday.from(date: date)
    }
}
