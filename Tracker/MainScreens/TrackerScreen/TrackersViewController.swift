//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Aleksei Bondarenko on 7.9.2024.
//

import Foundation
import UIKit


class TrackersViewController: UIViewController {
    
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .lbWhite
        
        setupUI()
        Logger.log("Загружен Tracker view контроллер")
    }
    
    @objc private func addButtonTapped() {
        Logger.log("Кнопка '+' была нажата")
        let trackerTypeVC = TrackerTypeSelectionViewController()
        present(trackerTypeVC, animated: true, completion: nil)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU") // Устанавливаем русский язык
        dateFormatter.dateFormat = "dd.MM.yy" // Формат день.месяц.год, короткая версия года
        let formattedDate = dateFormatter.string(from: selectedDate)
        Logger.log("Выбранная дата: \(formattedDate)")
    }
    
    
    private func setupUI() {
        
        // Page title creation
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Трекеры"
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        
        // Plus button creation
        let addButtonImage = UIImage(named: "AddTrackerPlusBotton")?.withRenderingMode(.alwaysTemplate)
        let addButton = UIBarButtonItem(
            image: addButtonImage,
            style: .plain,
            target: self,
            action: #selector(addButtonTapped))
        addButton.tintColor = .lbBlack
        navigationItem.leftBarButtonItem = addButton
        
        // Date picker creation for the right bar button
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.calendar = Calendar(identifier: .gregorian)
        
        
        let currentDate = Date()
        let calendar = Calendar.current
        datePicker.maximumDate = currentDate
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        // Search bar creation
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal
        
        // Empty state creation
        let emptyStateLogo = UIImageView(image: UIImage(named: "EmptyStateLogo"))
        emptyStateLogo.translatesAutoresizingMaskIntoConstraints = false
        
        // Empty state text creation
        let emptyStateTextLabel = UILabel()
        emptyStateTextLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateTextLabel.text = "Что будем отслеживать?"
        emptyStateTextLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        emptyStateTextLabel.textColor = .lbBlack
        
        // Adding all elements to the screen
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        view.addSubview(emptyStateLogo)
        view.addSubview(emptyStateTextLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            emptyStateLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateTextLabel.topAnchor.constraint(equalTo: emptyStateLogo.bottomAnchor, constant: 8),
            emptyStateTextLabel.centerXAnchor.constraint(equalTo: emptyStateLogo.centerXAnchor)
            
            
            
        ])
    }
}

extension TrackersViewController {
    
    func addTracker(_ newTracker: Tracker, to categoryTitle: String) {
        if let index = categories.firstIndex(where: { $0.title == categoryTitle }) {

            var updatedTrackers = categories[index].trackers
            updatedTrackers.append(newTracker)
            
            let updatedCategory = TrackerCategory(title: categoryTitle, trackers: updatedTrackers)
            
            var updatedCategories = categories
            updatedCategories[index] = updatedCategory
            
            categories = updatedCategories
        } else {
            let newCategory = TrackerCategory(title: categoryTitle, trackers: [newTracker])
            categories.append(newCategory)
        }
    }
    
    func trackerCompleted(_ tracker: Tracker, on date: Date) {
        let trackerRecord = TrackerRecord(trackerId: tracker.id, date: date)
        completedTrackers.append(trackerRecord)
    }
    
    func trackerUncompleted(_ tracker: Tracker, on date: Date) {
        if let index = completedTrackers.firstIndex(where: { $0.trackerId == tracker.id && $0.date == date }) {
            completedTrackers.remove(at: index)
        }
    }
}
