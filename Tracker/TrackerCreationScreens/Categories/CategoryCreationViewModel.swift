import Foundation

final class CategoryCreationViewModel {
    
    // MARK: - Properties
    
    var isDoneButtonEnabled: ((Bool) -> Void)?
    var errorMessage: ((String?) -> Void)?
    
    private(set) var categoryName: String = "" {
        didSet {
            isDoneButtonEnabled?(categoryName.count > 0)
        }
    }
    
    // MARK: - Public Methods
    
    func updateCategoryName(_ name: String) {
        categoryName = name
        validateCategoryName()
    }
    
    // MARK: - Private Methods
    
    private func validateCategoryName() {
        let trimmedText = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedText.isEmpty {
            errorMessage?(NSLocalizedString("category_creation.error.empty_name", comment: ""))
            isDoneButtonEnabled?(false)
        } else if trimmedText.count > 38 {
            errorMessage?(NSLocalizedString("category_creation.error.character_limit", comment: ""))
            isDoneButtonEnabled?(false)
        } else {
            errorMessage?(nil)
            isDoneButtonEnabled?(true)
        }
    }
}
