import UIKit

final class CategoryCreationViewController: UIViewController, ViewConfigurable, UITextFieldDelegate {
    
    // MARK: - Public Method

    func setTitleAndCategory(_ title: String, andCategoryName categoryName: String) {
        titleLabel.text = title
        textField.text = categoryName
    }
    
    var getCategoryName: String {
        return textField.text ?? ""
    }
    
    // MARK: - UI Elements
    
    private lazy var titleLabel: UILabel = CategoryCreationViewController.makeTitleLabel()
    private lazy var textField: UITextField = CategoryCreationViewController.makeTextField()
    private lazy var errorLabel: UILabel = CategoryCreationViewController.makeErrorLabel()
    private lazy var clearButtonContainer = UIView(frame: CGRect(x: 0, y: 0, width: 29, height: 17))
    private lazy var clearButton: UIButton = CategoryCreationViewController.makeClearButton()
    private lazy var doneButton: UIButton = CategoryCreationViewController.makeDoneButton()
    
    // MARK: - Properties
    
    private let viewModel: CategoryCreationViewModel
    var onCategoryCreated: ((String) -> Void)?
    var onViewDidAppear: (() -> Void)?
    
    // MARK: - Initializer
    
    init(viewModel: CategoryCreationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        onViewDidAppear?()
        setupView()
        setupBindings()
        
        textField.delegate = self
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        view.backgroundColor = .lbWhite
        setupUI()
        addTapGesture()
    }
    
    private func setupUI() {
        addSubviews()
        addConstraints()
    }
    
    // MARK: - ViewConfigurable Protocol Methods
    
    func addSubviews() {
        [titleLabel, textField, errorLabel, doneButton].forEach { view.addSubview($0) }
        configureClearButton()
        Logger.log("Элементы интерфейса добавлены на экран", level: .debug)
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            errorLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        Logger.log("Констрейнты для элементов интерфейса установлены", level: .debug)
    }
    
    func focusTextField() {
        textField.becomeFirstResponder()
        if let text = textField.text {
            let endPosition = textField.endOfDocument
            textField.selectedTextRange = textField.textRange(from: endPosition, to: endPosition)
        }
    }
    
    private func configureClearButton() {
        clearButtonContainer.addSubview(clearButton)
        textField.rightView = clearButtonContainer
        textField.rightViewMode = .whileEditing
    }
    
    private func setupBindings() {
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        
        // Bindings с ViewModel для обновления состояния кнопки и показа ошибок
        viewModel.isDoneButtonEnabled = { [weak self] isEnabled in
            self?.doneButton.isEnabled = isEnabled
            self?.doneButton.backgroundColor = isEnabled ? UIColor(named: "LB_blackAndWhite") : UIColor(named: "LB_grey")
        }
        
        viewModel.errorMessage = { [weak self] message in
            self?.errorLabel.text = message
            self?.errorLabel.isHidden = (message == nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Закрываем клавиатуру
        textField.resignFirstResponder()
        
        return true
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Validation and Actions
    
    @objc private func textFieldDidChange() {
        clearButton.isHidden = textField.text?.isEmpty ?? true
        viewModel.updateCategoryName(textField.text ?? "")
    }
    
    @objc private func handleTapOutside() {
        textField.resignFirstResponder()
    }
    
    @objc private func doneButtonTapped() {
        guard let categoryName = textField.text, !categoryName.isEmpty else { return }
        onCategoryCreated?(categoryName)
        dismiss(animated: true, completion: nil)
    }
    @objc private func clearTextField() {
        textField.text = ""
        clearButton.isHidden = true
        errorLabel.isHidden = true
        viewModel.updateCategoryName("")
    }
    
    // MARK: - Factory Methods
    
    private static func makeTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Новая категория"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textAlignment = .center
        return titleLabel
    }
    
    private static func makeTextField() -> UITextField {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
        textField.returnKeyType = .go
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.backgroundColor = .lbBackground
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        return textField
    }
    
    private static func makeErrorLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lbRed
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textAlignment = .center
        label.isHidden = true
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }
    
    private static func makeClearButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .gray
        button.frame = CGRect(x: 0, y: 0, width: 17, height: 17)
        button.addTarget(nil, action: #selector(clearTextField), for: .touchUpInside)
        button.isHidden = true // Изначально скрыта
        return button
    }
    
    private static func makeDoneButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(named: "LB_grey")
        button.layer.cornerRadius = 16
        button.setTitleColor(UIColor(named: "LB_white"), for: .normal)
        return button
    }
}
