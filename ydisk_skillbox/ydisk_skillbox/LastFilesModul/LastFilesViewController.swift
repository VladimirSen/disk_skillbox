import UIKit

final class LastFilesViewController: UIViewController, LastFilesViewControllerProtocol {
    var isOnInternet = true
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .large
        activityIndicator.color = .gray
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        return activityIndicator
    }()
    private lazy var tableView = PagingTableView()
    private var cell = "FilesCell"
    private let token = UserDefaults.standard.string(forKey: "token") ?? ""
    private var isPresentAlert = false
    private var viewModel: LastFilesViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Последние".localized()
        setupBackground()
        loadingData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
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
    
    func editName(oldName: String, newName: String) {
        viewModel?.editName(oldName: oldName, newName: newName)
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
        controller.lastFilesVC = self
        controller.hidesBottomBarWhenPushed = true
        if isOnInternet == false {
            controller.screenItems.editButton.isHidden = true
            controller.screenItems.shareButton.isHidden = true
            controller.screenItems.deleteButton.isHidden = true
        }
        navigationController?.pushViewController(controller, animated: false)
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.pagingDelegate = self
        tableView.register(FilesCell.self, forCellReuseIdentifier: cell)
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
    
    private func loadingData() {
        activityIndicator.startAnimating()
        self.viewModel = LastFilesViewModel()
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
    
    private func configureRefreshControl() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self,
                                            action: #selector(actionRefreshControl),
                                            for: .valueChanged)
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
}

extension LastFilesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.contents.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilesCell",
                                                 for: indexPath) as? FilesCell
        guard let model = viewModel?.contents[indexPath.row] else { return UITableViewCell() }
        cell?.configure(model: model)
        return cell ?? UITableViewCell()
    }
}

extension LastFilesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let model = viewModel?.contents[indexPath.row] else {return}
        let mediaType = model.mediaType
        let mimeType = model.mimeType
        let path = model.path
        var splitPath = path?.split(separator: "/")
        splitPath?.removeLast()
        var newPath: String = ""
        splitPath?.forEach { str in
            newPath = newPath + str + "/"
        }
        if mediaType == "image" {
            createDetailViewController(view: FilesPreviewViewController.imageView,
                                       dateString: model.created ?? "",
                                       textImageLabel: model.name ?? "",
                                       pathToFile: model.path ?? "",
                                       newPath: newPath)
        } else if mimeType == "application/pdf" {
            createDetailViewController(view: FilesPreviewViewController.pdfView,
                                       dateString: model.created ?? "",
                                       textImageLabel: model.name ?? "",
                                       pathToFile: model.path ?? "",
                                       newPath: nil)
        } else {
            createDetailViewController(view: FilesPreviewViewController.wkWebView,
                                       dateString: model.created ?? "",
                                       textImageLabel: model.name ?? "",
                                       pathToFile: model.path ?? "",
                                       newPath: nil)
        }
    }
}

extension LastFilesViewController: PagingTableViewProtocol {
    func didPaginate(_ tableView: PagingTableView, to page: Int) {}
    func paginate(_ tableView: PagingTableView, to page: Int) {
        tableView.isLoading = true
        viewModel?.loadData(at: page) { contents in
            self.viewModel?.contents.append(contentsOf: contents ?? [])
            self.tableView.isLoading = false
        }
    }
}
