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
            errorMessage?("Название категории не может быть пустым или состоять только из пробелов")
            isDoneButtonEnabled?(false)
        } else if trimmedText.count > 38 {
            errorMessage?("Ограничение 38 символов")
            isDoneButtonEnabled?(false)
        } else {
            errorMessage?(nil)
            isDoneButtonEnabled?(true)
        }
    }
}
