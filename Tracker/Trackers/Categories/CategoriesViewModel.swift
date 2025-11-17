import Foundation

final class CategoriesViewModel {
    
    private let store: TrackerCategoryStore
    private(set) var categories: [TrackerCategory] = []
    
    var onUpdate: (() -> Void)?
    var onSelect: ((TrackerCategory) -> Void)?
    var onError: ((Error) -> Void)?

    init(store: TrackerCategoryStore) {
        self.store = store
    }

    func load() {
        let list = store.fetchAll()
        self.categories = list.map { TrackerCategory(name: $0.name ?? "", trackers: []) }
        onUpdate?()
    }

    func create(name: String) {
        _ = store.create(name: name)
        load()
    }

    func select(at index: Int) {
        guard index < categories.count else { return }
        let category = categories[index]
        onSelect?(category)
    }
}
