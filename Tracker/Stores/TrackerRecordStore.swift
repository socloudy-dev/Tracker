import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func addRecord(for trackerId: UUID, date: Date) {
        guard let tracker = fetchTrackerCoreData(with: trackerId) else { return }
        if hasRecord(for: trackerId, date: date) { return }
        let record = TrackerRecordCoreData(context: context)
        record.date = date
        record.tracker = tracker
        CoreDataStack.shared.saveContext()
    }

    func removeRecord(for trackerId: UUID, date: Date) {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "tracker.id == %@", trackerId as CVarArg),
            NSPredicate(format: "date == %@", Calendar.current.startOfDay(for: date) as NSDate)
        ])
        let records = (try? context.fetch(request)) ?? []
        for record in records {
            context.delete(record)
        }
        if !records.isEmpty {
            CoreDataStack.shared.saveContext()
        }
    }

    func fetchRecords(for trackerId: UUID) -> [TrackerRecord] {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "tracker.id == %@", trackerId as CVarArg)
        let records = (try? context.fetch(request)) ?? []
        return records.compactMap { record in
            guard let tracker = record.tracker, let id = tracker.id, let date = record.date else { return nil }
            return TrackerRecord(trackerId: id, date: date)
        }
    }
    
    func hasRecord(for trackerId: UUID, date: Date) -> Bool {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "tracker.id == %@", trackerId as CVarArg),
            NSPredicate(format: "date == %@", Calendar.current.startOfDay(for: date) as NSDate)
        ])
        let count = (try? context.count(for: request)) ?? 0
        return count > 0
    }

    private func fetchTrackerCoreData(with id: UUID) -> TrackerCoreData? {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return (try? context.fetch(request))?.first
    }
}
