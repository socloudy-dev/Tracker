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
}
