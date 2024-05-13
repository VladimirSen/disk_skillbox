import UIKit

final class FilesPreviewItems {
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemBlue
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemBlue
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.compact.left"), for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.tintColor = .systemBlue
        return button
    }()
    lazy var editButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "applepencil"), for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.tintColor = .systemBlue
        return button
    }()
    lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.tintColor = .systemBlue
        return button
    }()
    lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.tintColor = .systemBlue
        return button
    }()
}
