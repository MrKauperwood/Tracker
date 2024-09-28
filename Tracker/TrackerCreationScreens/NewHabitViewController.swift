//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by Aleksei Bondarenko on 22.9.2024.
//

import UIKit

final class NewHabitViewController: UIViewController {
    
    // MARK: - Public Properties
    
    var trackerType: TrackerType = .habit
    
    // MARK: - Private Properties
    
    private var selectedSchedule: [Weekday] = []
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Новая привычка"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        titleLabel.textAlignment = .center
        
        return titleLabel
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
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
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lbRed
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textAlignment = .center
        label.isHidden = true // Изначально скрыта
        return label
    }()
    
    private let clearButtonContainer: UIView = {
        // Учитывая ширину кнопки (17) и отступ (12), создаем контейнер с шириной 29
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 29, height: 17))
        return container
    }()
    
    private let clearButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .gray
        button.frame = CGRect(x: 0, y: 0, width: 17, height: 17)
        button.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        button.isHidden = true // Изначально скрыта
        return button
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        
        tableView.backgroundColor = .lbBackground
        
        // Радиус скругления
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        
        return tableView
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        
        button.setTitleColor(UIColor(named: "LB_red"), for: .normal) // Применяем цвет текста
        button.layer.borderColor = UIColor(named: "LB_red")?.cgColor // Цвет бордера из ассетов
        button.layer.borderWidth = 1 // Ширина бордера
        button.layer.cornerRadius = 16 // Радиус скругления
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private let createButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(UIColor(named: "LB_white"), for: .normal)
        button.layer.borderColor = UIColor(named: "LB_white")?.cgColor
        button.backgroundColor = UIColor(named: "LB_grey")
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually // Равномерное распределение кнопок
        stackView.spacing = 10 // Отступ между кнопками
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var tableData: [String] {
        return trackerType == .habit ? ["Категория", "Расписание"] : ["Категория"]
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
        
        // Устанавливаем заголовок в зависимости от типа трекера
        titleLabel.text = trackerType == .habit ? "Новая привычка" : "Новое нерегулярное событие"
        
        // Настройка крестика с отступом
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
        
        // Регистрация ячеек
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "emojiCell")
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "colorCell")
        
        // Регистрация table view
        tableView.register(CustomTableViewCellForNewHabit.self, forCellReuseIdentifier: "CustomCellForNewHabit")
        
        view.backgroundColor = .white
        
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
        view.addSubview(titleLabel)
        view.addSubview(textField)
        view.addSubview(errorLabel)
        view.addSubview(tableView)
        view.addSubview(collectionView)
        
        // Добавляем кнопки в стек
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(createButton)
        
        view.addSubview(buttonStackView)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            
            // Title layout
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Tracker's name text field layout
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // ErrorLabel's layout
            errorLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Tracker's settings Table view layout
            tableView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(75 * tableData.count)),
            
            // Emoji collection view layout
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            //            collectionView.heightAnchor.constraint(equalToConstant: calculateCollectionHeight()),
            collectionView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -16),
            
            // Layout для buttonStackView
            buttonStackView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
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
            errorLabel.text = "Ограничение 38 символов"
            errorLabel.isHidden = false
        } else {
            errorLabel.isHidden = true
        }
    }
    
    @objc private func clearTextField() {
        textField.text = ""
        clearButton.isHidden = true
        validateForm() // Обновляем форму после очистки поля
    }
    
    private func validateForm() {
        let isTrackerNameValid = !(textField.text?.isEmpty ?? true) && (textField.text?.count ?? 0) <= 38
        
        let isScheduleSelected = trackerType == .habit ? !selectedSchedule.isEmpty : true
        let isCategorySelected = true // Заменить на логику проверки выбранной категории
        
        if isTrackerNameValid && isScheduleSelected && isCategorySelected {
            createButton.isEnabled = true
            createButton.backgroundColor = UIColor(named: "LB_black")
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = UIColor(named: "LB_grey")
        }
        
        Logger.log("Форма валидна: \(isTrackerNameValid && isScheduleSelected && isCategorySelected)", level: .debug)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderView.identifier, for: indexPath) as! SectionHeaderView
        
        if indexPath.section == 0 {
            header.title = "Emoji"
        } else {
            header.title = "Цвет"
        }
        
        return header
    }
    
    func calculateCollectionHeight() -> CGFloat {
        let numberOfItemsPerRow: CGFloat = 6
        let itemHeight: CGFloat = 52
        let spacing: CGFloat = 16
        
        // Рассчитываем высоту для секции с эмодзи
        let numberOfRowsEmoji = ceil(CGFloat(emojis.count) / numberOfItemsPerRow)
        let emojiHeight = (numberOfRowsEmoji * itemHeight) + ((numberOfRowsEmoji - 1) * spacing)
        
        // Рассчитываем высоту для секции с цветами
        let numberOfRowsColors = ceil(CGFloat(colors.count) / numberOfItemsPerRow)
        let colorsHeight = (numberOfRowsColors * itemHeight) + ((numberOfRowsColors - 1) * spacing)
        
        // Динамически получаем высоту заголовка
        let headerHeight = self.collectionView(
            collectionView,
            layout: collectionView.collectionViewLayout as! UICollectionViewFlowLayout,
            referenceSizeForHeaderInSection: 0
        ).height
        
        return emojiHeight + colorsHeight + (headerHeight * 2) // Учитываем два заголовка
    }
    
    @objc func createButtonTapped() {
        
        // Проверяем, введено ли имя трекера
        guard let trackerName = textField.text, !trackerName.isEmpty else {
            // Показываем предупреждение, если имя не введено
            return
        }
        
        // Категория по умолчанию (вы можете реализовать выбор категории позже)
        let categoryTitle = trackerType == .habit ? "Обучение" : "Нерегулярные события"
        
        // Выбираем цвет и эмодзи. Для упрощения выберем первый вариант из списка (позже можно добавить логику выбора)
        let selectedColor = colors.first ?? .lbCS13Peach
        let selectedEmoji = emojis.first ?? "😊"
        
        // Создаем новый трекер
        let newTracker = Tracker(
            id: UUID(),
            name: trackerName,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: trackerType == .habit ? selectedSchedule : [],
            trackerType: trackerType
        )
        
        if let parentVC = ((presentingViewController?.presentingViewController as? TabBarController)?.selectedViewController as? UINavigationController)?.viewControllers.first(where: { $0 is TrackersViewController }) as? TrackersViewController {
            // Используем навигационный стек, если нашли контроллер
            parentVC.addTracker(newTracker, to: categoryTitle)
            // После добавления трекера фильтруем трекеры для выбранной даты
            let currentWeekday = parentVC.getWeekday(from: parentVC.selectedDate)
            parentVC.filterCategories(by: currentWeekday)
            
            parentVC.reloadData() // Обновляем данные на экране
            navigationController?.popViewController(animated: true) // Возвращаемся к предыдущему экрану
        } else if let parentVC = presentingViewController?.presentingViewController as? TrackersViewController {
            // Если контроллер был представлен модально
            parentVC.addTracker(newTracker, to: categoryTitle)
            parentVC.reloadData() // Обновляем данные на экране
            dismiss(animated: true, completion: nil) // Закрываем экран создания
        } else {
            // Обработка случая, если контроллер не был найден
            print("Не удалось найти TrackersViewController")
        }
        // Закрываем все модальные окна
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
                    cell.configureDescription("Каждый день")
                } else {
                    let sortedDays = selectedSchedule.sorted { Weekday.orderedWeekdays.firstIndex(of: $0)! < Weekday.orderedWeekdays.firstIndex(of: $1)! }
                    cell.configureDescription(sortedDays.isEmpty ? "" : sortedDays.map { $0.shortName }.joined(separator: ", "))
                }
            }
        } else if indexPath.row == 0 {
            cell.configureDescription("Важное")
        }
        
        cell.backgroundColor = .clear
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}


// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension NewHabitViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2 // Секция 0 для эмодзи, секция 1 для цветов
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? emojis.count : colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath)
            let emojiLabel = UILabel()
            emojiLabel.text = emojis[indexPath.item]
            emojiLabel.font = UIFont.systemFont(ofSize: 32)
            emojiLabel.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(emojiLabel)
            NSLayoutConstraint.activate([
                emojiLabel.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                emojiLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath)
            cell.backgroundColor = colors[indexPath.item]
            cell.layer.cornerRadius = 8
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
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
        validateForm() // Проверка формы после подтверждения изменений
        return true
    }
}
