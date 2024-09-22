//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by Aleksei Bondarenko on 22.9.2024.
//

import UIKit

class NewHabitViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UI Elements
    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Новая привычка"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        // Внутренние отступы (padding)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0)) // отступ слева
        textField.leftViewMode = .always
        
        textField.backgroundColor = .lbLightGrey
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        
        return textField
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        
        tableView.backgroundColor = .lbLightGrey
        
        // Радиус скругления
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.separatorStyle = .none
        
        return tableView
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        
        button.setTitleColor(UIColor(named: "LB_red"), for: .normal) // Применяем цвет текста
        button.layer.borderColor = UIColor(named: "LB_red")?.cgColor // Цвет бордера из ассетов
        button.layer.borderWidth = 1 // Ширина бордера
        button.layer.cornerRadius = 16 // Радиус скругления
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    let createButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(UIColor(named: "LB_white"), for: .normal)
        button.layer.borderColor = UIColor(named: "LB_white")?.cgColor
        button.backgroundColor = UIColor(named: "LB_grey")
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually // Равномерное распределение кнопок
        stackView.spacing = 10 // Отступ между кнопками
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // Data arrays
    let tableData = ["Категория", "Расписание"]
    let emojis = ["😊", "😻", "🌸", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🏅", "🎸", "🏖", "😪"]
    let colors: [UIColor] = [
        .lbCS1Red, .lbCS2Orange, .lbCS3Blue, .lbCS4Purple, .lbCS5Green, .lbCS6Pink,
        .lbCS7LightPink, .lbCS8BrightBlue, .lbCS9MintGreen, .lbCS10DarkBlue,
        .lbCS11OrangeRed, .lbCS12BrightPink, .lbCS13Peach, .lbCS14LightBlue,
        .lbCS15Violet, .lbCS16PurplePink, .lbCS17Lilac, .lbCS18BrightGreen]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Регистрация Supplementary View
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.identifier)
        
        // Регистрация ячеек
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "emojiCell")
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "colorCell")
        
        view.backgroundColor = .white
        title = "Новая привычка"
        
        // Setup table view
        tableView.delegate = self
        tableView.dataSource = self
        
        // Register cell for table view
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // Setup collection views
        collectionView.delegate = self
        collectionView.dataSource = self
        
        setupUI()
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(textField)
        view.addSubview(tableView)
        view.addSubview(collectionView)
        
        // Добавляем кнопки в стек
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(createButton)
        
        view.addSubview(buttonStackView)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            
            // Title layout
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Tracker's name text field layout
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Tracker's settings Table view layout
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            // Emoji collection view layout
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.heightAnchor.constraint(equalToConstant: calculateCollectionHeight()),
            
            // Layout для buttonStackView
            buttonStackView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }
    
    // MARK: - Table view delegate and data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = tableData[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    // MARK: - Collection view delegate and data source
    
    // MARK: - Collection view number of sections
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2 // Секция 0 для эмодзи, секция 1 для цветов
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return emojis.count
        } else {
            return colors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderView.identifier, for: indexPath) as! SectionHeaderView
        
        if indexPath.section == 0 {
            header.titleLabel.text = "Emoji"
        } else {
            header.titleLabel.text = "Цвет"
        }
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath)
            let emojiLabel = UILabel()
            emojiLabel.text = emojis[indexPath.item]
            emojiLabel.font = UIFont.systemFont(ofSize: 32)
            emojiLabel.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(emojiLabel)
            NSLayoutConstraint.activate([
                emojiLabel.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                emojiLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath)
            cell.backgroundColor = colors[indexPath.item]
            cell.layer.cornerRadius = 8
            return cell
        }
    }
    
    // Layout for collection view items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 1 {
            // Размер ячеек для секции с палитрой цветов
            return CGSize(width: 52, height: 52)
        } else {
            // Размер ячеек для секции с эмодзи
            return CGSize(width: 52, height: 52)
        }
    }
    
    func calculateCollectionHeight() -> CGFloat {
        let numberOfItemsPerRow: CGFloat = 6
        let itemHeight: CGFloat = 52
        let spacing: CGFloat = 16
        
        // Рассчитываем высоту для секции с эмодзи
        let numberOfRowsEmoji = ceil(CGFloat(emojis.count) / numberOfItemsPerRow)
        let emojiHeight = (numberOfRowsEmoji * itemHeight) + ((numberOfRowsEmoji - 1) * spacing)
        
        // Рассчитываем высоту для секции с цветами
        let numberOfRowsColors = ceil(CGFloat(colors.count) / numberOfItemsPerRow)
        let colorsHeight = (numberOfRowsColors * itemHeight) + ((numberOfRowsColors - 1) * spacing)
        
        // Динамически получаем высоту заголовка
        let headerHeight = self.collectionView(
            collectionView,
            layout: collectionView.collectionViewLayout as! UICollectionViewFlowLayout,
            referenceSizeForHeaderInSection: 0
        ).height
        
        return emojiHeight + colorsHeight + (headerHeight * 2) // Учитываем два заголовка
    }
}
