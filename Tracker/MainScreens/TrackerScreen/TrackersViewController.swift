//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Aleksei Bondarenko on 7.9.2024.
//

import Foundation
import UIKit


class TrackersViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var selectedDate: Date = Date()

    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    var filteredCategories: [TrackerCategory] = []
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    let emptyStateLogo: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "EmptyStateLogo"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let emptyStateTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .lbBlack
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .lbWhite
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "trackerCell")
        collectionView.register(CategoryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "categoryHeader")
        
        // Добавляем тестовый трекер
        addTestTracker()
        addTestTrackerForAnotherCategory()
        addTestTracker()
        addTestTrackerForAnotherCategory()

        
        setupUI()
        
        // Фильтрация трекеров по текущему дню недели
        let currentDate = Date()
        let weekday = getWeekday(from: currentDate)
        Logger.log("Выбранный день недели: \(String(describing: weekday?.rawValue))")
        filterCategories(by: weekday)
        
        Logger.log("Загружен Tracker view контроллер")
    }
    
    // Функция для добавления тестового трекера
    private func addTestTracker() {
        let testTracker = Tracker(
            id: UUID(),
            name: "Поливать растения",
            color: .lbCS5Green,
            emoji: "❤️",
            schedule: [.monday, .wednesday, .friday]
        )

        let categoryTitle = "Домашний уют"
        
        // Добавляем трекер в категорию
        addTracker(testTracker, to: categoryTitle)
        
        // Перезагружаем collectionView для отображения изменений
        collectionView.reloadData()
        
        // Обновляем состояние empty state
        updateEmptyStateVisibility()
    }
    
    // Функция для добавления тестового трекера
    private func addTestTrackerForAnotherCategory() {
        let testTracker = Tracker(
            id: UUID(),
            name: "Программирование обучение",
            color: .lbCS13Peach,
            emoji: "😻",
            schedule: [.monday, .tuesday, .wednesday, .friday]
        )

        let categoryTitle = "Обучение"
        
        // Добавляем трекер в категорию
        addTracker(testTracker, to: categoryTitle)
        
        // Перезагружаем collectionView для отображения изменений
        collectionView.reloadData()
        
        // Обновляем состояние empty state
        updateEmptyStateVisibility()
    }
    
    func getWeekday(from date: Date) -> Weekday? {
        let calendar = Calendar.current
        let weekdayNumber = calendar.component(.weekday, from: date) // 1 - Воскресенье, 2 - Понедельник и т.д.
        
        switch weekdayNumber {
        case 1:
            return .sunday
        case 2:
            return .monday
        case 3:
            return .tuesday
        case 4:
            return .wednesday
        case 5:
            return .thursday
        case 6:
            return .friday
        case 7:
            return .saturday
        default:
            return nil
        }
    }
    
    func filterCategories(by weekday: Weekday?) {
        guard let weekday = weekday else { return }
        
        // Очищаем массив отфильтрованных категорий
        filteredCategories = []
        
        // Проходим по всем категориям
        for category in categories {
            // Фильтруем трекеры внутри категории по выбранному дню недели
            let filteredTrackers = category.trackers.filter { tracker in
                return tracker.schedule.contains(weekday)
            }
            
            // Если в категории есть трекеры, добавляем их в фильтрованный массив
            if !filteredTrackers.isEmpty {
                let filteredCategory = TrackerCategory(title: category.title, trackers: filteredTrackers)
                filteredCategories.append(filteredCategory)
            }
        }
        // Обновляем состояние empty state
        updateEmptyStateVisibility()
    }
    
    @objc private func addButtonTapped() {
        Logger.log("Кнопка '+' была нажата")
        let trackerTypeVC = TrackerTypeSelectionViewController()
        present(trackerTypeVC, animated: true, completion: nil)
//        let trackerTypeVC = TrackerTypeSelectionViewController()
//        navigationController?.pushViewController(trackerTypeVC, animated: true)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        let weekday = getWeekday(from: selectedDate)
        Logger.log("Выбранный день недели: \(String(describing: weekday?.rawValue))")
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU") // Устанавливаем русский язык
        dateFormatter.dateFormat = "dd.MM.yy" // Формат день.месяц.год, короткая версия года
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
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
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
        let trackerRecord = TrackerRecord(trackerId: tracker.id, date: date)
        completedTrackers.append(trackerRecord)
    }
    
    func trackerUncompleted(_ tracker: Tracker, on date: Date) {
        if let index = completedTrackers.firstIndex(where: { $0.trackerId == tracker.id && $0.date == date }) {
            completedTrackers.remove(at: index)
        }
    }
}

extension TrackersViewController {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCategories[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trackerCell", for: indexPath) as! TrackerCell
        var tracker = filteredCategories[indexPath.section].trackers[indexPath.item] // изменяем на var

        // Проверяем, выполнен ли трекер для выбранной даты (selectedDate)
        let isCompleted = tracker.completedDates.contains { Calendar.current.isDate($0, inSameDayAs: selectedDate) }
        
        // Общее количество выполнений трекера
        let daysCompleted = tracker.completedDates.count

        // Передаем состояние и выбранную дату в ячейку
        cell.configure(with: tracker, daysCompleted: daysCompleted, isCompleted: isCompleted)
        
        cell.increaseDayCounterButtonTapped = { [weak self] increment in
            guard let self = self else { return }

            // Проверяем, не является ли выбранная дата будущей
            if Calendar.current.compare(Date(), to: self.selectedDate, toGranularity: .day) == .orderedAscending {
                Logger.log("Нельзя отмечать трекеры для будущей даты")
                return
            }
            
            // Добавляем или удаляем дату выполнения в зависимости от нажатия
            if increment == 1 {
                // Если трекер не был выполнен в выбранную дату, добавляем дату
                if !tracker.completedDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: self.selectedDate) }) {
                    tracker.completedDates.append(self.selectedDate)
                }
            } else {
                // Если трекер был выполнен, удаляем дату выполнения
                tracker.completedDates.removeAll { Calendar.current.isDate($0, inSameDayAs: self.selectedDate) }
            }

            // Обновляем трекер в отфильтрованной категории
            self.filteredCategories[indexPath.section].trackers[indexPath.item] = tracker

            // Обновляем трекер в основной категории (categories)
            if let categoryIndex = self.categories.firstIndex(where: { $0.title == self.filteredCategories[indexPath.section].title }) {
                if let trackerIndex = self.categories[categoryIndex].trackers.firstIndex(where: { $0.id == tracker.id }) {
                    self.categories[categoryIndex].trackers[trackerIndex] = tracker
                }
            }

            collectionView.reloadItems(at: [indexPath])
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "categoryHeader", for: indexPath) as! CategoryHeaderView
        let category = filteredCategories[indexPath.section]
        header.configure(with: category.title)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 167, height: 148)
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

