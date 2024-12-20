import UIKit

final class NewHabitViewController: UIViewController {
    
    // MARK: - Public Properties
    
    var trackerType: TrackerType = .habit
    var trackerStore: TrackerStore!
    var trackerCategoryStore: TrackerCategoryStore!
    var trackerRecordStore: TrackerRecordStore!
    
    var selectedSchedule: [Weekday] = []
    var selectedEmoji: String?
    var selectedColor: UIColor?
    var selectedCategory: TrackerCategory?
    
    var isEditingMode: Bool = false
    var existingTrackerId: UUID?
    
    // MARK: - UI Elements
    
    public lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("new_habit.text_field.placeholder", comment: "")
        textField.returnKeyType = .go
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        // Внутренние отступы (padding)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0)) // отступ слева
        textField.leftViewMode = .always
        
        textField.backgroundColor = .lbBackground
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        
        return textField
    }()
    
    public lazy var counterLabel: UILabel = {
        let counterLabel = UILabel()
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
        counterLabel.text = "0"
        
        counterLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        counterLabel.textAlignment = .center
        
        return counterLabel
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = isEditingMode
        ? NSLocalizedString("new_habit.title.edit_habit", comment: "") : NSLocalizedString("new_habit.title.new_habit", comment: "")
        
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textAlignment = .center
        
        return titleLabel
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lbRed
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textAlignment = .center
        label.isHidden = true // Изначально скрыта
        return label
    }()
    
    private lazy var clearButtonContainer: UIView = {
        // Учитывая ширину кнопки (17) и отступ (12), создаем контейнер с шириной 29
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 29, height: 17))
        return container
    }()
    
    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .gray
        button.frame = CGRect(x: 0, y: 0, width: 17, height: 17)
        button.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        button.isHidden = true // Изначально скрыта
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        
        tableView.backgroundColor = .lbBackground
        
        // Радиус скругления
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        
        return tableView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false // Отключаем скроллинг коллекции
        return collectionView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("new_habit.cancel_button.title", comment: ""), for: .normal)
        
        button.setTitleColor(UIColor(named: "LB_red"), for: .normal)
        button.layer.borderColor = UIColor(named: "LB_red")?.cgColor
        button.layer.borderWidth = 1 // Ширина бордера
        button.layer.cornerRadius = 16 // Радиус скругления
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        return button
    }()
    
    private lazy var createButton: UIButton = {
        
        let button = UIButton(type: .system)
        if !isEditingMode {
            button.setTitle(NSLocalizedString("new_habit.create_button.title.create", comment: ""), for: .normal)
        } else {
            button.setTitle(NSLocalizedString("new_habit.create_button.title.save", comment: ""), for: .normal)
        }
        
        button.setTitleColor(UIColor(named: "LB_white"), for: .normal)
        button.layer.borderColor = UIColor(named: "LB_white")?.cgColor
        button.backgroundColor = UIColor(named: "LB_grey")
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var tableData: [String] {
        return trackerType == .habit ? [
            NSLocalizedString("new_habit.table_row.category", comment: ""),
            NSLocalizedString("new_habit.table_row.schedule", comment: "")] : [NSLocalizedString("new_habit.table_row.category", comment: "")]
    }
    private let emojis = ["😊", "😻", "🌸", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🏅", "🎸", "🏖", "😪"]
    private let colors: [UIColor] = [
        .lbCS1Red, .lbCS2Orange, .lbCS3Blue, .lbCS4Purple, .lbCS5Green, .lbCS6Pink,
        .lbCS7LightPink, .lbCS8BrightBlue, .lbCS9MintGreen, .lbCS10DarkBlue,
        .lbCS11OrangeRed, .lbCS12BrightPink, .lbCS13Peach, .lbCS14LightBlue,
        .lbCS15Violet, .lbCS16PurplePink, .lbCS17Lilac, .lbCS18BrightGreen]
    
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Logger.log("Экран создания новой привычки загружен")
        
        titleLabel.text = trackerType == .habit
        ? NSLocalizedString("new_habit.title.new_habit", comment: "")
        : NSLocalizedString("new_habit.title.new_irregular_event", comment: "")
        if isEditingMode {
            titleLabel.text = NSLocalizedString("new_habit.title.edit_habit", comment: "")
            counterLabel.isHidden = false
        } else {
            counterLabel.isHidden = true
        }
        
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButtonContainer.addSubview(clearButton)
        
        NSLayoutConstraint.activate([
            clearButton.leadingAnchor.constraint(equalTo: clearButtonContainer.leadingAnchor),
            clearButton.centerYAnchor.constraint(equalTo: clearButtonContainer.centerYAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: 17),
            clearButton.heightAnchor.constraint(equalToConstant: 17),
            
            clearButton.trailingAnchor.constraint(equalTo: clearButtonContainer.trailingAnchor, constant: -12)
        ])
        
        // Устанавливаем контейнер с кнопкой в качестве правого вида для UITextField
        textField.rightView = clearButtonContainer
        textField.rightViewMode = .whileEditing
        
        // Добавляем жест для скрытия клавиатуры при нажатии на любое место
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        textField.delegate = self
        
        validateForm()
        
        // Регистрация Supplementary View
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.identifier)
        
        // Добавляем таргет для кнопки отмены
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "emojiCell")
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "colorCell")
        
        tableView.register(CustomTableViewCellForNewHabit.self, forCellReuseIdentifier: "CustomCellForNewHabit")
        
        view.backgroundColor = .lbWhite
        
        // Setup table view
        tableView.delegate = self
        tableView.dataSource = self
        
        // Register cell for table view
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // Setup collection views
        collectionView.delegate = self
        collectionView.dataSource = self
        
        setupUI()
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        // Добавляем scrollView на главный view
        view.addSubview(scrollView)
        
        // Добавляем contentStackView внутрь scrollView
        scrollView.addSubview(contentStackView)
        
        // Добавляем кнопки в стек
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(createButton)
        
        // Добавляем все элементы в contentStackView
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(counterLabel)
        contentStackView.addArrangedSubview(textField)
        contentStackView.addArrangedSubview(errorLabel)
        contentStackView.addArrangedSubview(tableView)
        contentStackView.addArrangedSubview(collectionView)
        contentStackView.addArrangedSubview(buttonStackView)
        
        contentStackView.setCustomSpacing(38, after: titleLabel)
        
        // Констрейнты для scrollView
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Констрейнты для contentStackView
        NSLayoutConstraint.activate([
            counterLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            counterLabel.bottomAnchor.constraint(equalTo: textField.topAnchor, constant: -40),
        ])
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 30),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
        
        // Констрейнты для tableView (например, высота зависит от количества строк)
        NSLayoutConstraint.activate([
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(75 * tableData.count)) // Высота таблицы
        ])
        
        // Констрейнты для collectionView (можно вычислять динамически при необходимости)
        NSLayoutConstraint.activate([
            collectionView.heightAnchor.constraint(equalToConstant: calculateCollectionHeight())
        ])
        
        // Констрейнты для buttonStackView (если требуется фиксированная высота)
        NSLayoutConstraint.activate([
            buttonStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func handleTapOutside() {
        // Скрываем клавиатуру
        textField.resignFirstResponder()
        
        // Выполняем проверку формы, как в методе `textFieldShouldReturn`
        validateForm()
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil) // Закрываем экран без сохранения изменений
    }
    
    @objc private func textFieldDidChange() {
        clearButton.isHidden = textField.text?.isEmpty ?? true
        validateForm()
        
        // Проверяем длину текста
        if let text = textField.text, text.count > 38 {
            errorLabel.text = NSLocalizedString("new_habit.error_label.text", comment: "")
            errorLabel.isHidden = false
        } else {
            errorLabel.isHidden = true
        }
    }
    
    @objc private func clearTextField() {
        textField.text = ""
        clearButton.isHidden = true
        validateForm() // Обновляем форму после очистки поля
        errorLabel.isHidden = true
    }
    
    private func validateForm() {
        let isTrackerNameValid = !(textField.text?.isEmpty ?? true) && (textField.text?.count ?? 0) <= 38
        
        let isScheduleSelected = trackerType == .habit ? !selectedSchedule.isEmpty : true
        let isCategorySelected = true // Заменить на логику проверки выбранной категории
        
        // Новые условия: проверка выбора эмодзи и цвета
        let isEmojiSelected = selectedEmoji != nil
        let isColorSelected = selectedColor != nil
        
        if isTrackerNameValid && isScheduleSelected && isCategorySelected && isEmojiSelected && isColorSelected {
            createButton.isEnabled = true
            createButton.backgroundColor = UIColor(named: "LB_blackAndWhite")
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = UIColor(named: "LB_grey")
        }
        
        Logger.log("Форма валидна: \(isTrackerNameValid && isScheduleSelected && isCategorySelected && isEmojiSelected && isColorSelected)", level: .debug)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderView.identifier, for: indexPath) as! SectionHeaderView
        
        if indexPath.section == 0 {
            header.title = NSLocalizedString("new_habit.section_header.emoji", comment: "")
        } else {
            header.title = NSLocalizedString("new_habit.section_header.color", comment: "")
        }
        
        return header
    }
    
    func calculateCollectionHeight() -> CGFloat {
        let numberOfItemsPerRow: CGFloat = 6
        let itemHeight: CGFloat = 52
        let spacing: CGFloat = 10
        
        // Рассчитываем высоту для секции с эмодзи
        let numberOfRowsEmoji = ceil(CGFloat(emojis.count) / numberOfItemsPerRow)
        let emojiHeight = (numberOfRowsEmoji * itemHeight) + ((numberOfRowsEmoji - 1) * spacing)
        
        // Рассчитываем высоту для секции с цветами
        let numberOfRowsColors = ceil(CGFloat(colors.count) / numberOfItemsPerRow)
        let colorsHeight = (numberOfRowsColors * itemHeight) + ((numberOfRowsColors - 1) * spacing)
        
        // Высота заголовков (если у вас фиксированная высота заголовков)
        let headerHeight: CGFloat = 50.0 // Высота заголовка для каждой секции
        
        // Общая высота: высота эмодзи + высота цветов + высота заголовков
        let totalHeight = emojiHeight + colorsHeight + (headerHeight * 2) + 30
        
        return totalHeight
    }
    
    @objc private func createButtonTapped() {
        
        // Проверяем, введено ли имя трекера
        guard let trackerName = textField.text, !trackerName.isEmpty else {
            return
        }
        
        guard let categoryTitle = selectedCategory?.title else {
            Logger.log("Категория не выбрана", level: .error)
            return
        }
        
        guard let selectedEmoji = selectedEmoji else {
            return
        }
        
        guard let selectedColor = selectedColor else {
            return
        }
        
        let trackerID = isEditingMode ? (existingTrackerId ?? UUID()) : UUID()
        
        let newTracker = Tracker(
            id: trackerID,
            name: trackerName,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: trackerType == .habit ? selectedSchedule : [],
            trackerType: trackerType
        )
        
        do {
            if isEditingMode {
                let updatedCategoryName = categoryTitle
                try trackerStore.updateTracker(with: newTracker.id, updatedTracker: newTracker, updatedCategoryName: updatedCategoryName)
            } else {
                let newCategory = TrackerCategory(title: categoryTitle, trackers: [])
                try trackerStore.addTracker(newTracker, to: newCategory)
            }
            
        } catch {
            Logger.log("Ошибка при сохранении трекера: \(error)", level: .error)
            return
        }
        
        if let parentVC = ((presentingViewController?.presentingViewController as? TabBarController)?.selectedViewController as? UINavigationController)?.viewControllers.first(where: { $0 is TrackersViewController }) as? TrackersViewController {
            
            // Обновляем данные из базы в TrackersViewController
            parentVC.setupTrackerStore()
            
            // Используем навигационный стек, если нашли контроллер
            parentVC.addTracker(newTracker, to: categoryTitle)
            
            // После добавления трекера фильтруем трекеры для выбранной даты
            parentVC.filterCategories(from: parentVC.getCategories, for: parentVC.selectedDate)
            
            parentVC.reloadData() // Обновляем данные на экране
            navigationController?.popViewController(animated: true) // Возвращаемся к предыдущему экрану
        } else if let parentVC = presentingViewController?.presentingViewController as? TrackersViewController {
            // Если контроллер был представлен модально
            parentVC.addTracker(newTracker, to: categoryTitle)
            parentVC.reloadData() // Обновляем данные на экране
            dismiss(animated: true, completion: nil) // Закрываем экран создания
        } else if let tabBarController = self.presentingViewController as? TabBarController,
                  let navController = tabBarController.selectedViewController as? UINavigationController,
                  let parentVC = navController.viewControllers.first(where: { $0 is TrackersViewController }) as? TrackersViewController {
            parentVC.reloadData() // Обновляем данные на экране
            isEditingMode = false
            dismiss(animated: true, completion: nil) // Закрываем экран создания
        }
        
        presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        
        Logger.log("Создан новый трекер: \(trackerName) с эмодзи \(selectedEmoji) и цветом \(selectedColor)")
    }
}


