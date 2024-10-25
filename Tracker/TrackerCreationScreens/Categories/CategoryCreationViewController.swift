//
//  CategoryCreationViewController.swift
//  Tracker
//
//  Created by Aleksei Bondarenko on 25.10.2024.
//

import UIKit

final class CategoryCreationViewController: UIViewController {
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = CategoryCreationViewController.makeTitleLabel()
    private let textField: UITextField = CategoryCreationViewController.makeTextField()
    private let errorLabel: UILabel = CategoryCreationViewController.makeErrorLabel()
    private let clearButtonContainer = UIView(frame: CGRect(x: 0, y: 0, width: 29, height: 17))
    private let clearButton: UIButton = CategoryCreationViewController.makeClearButton()
    private let doneButton: UIButton = CategoryCreationViewController.makeDoneButton()
    
    // MARK: - Properties
    private let viewModel: CategoryCreationViewModel
    var onCategoryCreated: ((String) -> Void)?
    
    // MARK: - Initializer
    init(viewModel: CategoryCreationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        view.backgroundColor = .white
        setupUI()
        addTapGesture()
    }
    
    private func setupUI() {
        configureClearButtonForTheTextField()
        [titleLabel, textField, errorLabel, doneButton].forEach { view.addSubview($0) }
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
    }
    
    private func configureClearButtonForTheTextField() {
        clearButtonContainer.addSubview(clearButton)
        textField.rightView = clearButtonContainer
        textField.rightViewMode = .whileEditing
    }
    
    private func setupBindings() {
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Validation and Actions
    
    private func validateForm() {
        let trimmedText = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        doneButton.isEnabled = !trimmedText.isEmpty && trimmedText.count <= 38
        doneButton.backgroundColor = doneButton.isEnabled ? UIColor(named: "LB_black") : UIColor(named: "LB_grey")
    }
    
    @objc private func textFieldDidChange() {
        clearButton.isHidden = textField.text?.isEmpty ?? true
        validateForm()
        updateErrorLabel()
    }
    
    private func updateErrorLabel() {
        let trimmedText = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if trimmedText.count > 38 {
            errorLabel.text = "Ограничение 38 символов"
            errorLabel.isHidden = false
        } else if trimmedText.isEmpty {
            errorLabel.text = "Название категории не может быть пустым или состоять только из пробелов"
            errorLabel.isHidden = false
        } else {
            errorLabel.isHidden = true
            viewModel.updateCategoryName(trimmedText)
        }
    }
    
    @objc private func handleTapOutside() {
        textField.resignFirstResponder()
        validateForm()
    }
    
    @objc private func doneButtonTapped() {
        guard let categoryName = textField.text, !categoryName.isEmpty else { return }
        onCategoryCreated?(categoryName)
        dismiss(animated: true, completion: nil)
    }
    @objc private func clearTextField() {
        textField.text = ""
        clearButton.isHidden = true
        validateForm()
        errorLabel.isHidden = true
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
