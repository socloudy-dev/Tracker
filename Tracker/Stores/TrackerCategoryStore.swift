import CoreData

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func create(name: String) -> TrackerCategoryCoreData {
        let category = TrackerCategoryCoreData(context: context)
        category.name = name
        CoreDataStack.shared.saveContext()
        return category
    }
    
    func fetchAll() -> [TrackerCategoryCoreData] {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return (try? context.fetch(request)) ?? []
    }
    
    func delete(_ category: TrackerCategory) {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", category.name)
        if let object = try? context.fetch(request).first {
            context.delete(object)
            CoreDataStack.shared.saveContext()
        }
    }

    func update(_ category: TrackerCategory, newName: String) {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", category.name)
        if let object = try? context.fetch(request).first {
            object.name = newName
            CoreDataStack.shared.saveContext()
        }
    }
}
