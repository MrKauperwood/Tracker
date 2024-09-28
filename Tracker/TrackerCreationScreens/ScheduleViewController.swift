//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Aleksei Bondarenko on 25.9.2024.
//

import UIKit

final class ScheduleViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.text = "Расписание"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    private let tableView = UITableView() // Таблица для отображения дней недели
    var selectedDays: Set<Weekday> = [] // Массив для хранения выбранных дней
    
    var onScheduleSelected: ((Set<Weekday>) -> Void)?
    var tableHeightConstraint: NSLayoutConstraint? // Переменная для хранения констрейнта высоты таблицы
    
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Настройка цвета текста и шрифта
        button.setTitleColor(.white, for: .normal) // Устанавливаем белый цвет текста
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16) // Устанавливаем размер шрифта 16
        
        // Размеры кнопки
        button.widthAnchor.constraint(equalToConstant: 335).isActive = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        button.backgroundColor = .lbBlack
        button.layer.cornerRadius = 16
        
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(titleLabel)
        view.addSubview(doneButton)
        
        view.backgroundColor = .white
        
        // Настройка таблицы
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 75
        
        // Настройка скругления углов таблицы
        tableView.layer.cornerRadius = 16 // Задайте радиус углов
        tableView.layer.maskedCorners = [
            .layerMinXMinYCorner, // Верхний левый угол
            .layerMaxXMinYCorner, // Верхний правый угол
            .layerMinXMaxYCorner, // Нижний левый угол
            .layerMaxXMaxYCorner  // Нижний правый угол
        ]
        tableView.clipsToBounds = true
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            
            // Title layout
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Констрейнты для таблицы
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
        
        // Регистрация ячейки для таблицы
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "dayCell")
        
        
        // Добавляем констрейнт высоты для таблицы и сохраняем его в переменную
        tableHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableHeightConstraint?.isActive = true
        
        // Обновляем высоту таблицы на основе контента
        updateTableViewHeight()
        
        Logger.log("Экран расписания загружен")
    }
    
    func updateTableViewHeight() {
        tableView.layoutIfNeeded() // Обновляем макет таблицы
        let tableHeight = tableView.contentSize.height // Получаем высоту контента таблицы
        
        // Обновляем значение существующего констрейнта высоты таблицы
        tableHeightConstraint?.constant = tableHeight
        Logger.log("Высота таблицы обновлена: \(tableView.contentSize.height)", level: .debug)
    }
    
    // MARK: - UISwitch Action
    @objc func switchChanged(_ sender: UISwitch) {
        let day = Weekday.allCases[sender.tag]
        
        // Если переключатель включен, добавляем день в список выбранных
        if sender.isOn {
            selectedDays.insert(day)
        } else {
            selectedDays.remove(day)
        }
        Logger.log("Изменение дня: \(day.rawValue) - \(sender.isOn ? "добавлен" : "удален")", level: .debug)
    }
    
    @objc func doneButtonTapped() {
        onScheduleSelected?(selectedDays) // Передаем выбранные дни обратно
        dismiss(animated: true, completion: nil)
        Logger.log("Выбранные дни: \(selectedDays.map { $0.rawValue }.joined(separator: ", "))")
    }
}


// MARK: - UITableViewDelegate
extension ScheduleViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 { // Предположим, что строка с "Расписание" — вторая в списке (индекс 1)
            let scheduleVC = ScheduleViewController()
            scheduleVC.selectedDays = self.selectedDays // Передаем текущие выбранные дни в контроллер расписания
            scheduleVC.onScheduleSelected = { [weak self] selectedDays in
                self?.selectedDays = selectedDays
            }
            navigationController?.pushViewController(scheduleVC, animated: true)
        }
        Logger.log("Выбрана строка с индексом \(indexPath.row)")
    }
}


// MARK: - UITableViewDataSource
extension ScheduleViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Weekday.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell", for: indexPath)
        
        // Получаем текущий день недели
        let day = Weekday.allCases[indexPath.row]
        cell.textLabel?.text = day.rawValue
        
        cell.backgroundColor = .lbBackground
        
        // Создаем UISwitch
        let switchView = UISwitch(frame: .zero)
        switchView.isOn = selectedDays.contains(day)
        switchView.onTintColor = .lbBlue
        switchView.tag = indexPath.row // Используем тег для отслеживания изменения
        switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = switchView
        
        Logger.log("Создана ячейка для дня: \(Weekday.allCases[indexPath.row].rawValue)", level: .debug)
        
        return cell
    }
}