// MARK: - UITableViewDelegate
extension NewHabitViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if trackerType == .habit && indexPath.row == 1 { // Для строки с "Расписание"
            let scheduleVC = ScheduleViewController()
            scheduleVC.selectedDays = Set(selectedSchedule)
            scheduleVC.onScheduleSelected = { [weak self] selectedDays in
                self?.selectedSchedule = Array(selectedDays) // Сохраняем выбранные дни
                self?.tableView.reloadData() // Обновляем таблицу для отображения новых данных
                self?.validateForm() // Проверяем состояние формы
            }
            
            let navController = UINavigationController(rootViewController: scheduleVC)
            present(navController, animated: true, completion: nil)
        } else if trackerType == .habit && indexPath.row == 0 {
            
            guard let categoryStore = trackerCategoryStore else { return }
            let categoryViewModel = CategorySelectionViewModel(trackerCategoryStore: categoryStore)
            
            // Создаем CategorySelectionViewController и передаем ViewModel
            let categorySelectionVC = CategorySelectionViewController(viewModel: categoryViewModel)
            
            // Установка замыкания для обновления выбранной категории
            categorySelectionVC.onCategorySelected = { [weak self] selectedCategory in
                guard let self = self else { return }
                self.selectedCategory = selectedCategory // Обновляем выбранную категорию
                self.tableView.reloadRows(at: [indexPath], with: .none) // Перезагружаем ячейку категории
            }
            
            // Презентация контроллера выбора категории
            let navController = UINavigationController(rootViewController: categorySelectionVC)
            present(navController, animated: true, completion: nil)
        } else if trackerType == .irregular && indexPath.row == 0 {
            
            guard let categoryStore = trackerCategoryStore else { return }
            let categoryViewModel = CategorySelectionViewModel(trackerCategoryStore: categoryStore)
            
            // Создаем CategorySelectionViewController и передаем ViewModel
            let categorySelectionVC = CategorySelectionViewController(viewModel: categoryViewModel)
            
            // Установка замыкания для обновления выбранной категории
            categorySelectionVC.onCategorySelected = { [weak self] selectedCategory in
                guard let self = self else { return }
                self.selectedCategory = selectedCategory // Обновляем выбранную категорию
                self.tableView.reloadRows(at: [indexPath], with: .none) // Перезагружаем ячейку категории
            }
            
            // Презентация контроллера выбора категории
            let navController = UINavigationController(rootViewController: categorySelectionVC)
            present(navController, animated: true, completion: nil)
        }
        Logger.log("Выбрана строка с индексом \(indexPath.row) в таблице")
    }
}


