//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Aleksei Bondarenko on 7.9.2024.
//

import Foundation
import UIKit


final class TrackersViewController: UIViewController {
    
    var selectedDate: Date = Date()
    
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var filteredCategories: [TrackerCategory] = []
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let emptyStateLogo: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "EmptyStateLogo"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyStateTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .lbBlack
        return label
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU") // Устанавливаем русский язык
        formatter.dateFormat = "dd.MM.yy" // Формат день.месяц.год, короткая версия года
        return formatter
    }()
    
    // Публичный метод для обновления данных в collectionView
    public func reloadData() {
        collectionView.reloadData()
        updateEmptyStateVisibility()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Logger.log("Загружен TrackersViewController")
        
        view.backgroundColor = .lbWhite
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "trackerCell")
        collectionView.register(CategoryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "categoryHeader")
        
        setupUI()
        
        // Фильтрация трекеров по текущему дню недели
        let currentDate = Date()
        let weekday = getWeekday(from: currentDate)
        Logger.log("Выбранный день недели: \(String(describing: weekday?.rawValue))")
        filterCategories(by: weekday)
        
        Logger.log("Загружен Tracker view контроллер")
    }
    
    func getWeekday(from date: Date) -> Weekday? {
        return Weekday.from(date: date)
    }
    
    func filterCategories(by weekday: Weekday?) {
        guard let weekday = weekday else { return }
        
        // Очищаем массив отфильтрованных категорий
        filteredCategories = []
        
        for category in categories {
            let filteredTrackers = category.trackers.filter { tracker in
                if tracker.trackerType == .irregular {
                    // Логика для нерегулярных трекеров
                    let isCompleted = completedTrackers.contains { record in
                        record.trackerId == tracker.id && Calendar.current.isDate(record.date, inSameDayAs: selectedDate)
                    }
                    return !isCompleted // Показываем, если ещё не выполнено
                } else {
                    // Логика для привычек
                    return tracker.schedule.contains(weekday)
                }
            }
            
            if !filteredTrackers.isEmpty {
                let filteredCategory = TrackerCategory(title: category.title, trackers: filteredTrackers)
                filteredCategories.append(filteredCategory)
            }
        }
        // Обновляем состояние empty state
        updateEmptyStateVisibility()
    }
    
    @objc private func addButtonTapped() {
        Logger.log("Кнопка '+' нажата, открытие экрана выбора типа трекера")
        let trackerTypeVC = TrackerTypeSelectionViewController()
        present(trackerTypeVC, animated: true, completion: nil)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        let weekday = getWeekday(from: selectedDate)
        Logger.log("Выбранный день недели: \(String(describing: weekday?.rawValue))")
        
        let formattedDate = dateFormatter.string(from: selectedDate)
        Logger.log("Выбранная дата: \(formattedDate)")
        
        // Фильтруем трекеры по дню недели
        filterCategories(by: weekday)
        
        // Обновляем данные в collectionView
        collectionView.reloadData()
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
        
        // Adding all elements to the screen
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(emptyStateLogo)
        view.addSubview(emptyStateTextLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            emptyStateLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateTextLabel.topAnchor.constraint(equalTo: emptyStateLogo.bottomAnchor, constant: 8),
            emptyStateTextLabel.centerXAnchor.constraint(equalTo: emptyStateLogo.centerXAnchor)
        ])
        
        // Логика скрытия пустого состояния
        updateEmptyStateVisibility()
    }
    
    // Логика отображения пустого состояния
    private func updateEmptyStateVisibility() {
        let hasFilteredTrackers = !filteredCategories.isEmpty
        emptyStateLogo.isHidden = hasFilteredTrackers
        emptyStateTextLabel.isHidden = hasFilteredTrackers
        collectionView.isHidden = !hasFilteredTrackers
    }
}


// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trackerCell", for: indexPath) as! TrackerCell
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item] // изменяем на var
        
        // Проверяем, выполнен ли трекер для выбранной даты (selectedDate)
        let isCompleted = completedTrackers.contains { record in
            record.trackerId == tracker.id && Calendar.current.isDate(record.date, inSameDayAs: selectedDate)
        }
        
        if tracker.schedule.isEmpty && !isCompleted {
            // Общее количество выполнений трекера
            let daysCompleted = completedTrackers.filter { $0.trackerId == tracker.id }.count
            let daysCompletedText = "\(daysCompleted) \(DayWordFormatter.getDayWord(for: daysCompleted))"
            cell.configure(with: tracker, daysCompletedText: daysCompletedText, isCompleted: isCompleted)
        } else {
            
            // Общее количество выполнений трекера
            let daysCompleted = completedTrackers.filter { $0.trackerId == tracker.id }.count
            
            // Передаем состояние и выбранную дату в ячейку
            let daysCompletedText = "\(daysCompleted) \(DayWordFormatter.getDayWord(for: daysCompleted))"
            cell.configure(with: tracker, daysCompletedText: daysCompletedText, isCompleted: isCompleted)}
        
        
        cell.increaseDayCounterButtonTapped = { [weak self] increment in
            guard let self = self else { return }
            
            // Проверяем, не является ли выбранная дата будущей
            if Calendar.current.compare(Date(), to: self.selectedDate, toGranularity: .day) == .orderedAscending {
                Logger.log("Нельзя отмечать трекеры для будущей даты")
                return
            }
            
            // Получаем текущий трекер
            let tracker = self.filteredCategories[indexPath.section].trackers[indexPath.item]
            
            // Добавляем или удаляем дату выполнения в зависимости от нажатия
            if increment == 1 {
                self.trackerCompleted(tracker, on: self.selectedDate)
            } else {
                self.trackerUncompleted(tracker, on: self.selectedDate)
            }
            
            // Создаем новый массив трекеров, заменяя изменённый трекер
            let updatedTrackers = self.filteredCategories[indexPath.section].trackers.enumerated().map { (index, existingTracker) -> Tracker in
                return index == indexPath.item ? tracker : existingTracker
            }
            
            // Создаем новую категорию с обновлённым списком трекеров
            let updatedCategory = TrackerCategory(title: self.filteredCategories[indexPath.section].title, trackers: updatedTrackers)
            
            // Обновляем отфильтрованные категории
            self.filteredCategories[indexPath.section] = updatedCategory
            
            // Обновляем трекер в основной категории (categories)
            if let categoryIndex = self.categories.firstIndex(where: { $0.title == self.filteredCategories[indexPath.section].title }) {
                let updatedTrackersInMainCategory = self.categories[categoryIndex].trackers.enumerated().map { (index, existingTracker) -> Tracker in
                    return index == indexPath.item ? tracker : existingTracker
                }
                let updatedMainCategory = TrackerCategory(title: self.categories[categoryIndex].title, trackers: updatedTrackersInMainCategory)
                self.categories[categoryIndex] = updatedMainCategory
            }
            
            // Если это нерегулярное событие и оно завершено, удаляем его из отображения
            if tracker.trackerType == .irregular && increment == 1 {
                // Обновляем данные
                let section = indexPath.section
                let item = indexPath.item
                
                // Удаляем трекер из системы
                self.removeTracker(tracker)
                
                // Удаляем завершённый трекер из данных
                let updatedTrackers = self.filteredCategories[section].trackers.enumerated().filter { index, _ in
                    index != item
                }.map { $1 }
                let updatedCategory = TrackerCategory(title: self.filteredCategories[section].title, trackers: updatedTrackers)
                self.filteredCategories[section] = updatedCategory
                
                // Если в секции больше нет трекеров, удаляем секцию
                if self.filteredCategories[section].trackers.isEmpty {
                    self.filteredCategories.remove(at: section)
                    
                    // Выполняем обновление коллекции с удалением секции
                    self.collectionView.performBatchUpdates({
                        let sectionToDelete = IndexSet(integer: section)
                        self.collectionView.deleteSections(sectionToDelete)
                    }, completion: nil)
                    
                } else {
                    // Выполняем обновление коллекции с удалением элемента
                    self.collectionView.performBatchUpdates({
                        let indexPathToDelete = IndexPath(item: item, section: section)
                        self.collectionView.deleteItems(at: [indexPathToDelete])
                    }, completion: nil)
                }
            } else {
                // Если это не нерегулярный трекер, обновляем ячейку
                self.collectionView.reloadItems(at: [indexPath])
            }
            
            // Проверяем и обновляем состояние empty state
            self.updateEmptyStateVisibility()
        }
        Logger.log("Настройка ячейки для трекера: \(tracker.name), выполнен: \(isCompleted)", level: .debug)
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "categoryHeader", for: indexPath) as! CategoryHeaderView
        let category = filteredCategories[indexPath.section]
        header.configure(with: category.title)
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16
        let minimumSpacing: CGFloat = 8
        let totalSpacing = padding * 2 + minimumSpacing
        let availableWidth = collectionView.frame.width - totalSpacing
        let itemWidth = availableWidth / 2
        let itemHeight: CGFloat = 148 // Здесь можно задать высоту элемента
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8 // Расстояние между элементами в строке
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 30) // Высота заголовков категорий
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    }
}

// MARK: - Helper Methods
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
        collectionView.reloadData()
        updateEmptyStateVisibility()
    }
    
    func trackerCompleted(_ tracker: Tracker, on date: Date) {
        if !completedTrackers.contains(where: { $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            let newRecord = TrackerRecord(trackerId: tracker.id, date: date)
            completedTrackers.append(newRecord)
        }
        Logger.log("Трекер \(tracker.name) выполнен для даты \(dateFormatter.string(from: date))")
    }

    func trackerUncompleted(_ tracker: Tracker, on date: Date) {
        completedTrackers.removeAll { record in
            record.trackerId == tracker.id && Calendar.current.isDate(record.date, inSameDayAs: date)
        }
        Logger.log("Выполнение трекера \(tracker.name) отменено для даты \(dateFormatter.string(from: date))")
    }
    
    func removeTracker(_ tracker: Tracker) {
        // Проходим по всем категориям и удаляем трекер из каждой категории
        for (categoryIndex, category) in categories.enumerated() {
            if let trackerIndex = category.trackers.firstIndex(where: { $0.id == tracker.id }) {
                // Удаляем трекер из категории
                let updatedTrackersInMainCategory = categories[categoryIndex].trackers.enumerated().filter { index, _ in
                    index != trackerIndex
                }.map { $1 }
                let updatedMainCategory = TrackerCategory(title: categories[categoryIndex].title, trackers: updatedTrackersInMainCategory)
                categories[categoryIndex] = updatedMainCategory
                
                // Если категория осталась пустой, удаляем её
                if categories[categoryIndex].trackers.isEmpty {
                    categories.remove(at: categoryIndex)
                }
                
                break // Прекращаем поиск после удаления трекера
            }
        }
        completedTrackers.removeAll { $0.trackerId == tracker.id }
        Logger.log("Трекер \(tracker.name) удалён")
    }
}
