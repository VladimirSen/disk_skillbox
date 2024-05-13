import UIKit

final class PublishedFilesCell: FilesCell {
    lazy var removeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        if traitCollection.userInterfaceStyle == .dark {
            button.tintColor = .white
        } else {
            button.tintColor = .black
        }
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "PublishedFilesCell")
        contentView.addSubview(removeButton)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError(Constants.Text.fatalError)
    }
    
    private func setupConstraints() {
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        removeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        removeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
    }
}
