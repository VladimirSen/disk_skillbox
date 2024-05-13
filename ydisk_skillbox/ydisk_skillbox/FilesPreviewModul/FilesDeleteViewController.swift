import UIKit

final class FilesDeleteViewController: UIViewController {
    let viewModel = FilesPreviewViewModel()
    private lazy var label: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: (view.frame.size.width - 350) / 2,
                             y: view.frame.size.height - 210.5,
                             width: 350,
                             height: 50)
        if traitCollection.userInterfaceStyle == .dark {
            label.backgroundColor = .systemGray6
            label.textColor = .white
        } else {
            label.backgroundColor = .white
            label.textColor = .black
        }
        label.text = "Данный файл будет удален".localized()
        label.font = .systemFont(ofSize: 14, weight: .thin)
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        label.layer.masksToBounds = true
        return label
    }()
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: (view.frame.size.width - 350) / 2,
                              y: view.frame.size.height - 160,
                              width: 350,
                              height: 50)
        if traitCollection.userInterfaceStyle == .dark {
            button.backgroundColor = .systemGray6
        } else {
            button.backgroundColor = .white
        }
        button.setTitle("Удалить файл".localized(), for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(tapExitButton), for: .touchUpInside)
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
    private lazy var pathToFile: String = ""
    private weak var controller: FilesPreviewViewControllerProtocol?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.addSubview(label)
        view.addSubview(deleteButton)
        view.addSubview(cancelButton)
        UIView.animate(withDuration: 1) { [weak self] in
            self?.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        }
    }
    
    func initValue(path: String, controller: FilesPreviewViewControllerProtocol) {
        self.pathToFile = path
        self.controller = controller
    }
    
    @objc func tapExitButton() {
        viewModel.deleteFile(pathToFile)
        dismiss(animated: true) { [weak self] in
            self?.controller?.reloadData()
            self?.controller?.deleteFileInCache()
        }
    }
    
    @objc func tapCancelButton() {
        self.dismiss(animated: true)
        self.view.backgroundColor = .clear
    }
}
