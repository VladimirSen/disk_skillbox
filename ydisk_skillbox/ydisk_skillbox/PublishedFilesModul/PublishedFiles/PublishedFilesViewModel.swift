import Foundation
import CoreData

protocol PublishedFilesViewControllerProtocol: AnyObject {
    func presentNoInternetAlert()
    func presentNoFilesView()
    func reloadData()
    func reloadData(deletedFile: String)
    func setupTableView()
}

protocol PublishedFilesViewModelProtocol: AnyObject {
    func uploadData(token: String, completion: @escaping ([ItemList]?) -> Void)
    func deletePublishedFile(_ pathToFile: String)
    func reloadDataAfterDelete(deletedFile: String)
}

final class PublishedFilesViewModel: PublishedFilesViewModelProtocol {
    var items: [ItemList] = []
    var contents: [ItemList] = []
    weak var delegate: PublishedFilesViewControllerProtocol?
    private var coreDataModel: CoreDataServiseProtocol? = CoreDataService()
    private var networkService: NetworkServiceProtocol? = NetworkService()
    private let itemsOnPage = 10
    
    func loadData(at page: Int, completion: @escaping ([ItemList]?) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let firstIndex = page * self.itemsOnPage
            guard firstIndex < self.items.count else {
                completion([])
                return
            }
            let lastIndex = (page + 1) * self.itemsOnPage < self.items.count ? (page + 1) * self.itemsOnPage : self.items.count
            completion(Array((self.items[firstIndex ..< lastIndex])))
        }
    }
    
    func deletePublishedFile(_ pathToFile: String) {
        networkService?.requestDeletePublishedFile(pathToFile)
    }
    
    func reloadDataAfterDelete(deletedFile: String) {
        for (index, value) in items.enumerated() where value.name == deletedFile {
            items.remove(at: index)
        }
        for (index, value) in contents.enumerated() where value.name == deletedFile {
            contents.remove(at: index)
        }
        delegate?.reloadData()
    }
    
    func uploadData(token: String, completion: @escaping ([ItemList]?) -> Void) {
        networkService?.requestPublishedFiles(token: token) { [weak self] (dataList, error) in
            DispatchQueue.main.async { [weak self] in
                guard let dataList = dataList else {
                    if error?.localizedDescription == Constants.Text.internetError {
                        self?.delegate?.presentNoInternetAlert()
                        self?.coreDataModel?.showPublishedFilesItems()
                        self?.items = self?.coreDataModel?.items ?? []
                        self?.delegate?.setupTableView()
                    }
                    return
                }
                self?.coreDataModel?.deletePublishedFilesViewContext()
                if self?.items != nil {
                    self?.items.removeAll()
                    self?.coreDataModel?.items.removeAll()
                }
                if dataList.items.isEmpty {
                    self?.delegate?.presentNoFilesView()
                } else {
                    dataList.items.forEach { items in
                        self?.items.append(items)
                        self?.coreDataModel?.items.append(items)
                    }
                    self?.delegate?.setupTableView()
                }
                self?.items.sort(by: { items1, items2 in
                    items2.type ?? "" > items1.type ?? ""
                })
                self?.coreDataModel?.savePudlishedFilesItems()
            }
        }
    }
}
