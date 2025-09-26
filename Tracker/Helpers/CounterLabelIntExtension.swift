extension Int {
    var dayWithEnding: String {
        let lastDigit = self % 10
        let lastTwoDigits = self % 100

        if lastTwoDigits >= 11 && lastTwoDigits <= 14 {
            return "\(self) дней"
        } else if lastDigit == 1 {
            return "\(self) день"
        } else if (2...4).contains(lastDigit) {
            return "\(self) дня"
        } else {
            return "\(self) дней"
        }
    }
}
