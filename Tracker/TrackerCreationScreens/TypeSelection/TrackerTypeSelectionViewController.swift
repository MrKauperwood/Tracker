import Foundation
import UIKit

final class TrackerTypeSelectionViewController: UIViewController, ViewConfigurable {
    
    var trackerStore: TrackerStore!
    var trackerCategoryStore: TrackerCategoryStore!
    var trackerRecordStore: TrackerRecordStore!
    
    // MARK: - UI Elements
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("tracker_type_selection.title", comment: "")
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var habitButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("tracker_type_selection.habit_button", comment: ""), for: .normal)
        button.backgroundColor = .lbBlackAndWhite
        button.setTitleColor(.lbWhite, for: .normal)
        button.titleLabel?.font = UIFont(name: "SFProText-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var irregularButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("tracker_type_selection.irregular_button", comment: ""), for: .normal)
        button.backgroundColor = .lbBlackAndWhite
        button.setTitleColor(.lbWhite, for: .normal)
        button.titleLabel?.font = UIFont(name: "SFProText-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(irregularButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Logger.log("Экран выбора типа трекера загружен")
        
        view.backgroundColor = .lbWhite
        setupUI()
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        addSubviews()
        addConstraints()
    }
    
    // MARK: - ViewConfigurable Protocol Methods
    
    func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(habitButton)
        view.addSubview(irregularButton)
        Logger.log("Элементы интерфейса добавлены на экран", level: .debug)
    }
    
    func addConstraints() {
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
        Logger.log("Констрейнты для элементов интерфейса установлены", level: .debug)
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
