import UIKit

final class OnboardingContentViewController: UIViewController {
    
    private let titleLabel = UILabel()
    private var backgroundImageView = UIImageView()
    private var button = UIButton()
    
    var buttonAction: (() -> Void)?  // Closure для передачи действия
    
    init(titleText: String, backgroundImageName: String, buttonTitle: String = "Вот это технологии!") {
        super.init(nibName: nil, bundle: nil)
        
        configureTitleLabel(with: titleText)
        configureBackgroundImage(with: backgroundImageName)
        configureButton(with: buttonTitle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // Основная функция для инициализации интерфейса
    private func setupUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(titleLabel)
        view.addSubview(button)
        
        setupConstraintsForTheAllElements()
    }

    // Метод для конфигурации UILabel (заголовок)
    private func configureTitleLabel(with text: String) {
        titleLabel.text = text
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
    }

    // Метод для конфигурации UIImageView (фоновое изображение)
    private func configureBackgroundImage(with imageName: String) {
        backgroundImageView = UIImageView(image: UIImage(named: imageName))
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
    }

    // Метод для конфигурации UIButton
    private func configureButton(with title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = .lbBlack
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    // Функция для установки констрейнтов
    private func setupConstraintsForTheAllElements() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -160),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -84),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        view.sendSubviewToBack(backgroundImageView)
    }

    @objc private func buttonTapped() {
        buttonAction?()
    }
}
