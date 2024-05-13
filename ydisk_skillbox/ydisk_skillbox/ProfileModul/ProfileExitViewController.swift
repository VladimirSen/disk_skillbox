import UIKit

final class ProfileExitViewController: UIViewController {
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
        label.text = "Профиль".localized()
        label.font = .systemFont(ofSize: 14, weight: .thin)
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        label.layer.masksToBounds = true
        return label
    }()
    private lazy var exitButton: UIButton = {
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
        button.setTitle("Выйти".localized(), for: .normal)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.addSubview(label)
        view.addSubview(exitButton)
        view.addSubview(cancelButton)
        UIView.animate(withDuration: 1) { [weak self] in
            self?.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        }
    }
    
    private func resetCoreData() {
        let coreDataService = CoreDataService()
        if let objects = try? coreDataService.container.viewContext.fetch(PublishedFiles.fetchRequest()) {
            objects.forEach({ object in
                coreDataService.container.viewContext.delete(object)
            })
        }
        if let objects = try? coreDataService.container.viewContext.fetch(LastFiles.fetchRequest()) {
            objects.forEach({ object in
                coreDataService.container.viewContext.delete(object)
            })
        }
        if let objects = try? coreDataService.container.viewContext.fetch(AllFiles.fetchRequest()) {
            objects.forEach({ object in
                coreDataService.container.viewContext.delete(object)
            })
        }
        do {
            try coreDataService.container.viewContext.save()
        } catch {
            AlertHelper.showAlert(withMessage: "\(error.localizedDescription)")
        }
    }
    
    private func resetFilesInDirectory() {
        let cachePath = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        let objects = try? FileManager().contentsOfDirectory(at: cachePath, includingPropertiesForKeys: [])
        objects?.forEach({ url in
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                AlertHelper.showAlert(withMessage: "\(error.localizedDescription)")
            }
        })
    }
    
    private func resetUserDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
    private func logout() {
        resetCoreData()
        resetFilesInDirectory()
        resetUserDefaults()
    }
    
    @objc func tapExitButton() {
        label.isHidden = true
        exitButton.isHidden = true
        cancelButton.isHidden = true
        exitAlert()
    }
    
    @objc func tapCancelButton() {
            self.dismiss(animated: true)
            self.view.backgroundColor = .clear
    }
    
    @objc func exitAlert() {
        let alert = UIAlertController(
            title: "Выход".localized(),
            message: Constants.Text.logout,
            preferredStyle: .alert
        )
        let actionYes = UIAlertAction(
            title: "Да".localized(),
            style: .default,
            handler: { _ in
                DispatchQueue.main.async { [weak self] in
                    self?.logout()
                    self?.view.backgroundColor = .clear
                    let controller = OnboardingViewController()
                    controller.nextButton.isHidden = true
                    controller.modalPresentationStyle = .fullScreen
                    self?.present(controller, animated: true)
                }
            }
        )
        let actionNo = UIAlertAction(
            title: "Нет".localized(),
            style: .destructive,
            handler: { _ in
                DispatchQueue.main.async { [weak self] in
                    alert.dismiss(animated: true)
                    self?.dismiss(animated: false)
                    let controller = TabBarController()
                    controller.modalPresentationStyle = .fullScreen
                    controller.modalTransitionStyle = .crossDissolve
                    self?.present(controller, animated: true)
                }
            }
        )
        alert.addAction(actionYes)
        alert.addAction(actionNo)
        self.present(alert, animated: true, completion: nil)
    }
}
