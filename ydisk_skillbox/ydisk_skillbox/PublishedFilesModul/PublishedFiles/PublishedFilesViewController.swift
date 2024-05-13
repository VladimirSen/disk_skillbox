import UIKit

final class PublishedFilesViewController: UIViewController, PublishedFilesViewControllerProtocol {
    var isOnInternet = true
    var viewModel: PublishedFilesViewModel?
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .large
        activityIndicator.color = .gray
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        return activityIndicator
    }()
    private lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.frame = CGRect(x: (view.frame.size.width - 160) / 2,
                             y: (view.frame.size.height - 300) / 2,
                             width: 160,
                             height: 160)
        image.image = UIImage(named: "noFiles")
        return image
    }()
    private lazy var imageXView: UIImageView = {
        let image = UIImageView()
        image.frame = CGRect(x: (view.frame.size.width - 190) / 2,
                             y: (view.frame.size.height - 330) / 2,
                             width: 55,
                             height: 55)
        image.image = UIImage(named: "x")
        return image
    }()
    private lazy var label: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: (view.frame.size.width - 200) / 2,
                             y: (view.frame.size.height - 80) / 2,
                             width: 200,
                             height: 200)
        label.text = "У вас пока нет опубликованных файлов".localized()
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    private lazy var updateButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: (view.frame.size.width - 320) / 2,
                              y: view.frame.size.height - 140,
                              width: 320,
                              height: 40)
        button.backgroundColor = .systemBlue
        button.setTitle("Обновить".localized(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(tapUpdateButton), for: .touchUpInside)
        return button
    }()
    private lazy var tableView = PagingTableView()
    private var cell = "PublishedFilesCell"
    private let token = UserDefaults.standard.string(forKey: "token") ?? ""
    private var isPresentAlert = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Опубликованные файлы".localized()
        setupBackground()
        loadingData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func presentNoFilesView() {
        view.addSubview(imageView)
        view.addSubview(imageXView)
        view.addSubview(label)
        view.addSubview(updateButton)
        view.addSubview(activityIndicator)
        self.activityIndicator.stopAnimating()
    }
    
    func presentNoInternetAlert() {
        isOnInternet = false
        if !isPresentAlert {
            createNoInternetAlert()
            isPresentAlert = true
        }
    }
    
    func reloadData() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    func reloadData(deletedFile: String) {
        viewModel?.reloadDataAfterDelete(deletedFile: deletedFile)
    }
    
    func createDetailViewController(view: UIView,
                                    dateString: String,
                                    textImageLabel: String,
                                    pathToFile: String,
                                    newPath: String? ) {
        let controller = FilesPreviewViewController.createFilesPreviewVC(view: view)
        controller.textDateLabel = String.transformDate(date: dateString)
        controller.textImageLabel = textImageLabel
        controller.pathToFile = pathToFile
        controller.newPath = newPath
        controller.hidesBottomBarWhenPushed = true
        controller.screenItems.editButton.isHidden = true
        controller.screenItems.shareButton.isHidden = true
        controller.screenItems.deleteButton.isHidden = true
        navigationController?.pushViewController(controller, animated: false)
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.pagingDelegate = self
        tableView.register(PublishedFilesCell.self, forCellReuseIdentifier: cell)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        if UIScreen.main.nativeBounds.height < 1792 {
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 65).isActive = true
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        } else {
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        }
        tableView.rowHeight = 80
        configureRefreshControl()
    }
    
    private func loadingData() {
        activityIndicator.startAnimating()
        self.viewModel = PublishedFilesViewModel()
        viewModel?.delegate = self
        self.viewModel?.uploadData(token: self.token,
                                   completion: { _ in
            self.activityIndicator.stopAnimating()
        })
    }
    
    private func createNoInternetAlert() {
        let alert = UIAlertController(
            title: "Ошибка".localized(),
            message: Constants.Text.noInt,
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: "OK",
            style: .cancel,
            handler: nil
        )
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func presentNoInternetDirAlert() {
        let alert = UIAlertController(
            title: "Ошибка".localized(),
            message: Constants.Text.noDir,
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: "OK",
            style: .cancel,
            handler: { _ in
                self.dismiss(animated: true)
            })
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func presentNoFilesAlert() {
        let alert = UIAlertController(
            title: "",
            message: Constants.Text.noFiles,
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: "OK",
            style: .cancel,
            handler: nil
        )
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func configureRefreshControl() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(actionRefreshControl), for: .valueChanged)
    }
    
    private func setupBackground() {
        var backImage = UIImage()
        if traitCollection.userInterfaceStyle == .dark {
            backImage = UIImage(named: "backgroundDark") ?? UIImage()
        } else {
            backImage = UIImage(named: "background") ?? UIImage()
        }
        view.backgroundColor = UIColor(patternImage: backImage)
        tableView.backgroundColor = UIColor(patternImage: backImage)
    }
    
    @objc func actionRefreshControl() {
        DispatchQueue.main.async { [weak self] in
            self?.viewModel?.contents = self?.viewModel?.items ?? []
            self?.viewModel?.uploadData(token: self?.token ?? "",
                                        completion: { _ in
            })
            self?.tableView.refreshControl?.endRefreshing()
            self?.reloadData()
        }
    }
    
    @objc func tapRemoveButton(_ sender: UIButton) {
        let controller = PublishedDeleteViewController()
        controller.modalPresentationStyle = .popover
        controller.controller = self
        let index = sender.tag
        let model = viewModel?.contents[index]
        guard let pathToFile = model?.path, let nameFile = model?.name else { return }
        controller.initValue(pathToFile: pathToFile, nameFile: nameFile)
        guard let presentationController = controller.popoverPresentationController else { return }
        presentationController.delegate = self
        self.present(controller, animated: false)
    }
    
    @objc func tapUpdateButton() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.startAnimating()
            self?.viewModel = PublishedFilesViewModel()
            self?.viewModel?.delegate = self
            self?.viewModel?.uploadData(token: self?.token ?? "",
                                        completion: { _ in
                self?.activityIndicator.stopAnimating()
            })
        }
    }
}

