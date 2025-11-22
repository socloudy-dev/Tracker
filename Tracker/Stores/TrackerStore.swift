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
    
    func create(tracker: Tracker, category: TrackerCategoryCoreData) {
        let trackerCore = TrackerCoreData(context: context)
        trackerCore.id = tracker.id
        trackerCore.name = tracker.name
        trackerCore.color = tracker.color
        trackerCore.emoji = tracker.emoji
        trackerCore.schedule = tracker.schedule.map { NSNumber(value: $0.rawValue) } as NSObject
        trackerCore.category = category
        
        try? context.save()
    }
    
    func delete(id: UUID) {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        if let tracker = try? context.fetch(request).first {
            context.delete(tracker)
            try? context.save()
            dataDidChange?()
        }
    }
    
    func update(tracker: Tracker, from category: TrackerCategoryCoreData) {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        guard let storedTracker = try? context.fetch(request).first else { return }
        
        storedTracker.name = tracker.name
        storedTracker.color = tracker.color
        storedTracker.emoji = tracker.emoji
        storedTracker.schedule = tracker.schedule.map { NSNumber(value: $0.rawValue) } as NSObject
        storedTracker.category = category
        
        try? context.save()
        dataDidChange?()
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
