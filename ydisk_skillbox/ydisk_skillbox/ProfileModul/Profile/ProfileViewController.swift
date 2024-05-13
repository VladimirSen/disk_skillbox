import UIKit

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    var isOnInternet: Bool = true
    private lazy var publishedFilesButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: (view.frame.size.width - 320) / 2,
                              y: 445,
                              width: 320,
                              height: 40)
        if traitCollection.userInterfaceStyle == .dark {
            button.backgroundColor = .systemGray6
            button.setTitleColor(.white, for: .normal)
        } else {
            button.backgroundColor = .white
            button.setTitleColor(.black, for: .normal)
        }
        button.setTitle("Опубликованные файлы                >".localized(), for: .normal)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        if #available(iOS 14.0, *) {
            button.addAction(
                UIAction(
                    handler: { [weak self] _ in
                        self?.navigationController?.pushViewController(PublishedFilesViewController(), animated: false)
                    }),
                for: .touchUpInside)
        } else {
            button.addTarget(self, action: #selector(tapPublishedFilesButton), for: .touchUpInside)
        }
        return button
    }()
    private lazy var busyOnDiskColorView: UIView = {
        let uiView = UIView()
        uiView.frame = CGRect(x: 25,
                              y: 352,
                              width: 25,
                              height: 25)
        uiView.backgroundColor = colorBusyOnDisk
        uiView.layer.cornerRadius = 12.5
        uiView.layer.masksToBounds = true
        return uiView
    }()
    private lazy var freeOnDiskColorView: UIView = {
        let uiView = UIView()
        uiView.frame = CGRect(x: 25,
                              y: 387,
                              width: 25,
                              height: 25)
        uiView.backgroundColor = colorFreeOnDisk
        uiView.layer.cornerRadius = 12.5
        uiView.layer.masksToBounds = true
        return uiView
    }()
    private lazy var noInternetConnections: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0,
                             y: 85,
                             width: view.frame.size.width,
                             height: 50)
        label.text = "Нет подключения к интернету!".localized()
        label.textAlignment = .center
        label.backgroundColor = .red
        return label
    }()
    private lazy var pieChart: UIView = {
        let uiView = UIView()
        uiView.frame = CGRect(x: (view.frame.size.width - 220) / 2,
                              y: 115,
                              width: 220,
                              height: 220)
        return uiView
    }()
    private lazy var diskSpace: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: (view.frame.size.width - 45) / 2,
                             y: 215,
                             width: 45,
                             height: 20)
        label.textAlignment = .center
        return label
    }()
    private lazy var busyOnDisk: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 60,
                             y: 350,
                             width: 250,
                             height: 30)
        return label
    }()
    private lazy var freeOnDisk: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 60,
                             y: 385,
                             width: 250,
                             height: 30)
        return label
    }()
    private var viewModel: ProfileViewModelProtocol?
    private let colorFreeOnDisk = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
    private let colorBusyOnDisk = #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfileView()
        setupProfileData()
        loadingData()
    }
    
    func setupProfileData() {
        let data = viewModel?.data
        let totalSpace = Double(data?.totalSpace ?? 0) / (1024 * 1024 * 1024)
        let usedSpace = Double(data?.usedSpace ?? 0) / (1024 * 1024 * 1024)
        let freeSpace = totalSpace - usedSpace
        let totalSpaceOnScreen = "\(Int(totalSpace)) " + " " + "ГБ".localized()
        let usedSpaceOnScreen = String(format: "%.2F", usedSpace) + " " + "ГБ - занято".localized()
        let freeSpaceOnScreen = String(format: "%.2F", freeSpace) + " " + "ГБ - свободно".localized()
        let noneData = "Не удалось получить данные".localized()
        noInternetConnections.isHidden = self.isOnInternet ? true : false
        setupPieChartFreeOnDisk()
        setupPieChartBusyOnDisk(usedSpace / totalSpace)
        diskSpace.text = self.isOnInternet ? totalSpaceOnScreen : "?"
        busyOnDisk.text = self.isOnInternet ? usedSpaceOnScreen : noneData
        freeOnDisk.text = self.isOnInternet ? freeSpaceOnScreen : noneData
    }
    
    private func loadingData() {
        self.viewModel = ProfileViewModel()
        viewModel?.delegate = self
        viewModel?.uploadData()
    }
    
    private func setupProfileView() {
        var backImage = UIImage()
        if traitCollection.userInterfaceStyle == .dark {
            backImage = UIImage(named: "backgroundDark") ?? UIImage()
        } else {
            backImage = UIImage(named: "background") ?? UIImage()
        }
        view.backgroundColor = UIColor(patternImage: backImage)
        navigationItem.title = "Профиль".localized()
        navigationItem.backButtonTitle = ""
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Выйти".localized(),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(profileExit))
        view.addSubview(publishedFilesButton)
        view.addSubview(busyOnDiskColorView)
        view.addSubview(freeOnDiskColorView)
        view.addSubview(pieChart)
        view.addSubview(diskSpace)
        view.addSubview(busyOnDisk)
        view.addSubview(freeOnDisk)
        view.addSubview(noInternetConnections)
    }
    
    private func setupPieChartBusyOnDisk(_ strokeValue: Double) {
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(ovalIn: CGRect(x: 25,
                                                 y: 25,
                                                 width: pieChart.bounds.width - 50,
                                                 height: pieChart.bounds.height - 50)).cgPath
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 50
        layer.strokeColor = colorBusyOnDisk.cgColor
        layer.strokeEnd = strokeValue
        pieChart.clipsToBounds = true
        pieChart.layer.addSublayer(layer)
    }
    
    private func setupPieChartFreeOnDisk() {
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(ovalIn: CGRect(x: 25,
                                                 y: 25,
                                                 width: pieChart.bounds.width - 50,
                                                 height: pieChart.bounds.height - 50)).cgPath
        layer.lineWidth = 50
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = colorFreeOnDisk.cgColor
        pieChart.clipsToBounds = true
        pieChart.layer.addSublayer(layer)
    }
    
    @objc func tapPublishedFilesButton() {
        navigationController?.pushViewController(PublishedFilesViewController(), animated: true)
    }
    
    @objc func profileExit() {
        let controller = ProfileExitViewController()
        controller.modalPresentationStyle = .popover
        guard let presentationController = controller.popoverPresentationController else { return }
        presentationController.delegate = self
        self.present(controller, animated: false)
    }
}

extension ProfileViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .overFullScreen
    }
}
