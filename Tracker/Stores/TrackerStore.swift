import CoreData
import UIKit

final class TrackerStore: NSObject, NSFetchedResultsControllerDelegate {
    private let context: NSManagedObjectContext
    private(set) var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    
    var dataDidChange: (() -> Void)?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        dataDidChange?()
    }
    
    func create(id: UUID, name: String, color: UIColor, emoji: String, schedule: [WeekDay], category: TrackerCategoryCoreData) {
        let tracker = TrackerCoreData(context: context)
        tracker.id = id
        tracker.name = name
        tracker.color = color
        tracker.emoji = emoji
        tracker.schedule = schedule.map { NSNumber(value: $0.rawValue) } as NSObject
        tracker.category = category
        
        try? context.save()
    }
    
    func delete(_ tracker: TrackerCoreData) {
        context.delete(tracker)
        try? context.save()
    }
    
    func fetchTrackers() {
        let request = TrackerCoreData.fetchRequest()
        
        request.sortDescriptors = [
            NSSortDescriptor(key: "category.name", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)
        ]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: "category.name",
            cacheName: nil
        )
        fetchedResultsController?.delegate = self
        
        try? fetchedResultsController?.performFetch()
    }
    
    func categoryName(for section: Int) -> String? {
        fetchedResultsController?.sections?[section].name
    }
    
    
    func numberOfSections() -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    private func trackers(for sectionObjects: [TrackerCoreData], date: Date) -> [TrackerCoreData] {
        let index = Calendar.current.component(.weekday, from: date)
        return sectionObjects.filter { tracker in
            guard let schedule = tracker.schedule as? [Int] else { return false }
            return schedule.contains(index)
        }
    }
    
    func numberOfTrackers(in section: Int, for date: Date) -> Int {
        guard let objects = fetchedResultsController?.sections?[section].objects as? [TrackerCoreData] else { return 0 }
        return trackers(for: objects, date: date).count
    }
    
    func tracker(at indexPath: IndexPath, for date: Date) -> Tracker? {
        guard let sectionObjects = fetchedResultsController?.sections?[indexPath.section].objects as? [TrackerCoreData] else { return nil }
        let trackersInSection = trackers(for: sectionObjects, date: date)
        guard indexPath.item < trackersInSection.count else { return nil }
        return trackersInSection[indexPath.item].toModel()
    }
    
    func allTrackersForDate(_ date: Date) -> [Tracker] {
        guard let sections = fetchedResultsController?.sections else { return [] }
        return sections
            .flatMap { ($0.objects as? [TrackerCoreData]) ?? [] }
            .filter { core in
                guard let schedule = core.schedule as? [Int] else { return false }
                let weekday = Calendar.current.component(.weekday, from: date)
                return schedule.contains(weekday)
            }
            .compactMap { $0.toModel() }
    }
    
    func fetchAllTrackers() -> [Tracker] {
        guard let sections = fetchedResultsController?.sections else { return [] }
        return sections
            .flatMap { ($0.objects as? [TrackerCoreData]) ?? [] }
            .compactMap { $0.toModel() }
    }
}