extension PublishedFilesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.contents.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PublishedFilesCell",
                                                 for: indexPath) as? PublishedFilesCell
        guard let model = viewModel?.contents[indexPath.row] else { return UITableViewCell() }
        cell?.configure(model: model)
        cell?.removeButton.addTarget(self, action: #selector(tapRemoveButton), for: .touchUpInside)
        cell?.removeButton.tag = indexPath.row
        return cell ?? UITableViewCell()
    }
}

extension PublishedFilesViewController: PagingTableViewProtocol {
    func didPaginate(_ tableView: PagingTableView, to page: Int) {}
    func paginate(_ tableView: PagingTableView, to page: Int) {
        tableView.isLoading = true
        viewModel?.loadData(at: page) { contents in
            self.viewModel?.contents.append(contentsOf: contents ?? [])
            self.tableView.isLoading = false
        }
    }
}

extension PublishedFilesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let model = viewModel?.contents[indexPath.row] else {return}
        let mediaType = model.mediaType
        let mimeType = model.mimeType
        let path = model.path
        switch model.type {
        case "file":
            if mediaType == "image" {
                createDetailViewController(view: FilesPreviewViewController.imageView,
                                           dateString: model.created ?? "",
                                           textImageLabel: model.name ?? "",
                                           pathToFile: model.path ?? "",
                                           newPath: path)
            } else if mimeType == "application/pdf"{
                createDetailViewController(view: FilesPreviewViewController.pdfView,
                                           dateString: model.created ?? "",
                                           textImageLabel: model.name ?? "",
                                           pathToFile: model.path ?? "",
                                           newPath: path)
            } else {
                createDetailViewController(view: FilesPreviewViewController.wkWebView,
                                           dateString: model.created ?? "",
                                           textImageLabel: model.name ?? "",
                                           pathToFile: model.path ?? "",
                                           newPath: path)
            }
        case "dir":
            if isOnInternet == true {
                let controller = PublishedDirViewController()
                controller.name = model.name
                controller.path = (model.path ?? "")
                navigationItem.backButtonTitle = ""
                self.navigationController?.pushViewController(controller, animated: false)
            } else {
                presentNoInternetDirAlert()
            }
        default:
            return
        }
    }
}

extension PublishedFilesViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .overFullScreen
    }
}
