import Foundation

struct DateHelper {
    static let shared = DateHelper()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }()
    
    func formattedDate(from date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    func weekday(from date: Date) -> Weekday? {
        return Weekday.from(date: date)
    }
}
