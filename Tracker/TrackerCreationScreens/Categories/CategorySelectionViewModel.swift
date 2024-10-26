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
    
    func selectCategory(at index: Int) {
        guard index < categories.count else { return }
        selectedCategory = categories[index]
    }
}
