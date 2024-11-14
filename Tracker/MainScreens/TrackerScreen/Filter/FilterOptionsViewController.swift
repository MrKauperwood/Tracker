import UIKit

// MARK: - Constants
private enum Constants {
    static let titleText = "Фильтры"
    static let titleFontSize: CGFloat = 16
    static let estimatedRowHeight: CGFloat = 75
    static let tableCornerRadius: CGFloat = 16
    static let tableMaskedCorners: CACornerMask = [
        .layerMinXMinYCorner,
        .layerMaxXMinYCorner,
        .layerMinXMaxYCorner,
        .layerMaxXMaxYCorner
    ]
    static let cellIdentifier = "filterCell"
    
    static let titleTopAnchor: CGFloat = 30
    static let tableTopAnchor: CGFloat = 38
    static let tableLeadingAnchor: CGFloat = 16
    static let tableTrailingAnchor: CGFloat = -16
    static let tableBottomAnchor: CGFloat = -16
}

final class FilterOptionsViewController: UIViewController, ViewConfigurable {
    
    var selectedFilter: TrackerFilter = .allTrackers
    var filterSelected: ((TrackerFilter) -> Void)?
    
    private let filters: [TrackerFilter] = [.allTrackers, .today, .completed, .uncompleted]
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.text = Constants.titleText
        titleLabel.font = UIFont.systemFont(ofSize: Constants.titleFontSize, weight: .medium)
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        addSubviews()
        addConstraints()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Constants.estimatedRowHeight
        
        // Настройка скругления углов таблицы
        tableView.layer.cornerRadius = Constants.tableCornerRadius
        tableView.layer.maskedCorners = Constants.tableMaskedCorners
        tableView.clipsToBounds = true
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellIdentifier)
        Logger.log("Таблица для типов фильтров настроена", level: .debug)
    }
    
    // Реализация методов протокола ViewConfigurable
    func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.titleTopAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.tableTopAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.tableLeadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Constants.tableTrailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: Constants.tableBottomAnchor),
            
        ])
    }
}

extension FilterOptionsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath)
        let filter = filters[indexPath.row]
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.text = filter.description
        cell.accessoryType = filter == selectedFilter ? .checkmark : .none
        cell.selectionStyle = .none
        cell.backgroundColor = .lbBackground
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.estimatedRowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFilter = filters[indexPath.row]
        filterSelected?(selectedFilter)
        dismiss(animated: true, completion: nil)
    }
}