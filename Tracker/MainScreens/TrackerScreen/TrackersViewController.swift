//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Aleksei Bondarenko on 7.9.2024.
//

import Foundation
import UIKit


final class TrackersViewController: UIViewController {
    
    private var trackerStore: TrackerStore!
    private var trackerCategoryStore: TrackerCategoryStore!
    private var trackerRecordStore: TrackerRecordStore!
    
    
    private var visibleTrackers: [Tracker] = []
    
    var selectedDate: Date = Date()
    
    private var categories: [TrackerCategory] = []
    private var records: [TrackerRecord] = []
    private var completedTrackers: [TrackerRecord] = []
    
    
    var getCategories: [TrackerCategory] {
        return categories
    }
    
    private var allExistingTrackers: [Tracker] = []
    
    private var filteredCategories: [TrackerCategory] = []
    private var filteredTrackers: [Tracker] = []
    
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
        
        setupTrackerCategoryStore()
        setupTrackerStore()
        setupTrackerRecordStore()
        
        
        // Фильтрация трекеров по текущему дню недели
        let currentDate = Date()
        filterTrackers(from: allExistingTrackers, for: currentDate)
        filterCategories(from: categories, for: currentDate)
        
        setupUI()
        
        Logger.log("Загружен Tracker view контроллер")
    }
    
    
    private func filterTrackers(from trackers: [Tracker], for date: Date) {
        guard let weekday = Weekday.from(date: date) else { return }
        
        Logger.log("Фильтрация трекеров для дня недели: \(weekday)")
        
        filteredTrackers = trackers.filter { tracker in
            tracker.schedule.contains(weekday)
        }
        
        Logger.log("Отфильтрованный список трекеров: \(filteredTrackers)")
        
    }
    
    func filterCategories(from categories: [TrackerCategory], for date: Date) {
        guard let weekday = Weekday.from(date: date) else { return }
        
        // Создаем отфильтрованный список категорий
        let filteredCategories = categories.compactMap { category -> TrackerCategory? in
            // Фильтруем трекеры в категории
            let filteredTrackers = category.trackers.filter { tracker in
                if tracker.trackerType == .habit {
                    return tracker.schedule.contains(weekday)
                } else if tracker.trackerType == .irregular {
                    return true
                }
                return false
            }
            
            // Если в категории есть трекеры, возвращаем новую категорию с этими трекерами
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        Logger.log("Отфильтрованный список категорий: \(filteredCategories)")
        self.filteredCategories = filteredCategories
    }
    
    @objc private func handleCategoryUpdate() {
        // Обновляем данные из store
        categories = trackerCategoryStore.categories
        collectionView.reloadData()
        updateEmptyStateVisibility()
    }
    
    func getWeekday(from date: Date) -> Weekday? {
        return Weekday.from(date: date)
    }
    
    @objc private func addButtonTapped() {
        Logger.log("Кнопка '+' нажата, открытие экрана выбора типа трекера")
        let trackerTypeVC = TrackerTypeSelectionViewController()
        
        //нужно передать ссылку на trackerStore
        trackerTypeVC.trackerStore = self.trackerStore
        
        //нужно передать ссылку на trackerCategoryStore
        trackerTypeVC.trackerCategoryStore = self.trackerCategoryStore
        
        //нужно передать ссылку на trackerRecordStore
        trackerTypeVC.trackerRecordStore = self.trackerRecordStore
        
        present(trackerTypeVC, animated: true, completion: nil)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        let weekday = getWeekday(from: selectedDate)
        Logger.log("Выбранный день недели: \(String(describing: weekday?.rawValue))")
        
        let formattedDate = dateFormatter.string(from: selectedDate)
        Logger.log("Выбранная дата: \(formattedDate)")
        
        // Фильтруем трекеры по дню недели
        filterCategories(from: categories, for: selectedDate)
        filterTrackers(from: allExistingTrackers, for: selectedDate)
        
        // Обновляем коллекцию полностью
        updateUIAfterTrackerChange()
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
        let hasFilteredTrackers = !filteredTrackers.isEmpty
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
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        
        // Проверяем, выполнен ли трекер для выбранной даты (selectedDate)
        let isCompleted = records.contains { record in
            record.trackerId == tracker.id && Calendar.current.isDate(record.date, inSameDayAs: selectedDate)
        }
        
        // Общее количество выполнений трекера
        let daysCompleted = records.filter { $0.trackerId == tracker.id }.count
        let daysCompletedText = "\(daysCompleted) \(DayWordFormatter.getDayWord(for: daysCompleted))"
        cell.configure(with: tracker, daysCompletedText: daysCompletedText, isCompleted: isCompleted)
        
        cell.increaseDayCounterButtonTapped = { [weak self] increment in
            guard let self = self else { return }
            
            // Проверяем, не является ли выбранная дата будущей
            if Calendar.current.compare(Date(), to: self.selectedDate, toGranularity: .day) == .orderedAscending {
                Logger.log("Нельзя отмечать трекеры для будущей даты")
                return
            }
            
            // Генерируем объект записи трекера
            let trackerRecord = TrackerRecord(
                trackerId: tracker.id,
                date: self.selectedDate)
            
            do {
                if increment == 1 {
                    try self.trackerRecordStore.addRecord(trackerRecord)
                    
                    if tracker.trackerType == .irregular {
                        // Удаляем нерегулярный трекер из системы
                        self.removeTracker(tracker)
                        
                        // Удаляем трекер из Core Data
                        try self.trackerStore.deleteTracker(tracker)
                        
                        Logger.log("Нерегулярный трекер \(tracker.name) был удален после завершения")
                        // Обновляем UI после удаления трекера
                        self.updateUIAfterTrackerChange()
                        
                    } else {
                        Logger.log("Трекер \(tracker.name) отмечен как выполненный")
                    }
                } else {
                    try self.trackerRecordStore.deleteRecord(trackerRecord)
                }
                
                setupTrackerRecordStore()
                setupTrackerRecordStore()
                setupTrackerCategoryStore()
                self.collectionView.reloadData()
                
                
            } catch {
                Logger.log("Ошибка при изменении записи трекера: \(error)", level: .error)
            }
            
            // Проверяем и обновляем состояние empty state
            self.updateEmptyStateVisibility()
        }
        Logger.log("Настройка ячейки для трекера: \(tracker.name), выполнен: \(isCompleted)", level: .debug)
        return cell
        
    }
    
    private func updateUIAfterTrackerChange() {
        // Обновляем список категорий, фильтруем их
        filterCategories(from: categories, for: selectedDate)
        
        // Обновляем коллекцию полностью
        collectionView.reloadData()
        
        // Обновление отображения пустого состояния
        updateEmptyStateVisibility()
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

extension TrackersViewController: TrackerStoreDelegate{
    func store(_ store: TrackerStore, didUpdate update: TrackerStoreUpdate) {
    }
}

extension TrackersViewController: TrackerRecordStoreDelegate {
    func store(_ store: TrackerRecordStore, didUpdate update: TrackerRecordStoreUpdate){}
}

extension TrackersViewController: TrackerCategoryStoreDelegate {
    func store(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate) {
        categories = store.categories
        
        // Фильтрация трекеров и категорий по текущему дню недели
        filterTrackers(from: allExistingTrackers, for: selectedDate)
        filterCategories(from: categories, for: selectedDate)
        
        collectionView.performBatchUpdates {
            Logger.log("performBatchUpdates вызывается")
            
            // Убедиться, что секции существуют перед вставкой элементов
            if collectionView.numberOfSections == 0 {
                let sectionIndexSet = IndexSet(integer: 0)
                collectionView.insertSections(sectionIndexSet)
            }
            
            let insertedIndexPaths = update.insertedIndexes.map { IndexPath(item: $0, section: 0) }
            let deletedIndexPaths = update.deletedIndexes.map { IndexPath(item: $0, section: 0) }
            let updatedIndexPaths = update.updatedIndexes.map { IndexPath(item: $0, section: 0) }
            
            collectionView.insertItems(at: insertedIndexPaths)
            collectionView.deleteItems(at: deletedIndexPaths)
            collectionView.reloadItems(at: updatedIndexPaths)
            
            for move in update.movedIndexes {
                collectionView.moveItem(
                    at: IndexPath(item: move.oldIndex, section: 0),
                    to: IndexPath(item: move.newIndex, section: 0)
                )
            }
        }
        
        // Обновление отображения пустого состояния
        updateEmptyStateVisibility()
    }
}

extension TrackersViewController {
    
    // MARK: Work with CoreData
    
    func setupTrackerStore() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        trackerStore = TrackerStore(context: context)
        trackerStore.delegate = self
        
        // Загрузка начальных данных
        do {
            allExistingTrackers = try trackerStore.getAllTrackers()
            Logger.log("Трекеры (в количестве \(allExistingTrackers.count)) были загружены из CoreData")
        } catch {
            Logger.log("Ошибка при загрузке трекеров: \(allExistingTrackers)", level: .error)
        }
        
        filterTrackers(from: allExistingTrackers, for: selectedDate)
        filterCategories(from: categories, for: selectedDate)
        
        collectionView.reloadData()
    }
    
    private func setupTrackerCategoryStore() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        trackerCategoryStore = TrackerCategoryStore(context: context)
        trackerCategoryStore.delegate = self
        
        // Загрузка начальных данных
        categories = trackerCategoryStore.categories
        Logger.log("Все категории трекеров (в количестве \(categories.count)) были загружены из CoreData: \(categories)")
        
        collectionView.reloadData()
    }
    
    private func setupTrackerRecordStore() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        trackerRecordStore = TrackerRecordStore(context: context)
        trackerRecordStore.delegate = self
        
        // Загрузка начальных данных
        records = trackerRecordStore.records
        Logger.log("Все записи трекеров (в количестве \(records.count)) были загружены из CoreData: \(records)")
        
        collectionView.reloadData()
    }
}
