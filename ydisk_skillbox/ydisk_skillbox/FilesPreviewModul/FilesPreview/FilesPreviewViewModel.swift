import Foundation

protocol FilesPreviewViewControllerProtocol: AnyObject {
    var newPath: String? {get set}
    func presentNoInternetAlert()
    func setupData(data: FilesPreviewModel)
    func deleteFileInCache()
    func reloadData()
}

protocol FilesPreviewViewModelProtocol: AnyObject {
    var delegate: FilesPreviewViewControllerProtocol? {get set}
    func createDirectoryURLForFile(fileName: String) -> URL
    func uploadFileInCache(url: String?, fileName: String, completion: @escaping (URL) -> Void )
    func editFileInCache(at fileName: String?, to newFileName: String)
    func deleteFileInCache(at fileName: String?)
    func editFile(from pathToFile: String?, to toPath: String)
    func deleteFile(_ pathToFile: String)
    func uploadData(_ pathToFile: String)
}

final class FilesPreviewViewModel: FilesPreviewViewModelProtocol {
    weak var delegate: FilesPreviewViewControllerProtocol?
    private var networkService: NetworkServiceProtocol? = NetworkService()
    
    func createDirectoryURLForFile(fileName: String) -> URL {
        let cachePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let filesPath = cachePath.appendingPathComponent("Files")
        try? FileManager.default.createDirectory(at: filesPath, withIntermediateDirectories: false, attributes: nil)
        let fileURL = filesPath.appendingPathComponent(fileName)
        return fileURL
    }
    
    func uploadFileInCache(url: String?, fileName: String, completion: @escaping (URL) -> Void) {
        let fileURL = createDirectoryURLForFile(fileName: fileName)
        if (try? Data(contentsOf: fileURL)) != nil {
                completion(fileURL)
        } else {
            guard let url = url else { return }
            guard let url2 = URL(string: url) else { return  }
            let request = URLRequest(url: url2)
            let task = URLSession.shared.downloadTask(with: request) { localURL, _, _ in
                guard let localURL = localURL else { return }
                do {
                    try FileManager.default.copyItem(at: localURL, to: fileURL)
                    DispatchQueue.main.async {
                        completion(fileURL)
                    }
                } catch let error {
                    AlertHelper.showAlert(withMessage: "Copy Error: \(error.localizedDescription)")
                }
            }
            task.resume()
        }
    }
    
    func editFileInCache(at fileName: String?, to newFileName: String) {
        guard let fileName = fileName else { return }
        let atFileURL = createDirectoryURLForFile(fileName: fileName)
        let toFileURL = createDirectoryURLForFile(fileName: newFileName)
        do {
            try FileManager.default.moveItem(at: atFileURL, to: toFileURL)
        } catch {
            AlertHelper.showAlert(withMessage: "Move Error: \(error.localizedDescription)")
        }
    }
    
    func deleteFileInCache(at fileName: String?) {
        guard let fileName = fileName else { return }
        let atFileURL = createDirectoryURLForFile(fileName: fileName)
        do {
            try FileManager.default.removeItem(at: atFileURL)
        } catch {
            AlertHelper.showAlert(withMessage: "Remove Error: \(error.localizedDescription)")
        }
    }
    
    func editFile(from pathToFile: String?, to toPath: String) {
        networkService?.requestEditFile(from: pathToFile, to: toPath)
    }
    
    func deleteFile(_ pathToFile: String) {
        networkService?.requestDeleteFile(pathToFile)
    }
    
    func uploadData(_ pathToFile: String) {
        networkService?.requestPreveiwFile(pathToFile) { [weak self] (dataList, _) in
            DispatchQueue.main.async { [weak self] in
                guard let dataList = dataList else {
                    self?.delegate?.presentNoInternetAlert()
                    return
                }
                self?.delegate?.setupData(data: dataList)
            }
        }
    }
}
