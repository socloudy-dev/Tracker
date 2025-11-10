import UIKit
import CoreData

extension TrackerCoreData {
    func toModel() -> Tracker? {
        guard
            let id = self.id,
            let name = self.name,
            let emoji = self.emoji,
            let color = self.color as? UIColor
        else { return nil }
        
        let schedule = (self.schedule as? [Int])?.compactMap { WeekDay(rawValue: $0) } ?? []

        return Tracker(id: id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule)
    }
}

extension Tracker {
    func toCoreData(with context: NSManagedObjectContext, from category: TrackerCategoryCoreData) -> TrackerCoreData {
        let tracker = TrackerCoreData(context: context)
        tracker.id = id
        tracker.name = name
        tracker.emoji = emoji
        tracker.color = color
        tracker.schedule = schedule.map { $0.rawValue } as NSObject
        tracker.category = category
        return tracker
    }
}
