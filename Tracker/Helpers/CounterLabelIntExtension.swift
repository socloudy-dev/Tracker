import Foundation

extension Int {
    var dayWithEnding: String {
        String.localizedStringWithFormat(
            NSLocalizedString("days.count", comment: ""),
            self
        )
    }
}
