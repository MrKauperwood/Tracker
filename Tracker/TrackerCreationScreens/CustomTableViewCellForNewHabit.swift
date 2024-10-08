//
//  CustomTableViewCellForNewHabit.swift
//  Tracker
//
//  Created by Aleksei Bondarenko on 26.9.2024.
//

import UIKit

final class CustomTableViewCellForNewHabit: UITableViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular) // Настройка шрифта для заголовка
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular) // Настройка шрифта для описания
        label.textColor = .lbGrey
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Публичные методы для настройки текста
    func configureTitle(_ text: String) {
        titleLabel.text = text
        Logger.log("Заголовок ячейки установлен: \(text)", level: .debug)
    }
    
    func configureDescription(_ text: String) {
        descriptionLabel.text = text
        Logger.log("Описание ячейки установлено: \(text)", level: .debug)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Добавляем лейблы в contentView
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        
        // Настройка ограничений для лейблов
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
