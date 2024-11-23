import UIKit

final class FilterCell: UITableViewCell, ViewConfigurable {
    static let identifier = "FilterCell"

    private let customTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .regular)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        backgroundColor = .lbBackground
        addSubviews()
        addConstraints()
    }

    // MARK: - ViewConfigurable
    func addSubviews() {
        contentView.addSubview(customTextLabel)
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            customTextLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            customTextLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    // MARK: - Configuration
    func configure(with filter: TrackerFilter, isSelected: Bool) {
        customTextLabel.text = filter.description
        accessoryType = isSelected ? .checkmark : .none
    }
}
