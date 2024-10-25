//
//  Untitled.swift
//  Tracker
//
//  Created by Aleksei Bondarenko on 23.10.2024.
//

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
        loadCategories()
    }
    
    // MARK: - Public Methods
    func loadCategories() {
        categories = trackerCategoryStore.getCategories()
        categoriesDidChange?(categories)
    }
    
    func addCategory(with title: String) {
        do {
            try trackerCategoryStore.addCategory(title: title)
            loadCategories() // Обновляем категории после добавления новой
        } catch {
            print("Ошибка добавления категории: \(error)")
        }
    }
    
    func selectCategory(at index: Int) {
        guard index < categories.count else { return }
        selectedCategory = categories[index]
    }
}
