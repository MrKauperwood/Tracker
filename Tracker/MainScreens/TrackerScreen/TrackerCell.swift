import UIKit

final class TrackerCell: UICollectionViewCell {
    
    var increaseDayCounterButtonTapped: ((Int) -> Void)?
    private var isTrackerCompleted: Bool = false
    
    let topContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lbCS5Green
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let pinIconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "PinIcon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = .lbWhiteAndWhite
        label.numberOfLines = 0
        return label
    }()
    
    private let backgroundColorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.backgroundColor = .lbWhite
        return view
    }()
    
    private let bottomContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let daysLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .lbBlackAndWhite
        return label
    }()
    
    private let increaseDayButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+", for: .normal)
        button.setTitleColor(.lbWhite, for: .normal) //
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        button.layer.cornerRadius = 17
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let bottomStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Logger.log("Инициализирована ячейка TrackerCell с размером \(frame)", level: .debug)
        
        topContainerView.addSubview(emojiLabel)
        topContainerView.addSubview(nameLabel)
        topContainerView.addSubview(pinIconView)
        
        bottomStackView.addArrangedSubview(daysLabel)
        bottomStackView.addArrangedSubview(increaseDayButton)
        bottomContainerView.addSubview(bottomStackView)
        
        // Добавляем контейнеры в contentView
        contentView.addSubview(topContainerView)
        contentView.addSubview(bottomContainerView)
        
        contentView.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            // Первый контейнер
            topContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            topContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topContainerView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: topContainerView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: 12),
            
            pinIconView.topAnchor.constraint(equalTo: topContainerView.topAnchor, constant: 12),
            pinIconView.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor, constant: -12),
            
            nameLabel.bottomAnchor.constraint(equalTo: topContainerView.bottomAnchor, constant: -12),
            nameLabel.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor, constant: -12),
            
            // Второй контейнер
            bottomContainerView.topAnchor.constraint(equalTo: topContainerView.bottomAnchor, constant: 10),
            bottomContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            // BottomStackView внутри второго контейнера
            bottomStackView.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: 12),
            bottomStackView.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -12),
            bottomStackView.centerYAnchor.constraint(equalTo: bottomContainerView.centerYAnchor),
            
            // Ограничения для кнопки (чтобы она была круглой)
            increaseDayButton.widthAnchor.constraint(equalToConstant: 34),
            increaseDayButton.heightAnchor.constraint(equalToConstant: 34)
        ])
        
        increaseDayButton.addTarget(self, action: #selector(increaseDayCounter), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with tracker: Tracker, daysCompletedText: String, isCompleted: Bool) {
        emojiLabel.text = tracker.emoji
        nameLabel.text = tracker.name
        topContainerView.backgroundColor = tracker.color
        
        isTrackerCompleted = isCompleted
        
        updateButtonAppearance()
        
        pinIconView.isHidden = !tracker.isPinned
        
        daysLabel.text = daysCompletedText
        Logger.log("Конфигурация ячейки для трекера: \(tracker.name), количество дней: \(daysCompletedText), выполнен: \(isCompleted)", level: .info)
    }
    
    @objc private func increaseDayCounter() {
        increaseDayCounterButtonTapped?(isTrackerCompleted ? -1 : 1)
        Logger.log("Кнопка увеличения дня нажата, текущее состояние: \(isTrackerCompleted ? "выполнено" : "не выполнено")", level: .debug)
    }
    
    private func updateButtonAppearance() {
        if isTrackerCompleted {
            let doneImage = UIImage(named: "DoneButton")
            increaseDayButton.setImage(doneImage, for: .normal)
            increaseDayButton.tintColor = .lbWhite
            increaseDayButton.setTitle(nil, for: .normal)
            increaseDayButton.imageView?.contentMode = .scaleAspectFit
            
            if let imageView = increaseDayButton.imageView {
                increaseDayButton.bringSubviewToFront(imageView)
            }
            
            increaseDayButton.backgroundColor = topContainerView.backgroundColor?.withAlphaComponent(0.3)
        } else {
            increaseDayButton.setImage(nil, for: .normal)
            increaseDayButton.setTitle("+", for: .normal)
            increaseDayButton.backgroundColor = topContainerView.backgroundColor
        }
        Logger.log("Обновление внешнего вида кнопки: \(isTrackerCompleted ? "завершён" : "не завершён")", level: .debug)
    }
}
