import UIKit

public class FilesCell: UITableViewCell {
    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(frame: CGRect(x: 15,
                                                         y: 15,
                                                         width: 30,
                                                         height: 30))
        view.color = .lightGray
        view.style = .medium
        return view
    }()
    lazy var preview: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0,
                                             y: 0,
                                             width: 60,
                                             height: 60))
        view.contentMode = .scaleAspectFit
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        return view
    }()
    lazy var nameLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 18)
        view.contentMode = .scaleAspectFit
        return view
    }()
    lazy var sizeLabel: UILabel = {
        let view = UILabel()
        view.contentMode = .scaleAspectFit
        view.font = .systemFont(ofSize: 14, weight: .light)
        return view
    }()
    lazy var dateLabel: UILabel = {
        let view = UILabel()
        view.contentMode = .scaleAspectFit
        view.font = .systemFont(ofSize: 14, weight: .light)
        return view
    }()
    private lazy var littleStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.spacing = 8
        view.contentMode = .scaleAspectFit
        view.addArrangedSubview(sizeLabel)
        view.addArrangedSubview(dateLabel)
        return view
    }()
    private lazy var bigStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .leading
        view.contentMode = .scaleAspectFit
        view.spacing = 5
        view.addArrangedSubview(nameLabel)
        view.addArrangedSubview(littleStackView)
        return view
    }()
    private let token = UserDefaults.standard.string(forKey: "token") ?? ""
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "FilesCell")
        contentView.addSubview(preview)
        contentView.addSubview(bigStackView)
        var backImage = UIImage()
        if traitCollection.userInterfaceStyle == .dark {
            backImage = UIImage(named: "backgroundDark") ?? UIImage()
        } else {
            backImage = UIImage(named: "background") ?? UIImage()
        }
        contentView.backgroundColor = UIColor(patternImage: backImage)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError(Constants.Text.fatalError)
    }
    
    func configure(model: ItemList) {
        let dateString = String.transformDate(date: model.created ?? "")
        let size = Double(model.size ?? 0) / 1024 / 1024
        nameLabel.text = model.name
        dateLabel.text = dateString
        sizeLabel.text = String(format: "%.2F", size) + " " + "МБ".localized()
        if model.type == "dir" {
            preview.image = UIImage(named: "folder")
            dateLabel.text = ""
            sizeLabel.text = ""
            activityIndicator.stopAnimating()
        } else if model.mediaType == "audio" {
            preview.image = UIImage(named: "note")
            activityIndicator.stopAnimating()
        } else {
            NetworkService.loadImage(url: model.preview ?? "",
                                   token: self.token,
                                   completion: { image in
                DispatchQueue.main.async {
                    self.preview.image = image
                }
            })
        }
        if model.preview != nil {
            activityIndicator.stopAnimating()
        }
    }
    
    private func setupConstraints() {
        preview.translatesAutoresizingMaskIntoConstraints = false
        preview.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        preview.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        bigStackView.translatesAutoresizingMaskIntoConstraints = false
        bigStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
        bigStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 85).isActive = true
        bigStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
    }
}
