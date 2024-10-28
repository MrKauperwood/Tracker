final class DayWordFormatter {
    static func getDayWord(for count: Int) -> String {
        let lastDigit = count % 10
        let lastTwoDigits = count % 100
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 14 {
            return "дней"
        }
        
        if lastDigit == 1 {
            return "день"
        }
        
        if lastDigit >= 2 && lastDigit <= 4 {
            return "дня"
        }
        
        return "дней"
    }
}
