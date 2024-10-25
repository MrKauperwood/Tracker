//
//  CategoryCreationViewModel.swift
//  Tracker
//
//  Created by Aleksei Bondarenko on 25.10.2024.
//

import Foundation

final class CategoryCreationViewModel {
    
    // Замыкание для наблюдения за состоянием кнопки
    var isDoneButtonEnabled: ((Bool) -> Void)?
    
    private(set) var categoryName: String = "" {
        didSet {
            isDoneButtonEnabled?(categoryName.count > 0)
        }
    }
    
    // Метод для обновления имени категории
    func updateCategoryName(_ name: String) {
        categoryName = name
    }
}
