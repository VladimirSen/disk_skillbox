import UIKit

final class FilesShareViewController: UIViewController {
    private lazy var label: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: (view.frame.size.width - 350) / 2,
                             y: view.frame.size.height - 261.4,
                             width: 350,
                             height: 50)
        if traitCollection.userInterfaceStyle == .dark {
            label.backgroundColor = .systemGray6
            label.textColor = .white
        } else {
            label.backgroundColor = .white
            label.textColor = .black
        }
        label.text = "Поделиться".localized()
        label.font = .systemFont(ofSize: 14, weight: .thin)
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        label.layer.masksToBounds = true
        return label
    }()
    private lazy var fileShareButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: (view.frame.size.width - 350) / 2,
                              y: view.frame.size.height - 210.5,
                              width: 350,
                              height: 50)
        if traitCollection.userInterfaceStyle == .dark {
            button.backgroundColor = .systemGray6
            button.setTitleColor(.white, for: .normal)
        } else {
            button.backgroundColor = .white
            button.setTitleColor(.black, for: .normal)
        }
        button.setTitle("Файлом".localized(), for: .normal)
        button.addTarget(self, action: #selector(tapFileShareButton), for: .touchUpInside)
        return button
    }()
    private lazy var linkShareButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: (view.frame.size.width - 350) / 2,
                              y: view.frame.size.height - 160,
                              width: 350,
                              height: 50)
        if traitCollection.userInterfaceStyle == .dark {
            button.backgroundColor = .systemGray6
            button.setTitleColor(.white, for: .normal)
        } else {
            button.backgroundColor = .white
            button.setTitleColor(.black, for: .normal)
        }
        button.setTitle("Ссылкой".localized(), for: .normal)
        button.layer.cornerRadius = 10
        button.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(tapLinkShareButton), for: .touchUpInside)
        return button
    }()
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: (view.frame.size.width - 350) / 2,
                              y: view.frame.size.height - 100,
                              width: 350,
                              height: 50)
        if traitCollection.userInterfaceStyle == .dark {
            button.backgroundColor = .systemGray6
        } else {
            button.backgroundColor = .white
        }
        button.setTitle("Отмена".localized(), for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(tapCancelButton), for: .touchUpInside)
        return button
    }()
    private lazy var file: Any = ""
    private lazy var publicUrl: String = ""
    private lazy var path: String = ""
    private var viewModel = FilesShareViewModel()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.addSubview(label)
        view.addSubview(fileShareButton)
        view.addSubview(linkShareButton)
        view.addSubview(cancelButton)
        viewModel.delegate = self
        UIView.animate(withDuration: 1) { [weak self] in
            self?.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        }
    }
    
    func initValue(path: String, file: Any) {
        self.path = path
        self.file = file
    }
    
    func setupData(publicUrl: String) {
        self.publicUrl = publicUrl
    }
    
    @objc func tapFileShareButton() {
        self.view.isHidden = true
        let shareFileVC = UIActivityViewController(activityItems: [file], applicationActivities: nil)
        shareFileVC.completionWithItemsHandler = { (_, _, _, _) in
            self.dismiss(animated: true)
        }
        self.present(shareFileVC, animated: true)
    }
    
    @objc func tapLinkShareButton() {
        self.view.isHidden = true
        viewModel.uploadData(path)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let shareLinkVC = UIActivityViewController(activityItems: [self.publicUrl], applicationActivities: nil)
            shareLinkVC.completionWithItemsHandler = { (_, _, _, _) in self.dismiss(animated: true)
            }
            self.present(shareLinkVC, animated: true)
        }
    }
    
    @objc func tapCancelButton() {
        self.dismiss(animated: true)
        self.view.backgroundColor = .clear
    }
}
