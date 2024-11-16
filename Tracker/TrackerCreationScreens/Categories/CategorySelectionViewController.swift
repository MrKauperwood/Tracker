import UIKit

final class CategorySelectionViewController: UIViewController, ViewConfigurable {
    
    // MARK: - UI Elements
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.text = "Категория"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        button.setTitleColor(.lbWhite, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        
        button.backgroundColor = .lbBlackAndWhite
        button.layer.cornerRadius = 16
        
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var emptyStateLogo: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "EmptyStateLogo"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var emptyStateTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        // Настраиваем межстрочный интервал и выравнивание по центру
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .center
        
        let attributedString = NSAttributedString(
            string: "Привычки и события можно объединить по смыслу",
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .medium),
                .foregroundColor: UIColor.lbBlackAndWhite,
                .paragraphStyle: paragraphStyle
            ]
        )
        
        label.attributedText = attributedString
        
        return label
    }()
    
    // MARK: - Properties
    
    private let viewModel: CategorySelectionViewModel
    
    // Замыкание для передачи выбранной категории обратно
    var onCategorySelected: ((TrackerCategory) -> Void)?
    
    var tableHeightConstraint: NSLayoutConstraint? // Переменная для хранения констрейнта высоты таблицы
    
    // MARK: - Initializer
    init(viewModel: CategorySelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        Logger.log("CategorySelectionViewController загружен", level: .debug)
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        view.backgroundColor = .lbWhite
        
        setupTableView()
        addSubviews()
        addConstraints()
        toggleEmptyStateVisibility()
    }
    
    func addSubviews() {
        view.addSubview(emptyStateLogo)
        view.addSubview(emptyStateTextLabel)
        view.addSubview(tableView)
        view.addSubview(addButton)
        view.addSubview(titleLabel)
        Logger.log("Элементы интерфейса добавлены на экран", level: .debug)
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -16),
            
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            addButton.heightAnchor.constraint(equalToConstant: 60),
            
            emptyStateLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateTextLabel.topAnchor.constraint(equalTo: emptyStateLogo.bottomAnchor, constant: 8),
            emptyStateTextLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            emptyStateTextLabel.centerXAnchor.constraint(equalTo: emptyStateLogo.centerXAnchor)
        ])
        Logger.log("Констрейнты для элементов интерфейса установлены", level: .debug)
    }
    
    func updateTableViewHeight() {
        tableView.layoutIfNeeded() // Обновляем макет таблицы
        let tableHeight = tableView.contentSize.height // Получаем высоту контента таблицы
        
        // Обновляем значение существующего констрейнта высоты таблицы
        tableHeightConstraint?.constant = tableHeight
        Logger.log("Высота таблицы обновлена: \(tableView.contentSize.height)", level: .debug)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 75
        
        // Настройка скругления углов таблицы
        tableView.layer.cornerRadius = 16
        tableView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner,
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner
        ]
        tableView.clipsToBounds = true
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        Logger.log("Таблица для категорий настроена", level: .debug)
    }
    
    private func toggleEmptyStateVisibility() {
        let categories = viewModel.categories.isEmpty
        emptyStateLogo.isHidden = !categories
        emptyStateTextLabel.isHidden = !categories
        tableView.isHidden = categories
        
    }
    
    private func setupBindings() {
        viewModel.categoriesDidChange = { [weak self] categories in
            
            self?.toggleEmptyStateVisibility()
            self?.tableView.reloadData()
        }
        
        viewModel.selectedCategoryDidChange = { [weak self] category in
            // Передаем выбранную категорию обратно через замыкание
            self?.onCategorySelected?(category!)
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func addButtonTapped() {
        let categoryCreationViewModel = CategoryCreationViewModel()
        let categoryCreationVC = CategoryCreationViewController(viewModel: categoryCreationViewModel)
        
        // Замыкание, которое вызывается после создания категории
        categoryCreationVC.onCategoryCreated = { [weak self] categoryName in
            self?.viewModel.addCategory(with: categoryName)
        }
        
        present(categoryCreationVC, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension CategorySelectionViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = viewModel.categories[indexPath.row]
        cell.textLabel?.text = category.title
        
        // Отключаем выделение ячейки при выборе
        cell.selectionStyle = .none
        
        cell.backgroundColor = .lbBackground
        
        // Отметка галочкой выбранной категории
        if category == viewModel.selectedCategory {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath.row)
        
        // Обновляем таблицу, чтобы убрать предыдущую галочку и поставить новую
        tableView.reloadData()
        
        // Передача выбранной категории обратно через замыкание
        if let selectedCategory = viewModel.selectedCategory {
            onCategorySelected?(selectedCategory)
        }
        
        // Возвращаемся на экран создания привычки
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let category = viewModel.categories[indexPath.row]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            return self.makeContextMenu(for: category)
        }
    }
    
    private func makeContextMenu(for category: TrackerCategory) -> UIMenu {
        
        let editAction = UIAction(
            title: "Редактировать"
        ) { _ in
            self.editCategory(category)
        }
        
        let deleteAction = UIAction(
            title: "Удалить",
            attributes: .destructive
        ) { _ in
            self.removeCategory(category)
        }
        
        return UIMenu(title: "", children: [editAction, deleteAction])
    }
    
    private func editCategory(_ category: TrackerCategory) {
        let editViewModel = CategoryCreationViewModel()
        let editVC = CategoryCreationViewController(viewModel: editViewModel)
        
        editVC.setTitleAndCategory("Редактирование категории", andCategoryName: category.title)
        
        editVC.onViewDidAppear = { [weak editVC] in
            editVC?.focusTextField()
        }
        
        // Замыкание, которое вызывается после создания категории
        editVC.onCategoryCreated = { [weak self] categoryName in
            self?.viewModel.editCategory(category, newTitle: editVC.getCategoryName)
        }
        
        present(editVC, animated: true, completion: nil)
    }
    
    private func removeCategory(_ category: TrackerCategory) {
        let alertController = UIAlertController(title: "", message: "Эта категория точно не нужна?", preferredStyle: .actionSheet)
        
        let editViewModel = CategoryCreationViewModel()
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { _ in
            do {
                self.viewModel.removeCategory(category)
                self.viewModel.fetchCategories()
                self.tableView.reloadData()
                self.toggleEmptyStateVisibility()
            } catch {
                Logger.log("Ошибка при удалении трекера: \(error)", level: .error)
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
