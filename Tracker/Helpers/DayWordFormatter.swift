import Foundation

final class DayWordFormatter {
    static func getDayWord(for count: Int) -> String {
        let lastDigit = count % 10
        let lastTwoDigits = count % 100
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 14 {
            return NSLocalizedString("day_word_many", comment: "")
        }
        
        if lastDigit == 1 {
            return NSLocalizedString("day_word_one", comment: "")
        }
        
        if lastDigit >= 2 && lastDigit <= 4 {
            return NSLocalizedString("day_word_few", comment: "")
        }
        
        return NSLocalizedString("day_word_many", comment: "")
    }
}
