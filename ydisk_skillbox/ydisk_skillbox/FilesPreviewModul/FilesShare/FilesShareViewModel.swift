import Foundation

protocol FilesShareViewControllerProtocol: AnyObject {
    func setupData(publicUrl: String)
}

protocol FilesShareViewModelProtocol: AnyObject {
    func uploadData(_ pathToFile: String)
}

final class FilesShareViewModel: FilesShareViewModelProtocol {
    weak var delegate: FilesShareViewController?
    private var networkService: NetworkServiceProtocol? = NetworkService()
    
    func uploadData(_ pathToFile: String) {
        networkService?.requestShareFile(pathToFile) { [weak self] _ in
            self?.loadLink(pathToFile)
        }
    }
    
    private func loadLink(_ pathToFile: String) {
        networkService?.requestLoadLink(pathToFile) { [weak self] dataList in
            self?.delegate?.setupData(publicUrl: dataList?.publicUrl ?? "")
        }
    }
}
