import UIKit

final class StatisticCell: UITableViewCell, ViewConfigurable {
    
    private let gradientLayer = CAGradientLayer()
    
    // MARK: - Constants
    private enum Constants {
        static let numberLabelTopPadding: CGFloat = 12
        static let numberLabelLeadingPadding: CGFloat = 16
        static let descriptionLabelTopPadding: CGFloat = 4
        static let descriptionLabelTrailingPadding: CGFloat = -16
        static let descriptionLabelBottomPadding: CGFloat = -8
        
        static let numberLabelFontSize: CGFloat = 34
        static let descriptionLabelFontSize: CGFloat = 12
        
        static let borderRadius: CGFloat = 16
        static let borderWidth: CGFloat = 4
    }
    
    // MARK: - UI Elements
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: Constants.numberLabelFontSize, weight: .bold)
        label.textColor = .lbBlackAndWhite
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: Constants.descriptionLabelFontSize, weight: .regular)
        label.textColor = .lbBlackAndWhite
        return label
    }()
    
    private let borderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Constants.borderRadius
        view.layer.masksToBounds = true // Добавляем маскирование
        return view
    }()
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupGradientBorder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        contentView.backgroundColor = .lbWhite
        addSubviews()
        addConstraints()
    }
    
    func addSubviews() {
        contentView.addSubview(borderView)
        borderView.addSubview(numberLabel)
        borderView.addSubview(descriptionLabel)
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            borderView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            borderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            borderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            borderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            numberLabel.topAnchor.constraint(equalTo: borderView.topAnchor, constant: Constants.numberLabelTopPadding),
            numberLabel.leadingAnchor.constraint(equalTo: borderView.leadingAnchor, constant: Constants.numberLabelTopPadding),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: borderView.leadingAnchor, constant: Constants.numberLabelTopPadding),
            descriptionLabel.bottomAnchor.constraint(equalTo: borderView.bottomAnchor, constant: -Constants.numberLabelTopPadding)
        ])
    }
    
    private func setupGradientBorder() {
        gradientLayer.frame = borderView.bounds
        gradientLayer.colors = [
            UIColor.lbCS1Red.cgColor,
            UIColor.lbCS9MintGreen.cgColor,
            UIColor.lbCS3Blue.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = Constants.borderWidth
        shapeLayer.path = UIBezierPath(roundedRect: borderView.bounds, cornerRadius: Constants.borderRadius).cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        
        gradientLayer.mask = shapeLayer
        
        borderView.layer.addSublayer(gradientLayer)
    }
    
    // MARK: - Configuration
    func configure(with number: Int, description: String) {
        numberLabel.text = "\(number)"
        descriptionLabel.text = description
    }
}
