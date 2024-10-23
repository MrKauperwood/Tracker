//
//  TrackerTypeSelectionViewController.swift
//  Tracker
//
//  Created by Aleksei Bondarenko on 22.9.2024.
//

import Foundation
import UIKit

final class TrackerTypeSelectionViewController: UIViewController {
    
    var trackerStore: TrackerStore!
    var trackerCategoryStore: TrackerCategoryStore!
    var trackerRecordStore: TrackerRecordStore!
    
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Logger.log("Экран выбора типа трекера загружен")
        
        view.backgroundColor = .white
        setupUI()
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        // Заголовок
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Создание трекера"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        
        // Настройка шрифта для кнопок
        let buttonFont = UIFont(name: "SFProText-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        let buttonTextColor = UIColor.white
        
        // Кнопка Привычка
        let habitButton = UIButton(type: .system)
        habitButton.translatesAutoresizingMaskIntoConstraints = false
        habitButton.setTitle("Привычка", for: .normal)
        habitButton.backgroundColor = .black
        habitButton.setTitleColor(buttonTextColor, for: .normal)
        habitButton.titleLabel?.font = buttonFont
        habitButton.layer.cornerRadius = 10
        habitButton.titleLabel?.textAlignment = .center
        habitButton.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        view.addSubview(habitButton)
        
        // Кнопка Нерегулярные события
        let irregularButton = UIButton(type: .system)
        irregularButton.translatesAutoresizingMaskIntoConstraints = false
        irregularButton.setTitle("Нерегулярное событие", for: .normal)
        irregularButton.backgroundColor = .black
        irregularButton.setTitleColor(buttonTextColor, for: .normal)
        irregularButton.titleLabel?.font = buttonFont
        irregularButton.layer.cornerRadius = 10
        irregularButton.titleLabel?.textAlignment = .center
        irregularButton.addTarget(self, action: #selector(irregularButtonTapped), for: .touchUpInside)
        view.addSubview(irregularButton)
        
        // Расстановка элементов на экране
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            habitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            habitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            
            irregularButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
            irregularButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            irregularButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            irregularButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            irregularButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func habitButtonTapped() {
        Logger.log("Выбрано создание привычки")
        let newHabitVC = NewHabitViewController()
        newHabitVC.trackerType = .habit
        newHabitVC.trackerStore = self.trackerStore // Передаем trackerStore
        newHabitVC.trackerCategoryStore = self.trackerCategoryStore
        newHabitVC.trackerRecordStore = self.trackerRecordStore
        present(newHabitVC, animated: true, completion: nil)
    }
    
    @objc private func irregularButtonTapped() {
        Logger.log("Выбрано создание Нерегулярного события")
        let newHabitVC = NewHabitViewController()
        newHabitVC.trackerType = .irregular // Указываем, что создается нерегулярное событие
        newHabitVC.trackerStore = self.trackerStore // Передаем trackerStore
        newHabitVC.trackerCategoryStore = self.trackerCategoryStore
        newHabitVC.trackerRecordStore = self.trackerRecordStore
        present(newHabitVC, animated: true, completion: nil)
    }
}
