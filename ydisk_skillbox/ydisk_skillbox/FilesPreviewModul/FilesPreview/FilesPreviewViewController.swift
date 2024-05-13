import UIKit
import WebKit
import PDFKit

final class FilesPreviewViewController: UIViewController, FilesPreviewViewControllerProtocol {
    var lastFilesVC: LastFilesViewControllerProtocol?
    var allFilesVC: AllFilesViewControllerProtocol?
    lazy var screenItems = FilesPreviewItems()
    lazy var pathToFile: String = ""
    lazy var newPath: String? = nil
    lazy var textDateLabel: String = ""
    lazy var textImageLabel: String = ""
    static var imageView = UIImageView()
    static var pdfView = PDFView()
    static var wkWebView: WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        let view = WKWebView(frame: .zero, configuration: webConfiguration)
        view.isUserInteractionEnabled = true
        return view
    }
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .large
        activityIndicator.color = .lightGray
        activityIndicator.center = view.center
        return activityIndicator
    }()
    private lazy var data: FilesPreviewModel? = nil
    private lazy var isHiddenItems = false
    private var uiView: UIView?
    private var file: Any = 0
    private let token = UserDefaults.standard.string(forKey: "token") ?? ""
    private let viewModel: FilesPreviewViewModelProtocol = FilesPreviewViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        configuration()
    }
    
    func reloadData() {
        lastFilesVC?.reloadData(deletedFile: textImageLabel)
        allFilesVC?.reloadData(deletedFile: textImageLabel)
        dismiss(animated: true) { [weak self] in
            self?.tapBackButton()
        }
    }
    
    func setupData(data: FilesPreviewModel) {
        self.data = data
        viewSelection(data: self.data)
    }
    
    func deleteFileInCache() {
        viewModel.deleteFileInCache(at: textImageLabel)
    }
    
    func presentNoInternetAlert() {
        let alert = UIAlertController(
            title: "Ошибка".localized(),
            message: Constants.Text.noIntFile,
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: "OK",
            style: .cancel,
            handler: { _ in
                self.dismiss(animated: true)
                self.tapBackButton()
            })
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    static func createFilesPreviewVC(view: UIView) -> FilesPreviewViewController {
        let controller = FilesPreviewViewController()
        controller.uiView = view
        return controller
    }
    
    private func presentEditAlert(completion: @escaping (String) -> Void) {
        let alert = UIAlertController(
            title: "Переименовать".localized(),
            message: nil,
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(
            title: "Отмена".localized(),
            style: .cancel
        )
        let doneAction = UIAlertAction(
            title: "Готово".localized(),
            style: .default ) { [weak self] _ in
                guard let self = self else {return}
                guard let text = alert.textFields?.first?.text, !text.isEmpty else {return}
                let oldName = self.textImageLabel
                guard let extensions = oldName.split(separator: ".").last else {return}
                let newName = "\(text).\(extensions)"
                DispatchQueue.main.async {
                    self.screenItems.nameLabel.text = newName
                }
                if let publicUrl = UserDefaults.standard.string(forKey: oldName) {
                    UserDefaults.standard.set(publicUrl, forKey: newName)
                    UserDefaults.standard.removeObject(forKey: oldName)
                }
                self.viewModel.editFileInCache(at: oldName, to: newName)
                self.viewModel.editFile(from: self.pathToFile, to: "\(self.newPath ?? "")\(newName)")
                self.lastFilesVC?.editName(oldName: oldName, newName: newName)
                self.allFilesVC?.editName(oldName: oldName, newName: newName)
            }
        alert.addAction(cancelAction)
        alert.addAction(doneAction)
        alert.addTextField { [weak self] textField in
            textField.placeholder = self?.textImageLabel
        }
        present(alert, animated: true)
    }
    
    private func configuration() {
        viewModel.delegate = self
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        showData()
        tapImage()
    }
    
    private func addItems() {
        self.view.addSubview(self.screenItems.nameLabel)
        self.view.addSubview(self.screenItems.dateLabel)
        self.view.addSubview(self.screenItems.backButton)
        self.view.addSubview(self.screenItems.editButton)
        self.view.addSubview(self.screenItems.shareButton)
        self.view.addSubview(self.screenItems.deleteButton)
        screenItems.nameLabel.text = textImageLabel
        screenItems.dateLabel.text = textDateLabel
        screenItems.backButton.addTarget(self, action: #selector(tapBackButton), for: .touchUpInside)
        screenItems.editButton.addTarget(self, action: #selector(tapEditButton), for: .touchUpInside)
        screenItems.shareButton.addTarget(self, action: #selector(tapShareButton), for: .touchUpInside)
        screenItems.deleteButton.addTarget(self, action: #selector(tapDeleteButton), for: .touchUpInside)
        setupItemsConstraints()
    }
    
    private func setupItemsConstraints() {
        if UIScreen.main.nativeBounds.height < 1792 {
            screenItems.nameLabel.frame = CGRect(x: 50, y: 25, width: view.frame.size.width - 100, height: 20)
            screenItems.dateLabel.frame = CGRect(x: 50, y: 50, width: view.frame.size.width - 100, height: 10)
            screenItems.backButton.frame = CGRect(x: 3, y: 34, width: 24, height: 22)
            screenItems.editButton.frame = CGRect(x: view.frame.size.width - 41, y: 32, width: 26, height: 26)
            screenItems.shareButton.frame = CGRect(x: 53, y: view.frame.size.height - 48, width: 26, height: 26)
            screenItems.deleteButton.frame = CGRect(x: view.frame.size.width - 79,
                                        y: view.frame.size.height - 48, width: 26, height: 26)
        } else {
            screenItems.nameLabel.frame = CGRect(x: 50, y: 55, width: view.frame.size.width - 100, height: 20)
            screenItems.dateLabel.frame = CGRect(x: 50, y: 80, width: view.frame.size.width - 100, height: 10)
            screenItems.backButton.frame = CGRect(x: 3, y: 64, width: 24, height: 22)
            screenItems.editButton.frame = CGRect(x: view.frame.size.width - 41, y: 62, width: 26, height: 26)
            screenItems.shareButton.frame = CGRect(x: 53, y: view.frame.size.height - 78, width: 26, height: 26)
            screenItems.deleteButton.frame = CGRect(x: view.frame.size.width - 79,
                                        y: view.frame.size.height - 78, width: 26, height: 26)
        }
    }
    
    private func showData() {
        let url = viewModel.createDirectoryURLForFile(fileName: textImageLabel)
            if (try? Data(contentsOf: url)) != nil {
            viewSelection(data: nil)
        } else {
            viewModel.uploadData(pathToFile)
        }
    }
    
    private func viewSelection(data: FilesPreviewModel?) {
        switch self.uiView {
        case _ as UIImageView:
            self.viewModel.uploadFileInCache(url: data?.file, fileName: textImageLabel) { url in
                guard let data = try? Data(contentsOf: url) else {return}
                guard let image = UIImage(data: data) else {return}
                let imageScrollView = ImageScrollView(frame: self.view.frame)
                self.file = image
                imageScrollView.set(image: image)
                self.view.addSubview(imageScrollView)
                self.addItems()
                self.activityIndicator.stopAnimating()
            }
        case let pdf as PDFView:
            self.viewModel.uploadFileInCache(url: data?.file, fileName: textImageLabel) { url in
                guard let pdfDocument = PDFDocument(url: url) else { return }
                self.file = pdfDocument
                self.view.addSubview(pdf)
                self.addItems()
                pdf.frame = self.view.frame
                pdf.document = pdfDocument
                self.activityIndicator.stopAnimating()
            }
        case let document as WKWebView:
            self.viewModel.uploadFileInCache(url: data?.file, fileName: textImageLabel) { url in
                guard let file = try? Data(contentsOf: url) else { return }
                self.file = file
                document.frame = self.view.frame
                self.view.addSubview(document)
                self.addItems()
                document.loadFileURL(url, allowingReadAccessTo: url)
                self.activityIndicator.stopAnimating()
            }
        default:
            return
        }
    }
    
    private func tapImage() {
        let oneTap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        oneTap.delegate = self
        view.addGestureRecognizer(oneTap)
   }
    
    @objc private func tapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func tapEditButton() {
        presentEditAlert { _ in }
    }
    
    @objc private func tapShareButton() {
        let controller = FilesShareViewController()
        controller.modalPresentationStyle = .popover
        controller.initValue(path: pathToFile, file: file)
        guard let presentationController = controller.popoverPresentationController else { return }
        presentationController.delegate = self
        self.present(controller, animated: true)
    }
    
    @objc private func tapDeleteButton() {
        let controller = FilesDeleteViewController()
        UserDefaults.standard.removeObject(forKey: textImageLabel)
        controller.initValue(path: pathToFile, controller: self)
        controller.modalPresentationStyle = .popover
        guard let presentationController = controller.popoverPresentationController else { return }
        presentationController.delegate = self
        self.present(controller, animated: true)
    }
    
    @objc private func handleTap() {
        UIView.animate(withDuration: 0.5) {
            self.screenItems.dateLabel.alpha = self.isHiddenItems ? 1 : 0
            self.screenItems.nameLabel.alpha = self.isHiddenItems ? 1 : 0
            self.screenItems.backButton.alpha = self.isHiddenItems ? 1 : 0
            self.screenItems.editButton.alpha = self.isHiddenItems ? 1 : 0
            self.screenItems.shareButton.alpha = self.isHiddenItems ? 1 : 0
            self.screenItems.deleteButton.alpha = self.isHiddenItems ? 1 : 0
        } completion: { _ in
            self.isHiddenItems = !self.isHiddenItems
        }
    }
}

extension FilesPreviewViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension FilesPreviewViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .currentContext
    }
}
