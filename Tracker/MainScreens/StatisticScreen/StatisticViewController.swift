import Foundation
import UIKit

final class StatisticViewController: UIViewController, ViewConfigurable {
    
    private enum Constants {
        static let titleFontSize: CGFloat = 34
        static let titleTopPadding: CGFloat = 16
        static let labelFontSize: CGFloat = 12
        static let elementSpacing: CGFloat = 8
        static let tableTopPadding: CGFloat = 77
        static let cellHeight: CGFloat = 90
        static let footerHeight: CGFloat = 12
    }
    
    private var statistics = [
        (number: -1, description: "Лучший период"),
        (number: -1, description: "Идеальные дни"),
        (number: -1, description: "Трекеров завершено"),
        (number: -1, description: "Среднее значение")
    ]
    
    private var trackerStore: TrackerStore!
    private var trackerRecordStore: TrackerRecordStore!
    private var allExistingTrackers: [Tracker] = []
    private var allExistingRecords: [TrackerRecord] = []
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(StatisticCell.self, forCellReuseIdentifier: "StatisticCell")
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Статистика"
        titleLabel.font = UIFont.systemFont(ofSize: Constants.titleFontSize, weight: .bold)
        return titleLabel
    }()
    
    private let emptyStateLogo: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "EmptyStateLogoForStatistic"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyStateTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Анализировать пока нечего"
        label.font = UIFont.systemFont(ofSize: Constants.labelFontSize, weight: .regular)
        label.textColor = .lbBlackAndWhite
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTrackerStore()
        setupTrackerRecordStore()
        updateEmptyStateVisibility()
        if tableView.isHidden == false {
            calculateStatistics()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .lbWhite
        addSubviews()
        addConstraints()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .lbWhite
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0)
        
        if tableView.isHidden == false {
            calculateStatistics()
        }
    }
    
    func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(emptyStateLogo)
        view.addSubview(emptyStateTextLabel)
        view.addSubview(tableView)
    }
    
    func addConstraints(){
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.titleTopPadding),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.titleTopPadding),
            
            emptyStateLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateTextLabel.topAnchor.constraint(equalTo: emptyStateLogo.bottomAnchor, constant: Constants.elementSpacing),
            emptyStateTextLabel.centerXAnchor.constraint(equalTo: emptyStateLogo.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.tableTopPadding),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.titleTopPadding),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.titleTopPadding),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func updateEmptyStateVisibility() {
        let isEmptyState = allExistingTrackers.isEmpty && allExistingRecords.isEmpty
        
        let areAllNumbersNegative = statistics.allSatisfy { $0.number == 0 }
        
        let shouldShowEmptyState = isEmptyState || areAllNumbersNegative
        
        emptyStateLogo.isHidden = !isEmptyState
        emptyStateTextLabel.isHidden = !isEmptyState
        tableView.isHidden = isEmptyState
    }
    
    private func calculateStatistics() {
        
        let bestPeriod = calculateBestPeriod(records: allExistingRecords)
        statistics[0].number = bestPeriod
        
        let perfectDays = calculatePerfectDays(records: allExistingRecords, trackers: allExistingTrackers)
        statistics[1].number = perfectDays
        
        statistics[2].number = allExistingRecords.count
        
        let average = calculateAverage(records: allExistingRecords)
        statistics[3].number = average
        
        tableView.reloadData()
        
    }
    
    func calculateBestPeriod(records: [TrackerRecord]) -> Int {
        var bestPeriod = 0
        
        let groupedRecords = Dictionary(grouping: records) { $0.trackerId }
        
        for (_, trackerRecords) in groupedRecords {
            let sortedDates = trackerRecords.map { $0.date }.sorted()
            
            var currentStreak = 1
            var maxStreak = 1
            
            for i in 1..<sortedDates.count {
                let previousDate = sortedDates[i - 1]
                let currentDate = sortedDates[i]
                
                if Calendar.current.isDate(currentDate, inSameDayAs: previousDate.addingTimeInterval(24 * 60 * 60)) {
                    currentStreak += 1
                    maxStreak = max(maxStreak, currentStreak)
                } else {
                    currentStreak = 1
                }
            }
            bestPeriod = max(bestPeriod, maxStreak)
        }
        
        return bestPeriod
    }
    
    func calculatePerfectDays(records: [TrackerRecord], trackers: [Tracker]) -> Int {
        var perfectDays = 0
        
        let groupedRecords = Dictionary(grouping: records) { Calendar.current.startOfDay(for: $0.date) }
        
        for (date, recordsForDate) in groupedRecords {
            let completedTrackerIds = Set(recordsForDate.map { $0.trackerId })
            
            let scheduledTrackers = trackers.filter { tracker in
                tracker.schedule.contains(Weekday.from(date: date)!)
            }
            if completedTrackerIds.count == scheduledTrackers.count {
                perfectDays += 1
            }
        }
        
        return perfectDays
    }
    
    func calculateAverage(records: [TrackerRecord]) -> Int {
        let uniqueDays = Set(records.map { Calendar.current.startOfDay(for: $0.date) })
        let totalDays = uniqueDays.count
        
        guard totalDays > 0 else { return 0 }
        
        let average = Double(records.count) / Double(totalDays)
        return Int(average)
    }
}


// MARK: - UITableViewDataSource
extension StatisticViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statistics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StatisticCell", for: indexPath) as? StatisticCell else {
            return UITableViewCell()
        }
        
        let stat = statistics[indexPath.row]
        cell.configure(with: stat.number, description: stat.description)
        
        // Отключаем выделение ячейки
        cell.selectionStyle = .none
        return cell
    }
}


// MARK: - UITableViewDelegate
extension StatisticViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return Constants.footerHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let inset = UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0)
        cell.contentView.layoutMargins = inset
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let spacerView = UIView()
        spacerView.backgroundColor = .clear // Пустой прозрачный вид
        return spacerView
    }
}

extension StatisticViewController: TrackerStoreDelegate{
    func store(_ store: TrackerStore, didUpdate update: TrackerStoreUpdate) {
    }
}

extension StatisticViewController: TrackerRecordStoreDelegate {
    func store(_ store: TrackerRecordStore, didUpdate update: TrackerRecordStoreUpdate){}
}

extension StatisticViewController {
    
    // MARK: Work with CoreData
    
    func setupTrackerStore() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        trackerStore = TrackerStore(context: context)
        trackerStore.delegate = self
        
        do {
            allExistingTrackers = try trackerStore.getAllTrackers()
            Logger.log("Трекеры (в количестве \(allExistingTrackers.count)) были загружены из CoreData")
        } catch {
            Logger.log("Ошибка при загрузке трекеров: \(allExistingTrackers)", level: .error)
        }
    }
    
    private func setupTrackerRecordStore() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        trackerRecordStore = TrackerRecordStore(context: context)
        trackerRecordStore.delegate = self
        
        allExistingRecords = trackerRecordStore.records
        Logger.log("Все записи трекеров (в количестве \(allExistingRecords.count)) были загружены из CoreData")
    }
}