// MARK: - UITableViewDataSource
extension NewHabitViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackerType == .habit ? 2 : 1 // Если привычка, 2 строки, иначе 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCellForNewHabit", for: indexPath) as! CustomTableViewCellForNewHabit
        cell.configureTitle(tableData[indexPath.row])
        
        if indexPath.row == 1 {
            // Проверяем, выбраны ли все дни недели
            if trackerType == .habit {
                // Если это привычка, показываем расписание
                if selectedSchedule.count == Weekday.allCases.count {
                    cell.configureDescription(NSLocalizedString("new_habit.schedule.every_day", comment: ""))
                } else {
                    let sortedDays = selectedSchedule.sorted { Weekday.orderedWeekdays.firstIndex(of: $0)! < Weekday.orderedWeekdays.firstIndex(of: $1)! }
                    cell.configureDescription(sortedDays.isEmpty ? "" : sortedDays.map { $0.shortName }.joined(separator: ", "))
                }
            }
        } else if indexPath.row == 0 {
            let categoryDescription = selectedCategory?.title ?? ""
            cell.configureDescription(categoryDescription)
        }
        
        cell.backgroundColor = .clear
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}


// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension NewHabitViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Private Methods
    private func configureEmojiCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath)
        
        // Удаляем все подвиды ячейки, чтобы избежать наложения
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let emojiLabel = UILabel()
        emojiLabel.text = emojis[indexPath.item]
        emojiLabel.font = UIFont.systemFont(ofSize: 32)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
        ])
        
        // Меняем фон ячейки и добавляем закругленные углы, если эмодзи выбрано
        if selectedEmoji == emojis[indexPath.item] {
            cell.backgroundColor = .lbLightGrey
            cell.layer.cornerRadius = 16
        } else {
            cell.backgroundColor = .clear
            cell.layer.cornerRadius = 0
        }
        
        return cell
    }
    
    private func configureColorCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath)
        
        // Удаляем все подвиды, чтобы избежать дублирования при повторном использовании ячейки
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let colorView = UIView()
        colorView.backgroundColor = colors[indexPath.item]
        colorView.layer.cornerRadius = 8
        colorView.layer.masksToBounds = true
        colorView.translatesAutoresizingMaskIntoConstraints = false
        
        cell.contentView.addSubview(colorView)
        
        // Констрейнты для представления цвета (размер 40x40, центрируем внутри ячейки)
        NSLayoutConstraint.activate([
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
        ])
        
        // Добавляем обрамление только для выбранного цвета
        if selectedColor == colors[indexPath.item] {
            cell.layer.borderWidth = 3
            cell.layer.borderColor = colors[indexPath.item].withAlphaComponent(0.3).cgColor
            cell.layer.cornerRadius = 8
        } else {
            cell.layer.borderWidth = 0
        }
        
        return cell
    }
    
    // MARK: - Public Methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2 // Секция 0 для эмодзи, секция 1 для цветов
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? emojis.count : colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            return configureEmojiCell(for: collectionView, at: indexPath)
        } else {
            return configureColorCell(for: collectionView, at: indexPath)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            // Секция с эмодзи
            selectedEmoji = emojis[indexPath.item]
            collectionView.reloadSections(IndexSet(integer: 0)) // Перезагружаем секцию эмодзи
            validateForm()
            Logger.log("Выбран эмодзи: \(selectedEmoji ?? "")")
        } else {
            selectedColor = colors[indexPath.item]
            collectionView.reloadSections(IndexSet(integer: 1)) // Перезагружаем секцию эмодзи
            validateForm()
            Logger.log("Выбран цвет: \(selectedColor?.description ?? "")")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow: CGFloat = 6
        let spacing: CGFloat = 10 // Отступ между ячейками
        let totalSpacing = spacing * (numberOfItemsPerRow - 1)
        let width = (collectionView.bounds.width - totalSpacing) / numberOfItemsPerRow
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5 // Вертикальный отступ между строками
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0 // Горизонтальный отступ между ячейками
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
}


// MARK: - UITextFieldDelegate
extension NewHabitViewController: UITextFieldDelegate {
    
    // Реализация делегата
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Закрытие клавиатуры
        validateForm()
        return true
    }
}
