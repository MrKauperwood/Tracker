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
    
    private var currentFilter: TrackerFilter = .allTrackers
    
    private var currentSearchText: String = ""
    private let analyticsService = AnalyticsService()
    
    // Добавляем констрейнт для ширины строки поиска
    private var searchBarWidthConstraint: NSLayoutConstraint!
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .lbWhite
        return collectionView
    }()
    
    private let emptyStateLogo: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "EmptyStateLogo"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    private let emptyStateTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("trackers.empty_state.main_logo_text", comment: "")
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .lbBlackAndWhite
        label.isHidden = true
        return label
    }()
    
    private let emptyStateForSearchLogo: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "EmptyStateForSearch"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    private let emptyStateForSearchTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("trackers.empty_state.search_logo_text", comment: "")
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .lbBlackAndWhite
        label.isHidden = true
        return label
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = NSLocalizedString("trackers.searchbar.placeholder", comment: "")
        searchBar.searchBarStyle = .minimal
        searchBar.showsCancelButton = false
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.clearButtonMode = .never
        }
        
        return searchBar
    }()
    
    private let filtersButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("trackers.filters_button.title", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.setTitleColor(.lbWhiteAndWhite, for: .normal)
        button.backgroundColor = .lbBlue
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(filtersButtonTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        
        let currentLocale = Locale.current
        datePicker.locale = currentLocale
        
        datePicker.calendar = Calendar(identifier: .gregorian)
        datePicker.calendar.firstWeekday = 2
        
        return datePicker
    }()
    
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
        
        // Добавляем распознаватель касаний
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // Разрешает обработку нажатий для других элементов
        view.addGestureRecognizer(tapGesture)
        
        setupUI()
        
        Logger.log("Загружен Tracker view контроллер")
        analyticsService.report(event: "open", screen: "Main")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        analyticsService.report(event: "close", screen: "Main")
    }
    
    @objc private func dismissKeyboard() {
        // Скрываем клавиатуру и снимаем фокус с UISearchBar
        view.endEditing(true)
    }
    
    private func filterTrackers(from trackers: [Tracker], for date: Date) {
        guard let weekday = Weekday.from(date: date) else { return }
        Logger.log("Фильтрация трекеров для дня недели: \(weekday)")
        
        filteredTrackers = trackers.filter { tracker in
            if tracker.trackerType == .irregular {
                return true
            }
            return tracker.schedule.contains(weekday)
        }
        
        Logger.log("Отфильтрованный список трекеров: \(filteredTrackers)")
        
    }
    
    func filterCategories(from categories: [TrackerCategory], for date: Date) {
        guard let weekday = Weekday.from(date: date) else { return }
        
        var pinnedTrackers: [Tracker] = []
        var otherCategories: [TrackerCategory] = []
        
        for category in categories {
            var filteredTrackers: [Tracker] = []
            
            for tracker in category.trackers {
                if tracker.isPinned {
                    // Проверяем, подходит ли закрепленный трекер по расписанию
                    if tracker.trackerType == .irregular || tracker.schedule.contains(weekday) {
                        pinnedTrackers.append(tracker)
                    }
                } else if (tracker.trackerType == .habit && tracker.schedule.contains(weekday)) || tracker.trackerType == .irregular {
                    filteredTrackers.append(tracker)
                }
            }
            
            if !filteredTrackers.isEmpty {
                filteredTrackers.sort { $0.name < $1.name }
                otherCategories.append(TrackerCategory(title: category.title, trackers: filteredTrackers))
            }
        }
        
        if !pinnedTrackers.isEmpty {
            let pinnedCategory = TrackerCategory(title: NSLocalizedString("trackers.pinned_category.title", comment: ""), trackers: pinnedTrackers)
            filteredCategories = [pinnedCategory] + otherCategories
        } else {
            filteredCategories = otherCategories
        }
        
        Logger.log("Отфильтрованный список категорий: \(filteredCategories)")
        collectionView.reloadData()
    }
    
    @objc private func handleCategoryUpdate() {
        // Обновляем данные из store
        categories = trackerCategoryStore.categories
        collectionView.reloadData()
        updateEmptyStateVisibility()
    }
    
    @objc private func addButtonTapped() {
        Logger.log("Кнопка '+' нажата, открытие экрана выбора типа трекера")
        analyticsService.report(event: "click", screen: "Main", item: "add_track")
        let trackerTypeVC = TrackerTypeSelectionViewController()
        
        //нужно передать ссылку на trackerStore
        trackerTypeVC.trackerStore = self.trackerStore
        
        //нужно передать ссылку на trackerCategoryStore
        trackerTypeVC.trackerCategoryStore = self.trackerCategoryStore
        
        //нужно передать ссылку на trackerRecordStore
        trackerTypeVC.trackerRecordStore = self.trackerRecordStore
        
        present(trackerTypeVC, animated: true, completion: nil)
    }
    
    @objc private func filtersButtonTapped() {
        analyticsService.report(event: "click", screen: "Main", item: "filter")
        let filterVC = FilterOptionsViewController()
        filterVC.selectedFilter = currentFilter
        filterVC.filterSelected = { [weak self] selectedFilter in
            self?.applyFilter(selectedFilter)
        }
        present(filterVC, animated: true, completion: nil)
    }
    
    private func applyFilter(_ filter: TrackerFilter) {
        currentFilter = filter
        filtersButton.setTitleColor(filter == .allTrackers ? .lbWhite : .lbRed, for: .normal)
        
        switch filter {
        case .allTrackers:
            filterTrackers(from: allExistingTrackers, for: selectedDate)
            filterCategories(from: categories, for: selectedDate)
        case .today:
            let currentDate = Date()
            selectedDate = currentDate
            
            if let datePicker = navigationItem.rightBarButtonItem?.customView as? UIDatePicker {
                datePicker.setDate(currentDate, animated: true)
            }
            filterTrackers(from: allExistingTrackers, for: currentDate)
            filterCategories(from: categories, for: currentDate)
        case .completed:
            // Фильтруем только завершённые трекеры для выбранной даты
            let completedTrackersOnly = filteredTrackers.filter { tracker in
                records.contains { record in
                    record.trackerId == tracker.id && Calendar.current.isDate(record.date, inSameDayAs: selectedDate)
                }
            }
            
            // Обновляем filteredTrackers
            filteredTrackers = completedTrackersOnly
            
            // Обновляем filteredCategories, чтобы включить только завершённые трекеры
            filteredCategories = categories.compactMap { category in
                let trackersInCategory = category.trackers.filter { tracker in
                    completedTrackersOnly.contains { $0.id == tracker.id }
                }
                return trackersInCategory.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackersInCategory)
            }
            
        case .uncompleted:
            filterTrackers(from: allExistingTrackers, for: selectedDate)
            filterCategories(from: categories, for: selectedDate)
            // Фильтруем только невыполненные трекеры для выбранной даты
            let uncompletedTrackersOnly = filteredTrackers.filter { tracker in
                !records.contains { record in
                    record.trackerId == tracker.id && Calendar.current.isDate(record.date, inSameDayAs: selectedDate)
                }
            }
            
            // Обновляем filteredTrackers
            filteredTrackers = uncompletedTrackersOnly
            
            // Обновляем filteredCategories, чтобы включить только невыполненные трекеры
            filteredCategories = categories.compactMap { category in
                let trackersInCategory = category.trackers.filter { tracker in
                    uncompletedTrackersOnly.contains { $0.id == tracker.id }
                }
                return trackersInCategory.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackersInCategory)
            }
        }
        
        let isHidden = !filteredTrackers.isEmpty
        emptyStateForSearchLogo.isHidden = isHidden
        emptyStateForSearchTextLabel.isHidden = isHidden
        
        collectionView.reloadData()
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        let weekday = DateHelper.shared.weekday(from: selectedDate)
        Logger.log("Выбранный день недели: \(String(describing: weekday?.rawValue))")
        
        let formattedDate = DateHelper.shared.formattedDate(from: selectedDate)
        Logger.log("Выбранная дата: \(formattedDate)")
        
        filterTrackers(from: allExistingTrackers, for: selectedDate)
        
        updateUIAfterTrackerChange()
        
        if filtersButton.isEnabled {
            applyFilter(currentFilter)
        }
    }
    
    private func setupUI() {
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = NSLocalizedString("tabbar.trackers.title", comment: "")
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        
        let addButtonImage = UIImage(named: "AddTrackerPlusBotton")
        let addButton = UIBarButtonItem(
            image: addButtonImage,
            style: .plain,
            target: self,
            action: #selector(addButtonTapped))
        
        addButton.tintColor = .lbBlackAndWhite
        
        navigationItem.leftBarButtonItem = addButton
        
        setupDatePicker()
        searchBar.delegate = self
        
        // Устанавливаем начальную ширину строки поиска
        searchBarWidthConstraint = searchBar.widthAnchor.constraint(equalToConstant: view.frame.width - 32)
        searchBarWidthConstraint.isActive = true
        
        
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(emptyStateLogo)
        view.addSubview(emptyStateTextLabel)
        view.addSubview(emptyStateForSearchLogo)
        view.addSubview(emptyStateForSearchTextLabel)
        view.addSubview(filtersButton)
        
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
            emptyStateTextLabel.centerXAnchor.constraint(equalTo: emptyStateLogo.centerXAnchor),
            
            emptyStateForSearchLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateForSearchLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateForSearchTextLabel.topAnchor.constraint(equalTo: emptyStateLogo.bottomAnchor, constant: 8),
            emptyStateForSearchTextLabel.centerXAnchor.constraint(equalTo: emptyStateLogo.centerXAnchor),
            
            filtersButton.widthAnchor.constraint(equalToConstant: 114),
            filtersButton.heightAnchor.constraint(equalToConstant: 50),
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            
        ])
        
        updateEmptyStateVisibility()
    }
    
    private func setupDatePicker() {
        let currentDate = Date()
        let calendar = Calendar.current
        datePicker.maximumDate = currentDate

        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func updateEmptyStateVisibility() {
        setupTrackerCategoryStore()
        setupTrackerStore()
        setupTrackerRecordStore()
        configureEmptyStateVisibility()
    }
    
    private func configureEmptyStateVisibility() {
        let hasFilteredTrackers = !filteredTrackers.isEmpty
        let isSearchActive = !currentSearchText.isEmpty
        
        if isSearchActive {
            emptyStateLogo.isHidden = true
            emptyStateTextLabel.isHidden = true
            emptyStateForSearchLogo.isHidden = hasFilteredTrackers
            emptyStateForSearchTextLabel.isHidden = hasFilteredTrackers
        } else {
            emptyStateLogo.isHidden = hasFilteredTrackers
            emptyStateTextLabel.isHidden = hasFilteredTrackers
            emptyStateForSearchLogo.isHidden = true
            emptyStateForSearchTextLabel.isHidden = true
        }
        
        collectionView.isHidden = !hasFilteredTrackers
        filtersButton.isHidden = !hasFilteredTrackers
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
        
        analyticsService.report(event: "click", screen: "Main", item: "track")
        
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
                
                setupTrackerCategoryStore()
                setupTrackerStore()
                setupTrackerRecordStore()
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
        filterCategories(from: categories, for: selectedDate)
        filterTrackersAndCategories(for: currentSearchText)
        collectionView.reloadData()
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

// MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            return self.makeContextMenu(for: tracker)
        }
    }
    
    private func makeContextMenu(for tracker: Tracker) -> UIMenu {
        
        let pinAction = UIAction(
            title: tracker.isPinned ? NSLocalizedString("trackers.unpin_action.title", comment: "") : NSLocalizedString("trackers.pin_action.title", comment: "")
        ) { _ in
            self.togglePin(for: tracker)
        }
        
        let editAction = UIAction(
            title: NSLocalizedString("trackers.edit_action.title", comment: "n")
        ) { _ in
            self.analyticsService.report(event: "click", screen: "Main", item: "edit")
            self.editTracker(tracker)
        }
        
        let deleteAction = UIAction(
            title: NSLocalizedString("trackers.delete_action.title", comment: ""),
            attributes: .destructive
        ) { _ in
            self.analyticsService.report(event: "click", screen: "Main", item: "delete")
            self.deleteTracker(tracker)
        }
        
        return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
    }
    
    private func togglePin(for tracker: Tracker) {
        
        // Создаем новый экземпляр трекера с обновленным статусом
        let updatedTracker = tracker.togglePinnedStatus()
        
        // Здесь будет логика для закрепления/открепления трекера
        Logger.log("Изменение статуса закрепления для трекера: \(tracker.name)")
        
        do {
            try trackerStore.updatePinStatus(for: tracker, isPinned: updatedTracker.isPinned)
            Logger.log("Трекер \(tracker.name) \(tracker.isPinned ? "добавлен в избранное" : "удален из избранного")")
            
            setupTrackerStore()
            updateUIAfterTrackerChange()
        } catch {
            Logger.log("Ошибка при обновлении статуса закрепления для трекера: \(error)", level: .error)
        }
    }
    
    private func editTracker(_ tracker: Tracker) {
        let editVC = NewHabitViewController()
        editVC.trackerStore = self.trackerStore
        editVC.trackerCategoryStore = self.trackerCategoryStore
        editVC.trackerRecordStore = self.trackerRecordStore
        
        editVC.trackerType = tracker.trackerType
        editVC.selectedSchedule = tracker.schedule
        editVC.selectedEmoji = tracker.emoji
        editVC.selectedColor = tracker.color
        
        guard let category = trackerCategoryStore.categories.first(where: { category in
            category.trackers.contains(where: { $0.id == tracker.id })
        }) else {
            Logger.log("Категория для данного трекера не найдена", level: .error)
            return
        }
        
        let completedDaysCount = trackerRecordStore.records.filter { $0.trackerId == tracker.id }.count
        let daysCompletedText = "\(completedDaysCount) \(DayWordFormatter.getDayWord(for: completedDaysCount))"
        
        editVC.counterLabel.text = daysCompletedText
        editVC.selectedCategory = category
        editVC.textField.text = tracker.name
        editVC.existingTrackerId = tracker.id
        editVC.isEditingMode = true
        
        present(editVC, animated: true, completion: nil)
    }
    
    private func deleteTracker(_ tracker: Tracker) {
        let alertController = UIAlertController(title: "", message: NSLocalizedString("trackers.delete_confirmation.message", comment: ""), preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: NSLocalizedString("trackers.delete_action.title", comment: ""), style: .destructive) { _ in
            do {
                // Удаляем трекер из store
                try self.trackerStore.deleteTracker(tracker)
                self.removeTracker(tracker)
                self.updateUIAfterTrackerChange()
                
                Logger.log("Трекер \(tracker.name) успешно удален")
            } catch {
                Logger.log("Ошибка при удалении трекера: \(error)", level: .error)
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("trackers.cancel_action.title", comment: ""), style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
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
    }
    
    func trackerUncompleted(_ tracker: Tracker, on date: Date) {
        completedTrackers.removeAll { record in
            record.trackerId == tracker.id && Calendar.current.isDate(record.date, inSameDayAs: date)
        }
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

extension TrackersViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        
        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
            cancelButton.setTitle(NSLocalizedString("trackers.cancel_action.title", comment: ""), for: .normal)
        }
        
        searchBarWidthConstraint.constant = view.frame.width - 200
        searchBar.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentSearchText = searchText
        filterTrackersAndCategories(for: searchText)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // Проверяем, пуста ли строка поиска
        if searchBar.text?.isEmpty ?? true {
            // Скрываем кнопку "Отменить", если строка поиска пуста
            searchBar.setShowsCancelButton(false, animated: true)
        }
        
        // Восстанавливаем ширину строки поиска
        searchBarWidthConstraint.constant = view.frame.width - 32
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        currentSearchText = ""
        filterTrackersAndCategories(for: "")
        searchBar.resignFirstResponder()
    }
    
    private func filterTrackersAndCategories(for searchText: String) {
        // Сначала фильтруем трекеры по дню недели
        filterTrackers(from: allExistingTrackers, for: selectedDate)
        filterCategories(from: categories, for: selectedDate)
        
        if !searchText.isEmpty {
            // Фильтруем трекеры по введенному тексту
            filteredTrackers = filteredTrackers.filter { tracker in
                tracker.name.lowercased().contains(searchText.lowercased())
            }
            
            // Проверяем, есть ли среди отфильтрованных трекеров закрепленные
            let pinnedTrackers = filteredTrackers.filter { $0.isPinned }
            let nonPinnedTrackers = filteredTrackers.filter { !$0.isPinned }
            
            // Создаем временную категорию "Закрепленные" и добавляем её в начало списка, если есть закрепленные трекеры
            filteredCategories = []
            if !pinnedTrackers.isEmpty {
                let pinnedCategory = TrackerCategory(title: NSLocalizedString("trackers.pinned_category.title", comment: ""), trackers: pinnedTrackers)
                filteredCategories.append(pinnedCategory)
            }
            
            // Фильтруем категории, исключая закрепленные трекеры
            let remainingCategories = categories.compactMap { category in
                let trackersInCategory = category.trackers.filter { tracker in
                    nonPinnedTrackers.contains(where: { $0.id == tracker.id })
                }
                return trackersInCategory.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackersInCategory)
            }
            
            // Добавляем оставшиеся категории в список
            filteredCategories.append(contentsOf: remainingCategories)
        }
        
        configureEmptyStateVisibility()
        collectionView.reloadData()
    }
}

extension TrackersViewController {
    
    public func setSearchBarText(_ text: String) {
        searchBar.text = text
        currentSearchText = text
        searchBarTextDidBeginEditing(searchBar)
        filterTrackersAndCategories(for: text)
    }
    
    public func filterAndReloadData() {
        filterTrackers(from: allExistingTrackers, for: selectedDate)
        filterCategories(from: categories, for: selectedDate)
        collectionView.reloadData()
        configureEmptyStateVisibility()
    }
    
    var setAllExistingTrackers: [Tracker] {
        get {
            return allExistingTrackers
        }
        set {
            allExistingTrackers = newValue
        }
    }
    
    var setAllExistingCategories: [TrackerCategory] {
        get {
            return categories
        }
        set {
            categories = newValue
        }
    }
    
    var setAllRecords: [TrackerRecord] {
        get {
            return records
        }
        set {
            records = newValue
        }
    }
}
