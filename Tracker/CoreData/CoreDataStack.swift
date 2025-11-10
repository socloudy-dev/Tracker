import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("[CoreDataStack/persistentContainer]: Unable to load persistent stores: \(error)")
            }
        })
        return container
    }()

    func saveContext() {
        let context = context
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback()
                if let error = error as NSError? {
                    fatalError("[CoreDataStack/saveContext]: Unresolved error \(error), \(error.userInfo)")
                }
            }
        }
    }
}
