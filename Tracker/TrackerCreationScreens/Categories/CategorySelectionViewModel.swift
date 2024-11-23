final class CategorySelectionViewModel {
    
    // MARK: - Public Properties
    
    var categories: [TrackerCategory] = [] {
        didSet {
            categoriesDidChange?(categories)
        }
    }
    var selectedCategory: TrackerCategory? {
        didSet {
            selectedCategoryDidChange?(selectedCategory)
        }
    }
    
    // MARK: - Bindings
    
    var categoriesDidChange: (([TrackerCategory]) -> Void)?
    var selectedCategoryDidChange: ((TrackerCategory?) -> Void)?
    
    // MARK: - Dependencies
    
    private let trackerCategoryStore: TrackerCategoryStore
    
    // MARK: - Initializer
    
    init(trackerCategoryStore: TrackerCategoryStore) {
        self.trackerCategoryStore = trackerCategoryStore
        fetchCategories()
    }
    
    // MARK: - Public Methods
    
    func fetchCategories() {
        categories = trackerCategoryStore.getCategories()
        categoriesDidChange?(categories)
    }
    
    func addCategory(with title: String) {
        do {
            try trackerCategoryStore.addCategory(title: title)
            fetchCategories()
        } catch {
            Logger.log("Ошибка добавления категории: \(error)", level: .error)
        }
    }
    
    func editCategory(_ category: TrackerCategory, newTitle title: String) {
        do {
            try trackerCategoryStore.editCategory(category, with: title)
            fetchCategories()
        } catch {
            Logger.log("Ошибка редактирования категории: \(error)", level: .error)
        }
    }
    
    func removeCategory(_ category: TrackerCategory) {
        do {
            try trackerCategoryStore.deleteCategory(category)
        } catch {
            Logger.log("Ошибка при удалении категории: \(error)", level: .error)
        }
    }
    
    func selectCategory(at index: Int) {
        guard index < categories.count else { return }
        selectedCategory = categories[index]
    }
}
