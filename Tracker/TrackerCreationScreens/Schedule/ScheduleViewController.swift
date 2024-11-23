import UIKit

final class ScheduleViewController: UIViewController, ViewConfigurable {
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.text = NSLocalizedString("schedule.title", comment: "")
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    private let tableView = UITableView()
    var selectedDays: Set<Weekday> = []
    
    var onScheduleSelected: ((Set<Weekday>) -> Void)?
    var tableHeightConstraint: NSLayoutConstraint?
    
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("schedule.done_button", comment: ""), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        button.setTitleColor(.lbWhite, for: .normal)
        button.backgroundColor = .lbBlackAndWhite
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        
        button.widthAnchor.constraint(equalToConstant: 335).isActive = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
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
        
        setupUI()
        Logger.log("Экран расписания загружен")
    }
    
    private func setupUI() {
        view.backgroundColor = .lbWhite
        addSubviews()
        addConstraints()
    }
    
    func updateTableViewHeight() {
        tableView.layoutIfNeeded() // Обновляем макет таблицы
        let tableHeight = tableView.contentSize.height // Получаем высоту контента таблицы
        
        // Обновляем значение существующего констрейнта высоты таблицы
        tableHeightConstraint?.constant = tableHeight
        Logger.log("Высота таблицы обновлена: \(tableView.contentSize.height)", level: .debug)
    }
    
    func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(doneButton)
        setupTableView()
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        tableHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableHeightConstraint?.isActive = true
        updateTableViewHeight()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 75
        
        tableView.layer.cornerRadius = 16
        tableView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner,
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner
        ]
        tableView.clipsToBounds = true
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "dayCell")
    }
    
    // MARK: - UISwitch Action
    
    @objc private func switchChanged(_ sender: UISwitch) {
        let day = Weekday.allCases[sender.tag]
        
        // Если переключатель включен, добавляем день в список выбранных
        if sender.isOn {
            selectedDays.insert(day)
        } else {
            selectedDays.remove(day)
        }
        Logger.log("Изменение дня: \(day.rawValue) - \(sender.isOn ? "добавлен" : "удален")", level: .debug)
    }
    
    @objc private func doneButtonTapped() {
        onScheduleSelected?(selectedDays)
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
        if indexPath.row == 1 { // строка с "Расписание" — вторая в списке (индекс 1)
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
        let localizedDayName = NSLocalizedString(day.rawValue, comment: "")
        cell.textLabel?.text = localizedDayName
        
        cell.backgroundColor = .lbBackground
        
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
