import UIKit

struct MockData {
    static let colorNames = ["1", "2", "3", "4", "5"]
    static let emojis = ["🔥", "💧", "🌱", "⭐", "🍎", "🎯", "🏃", "📚"]

    static func generateTestTrackers() -> [Tracker] {
        let names = ["Утренняя пробежка", "Пить воду", "Чтение книги", "Учить Swift", "Медитация", "Завтрак", "Учеба", "Йога"]
        return names.enumerated().map { index, name in
            let emoji = emojis[index % emojis.count]
            let colorName = colorNames.randomElement() ?? "1"
            return Tracker(
                id: UUID(),
                name: name,
                color: UIColor(named: colorName) ?? .systemBlue,
                emoji: emoji,
                schedule: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday],
            )
        }
    }
}
