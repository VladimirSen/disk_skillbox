import Foundation
import CoreData

protocol AllFilesViewControllerProtocol: AnyObject {
    func presentNoInternetAlert()
    func presentNoFilesAlert()
    func reloadData()
    func reloadData(deletedFile: String)
    func editName(oldName: String, newName: String)
    func setupTableView()
}

protocol AllFilesViewModelProtocol: AnyObject {
    func uploadData(token: String, path: String?, completion: @escaping ([ItemList]?) -> Void)
    func reloadDataAfterDelete(deletedFile: String)
    func editName(oldName: String, newName: String)
}

final class AllFilesViewModel: AllFilesViewModelProtocol {
    var items: [ItemList] = []
    var contents: [ItemList] = []
    weak var delegate: AllFilesViewControllerProtocol?
    private var coreDataModel: CoreDataServiseProtocol? = CoreDataService()
    private var networkService: NetworkServiceProtocol? = NetworkService()
    private let token = UserDefaults.standard.string(forKey: "token") ?? ""
    private var path = ""
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
    
    func reloadDataAfterDelete(deletedFile: String) {
        for (index, value) in items.enumerated() where value.name == deletedFile {
            items.remove(at: index)
        }
        for (index, value) in contents.enumerated() where value.name == deletedFile {
            contents.remove(at: index)
        }
        delegate?.reloadData()
    }
    
    func editName(oldName: String, newName: String) {
        for (index, value) in items.enumerated() where value.name == oldName {
            items[index].name = newName
        }
        for (index, value) in contents.enumerated() where value.name == oldName {
            contents[index].name = newName
        }
        delegate?.reloadData()
    }
    
    func uploadData(token: String, path: String?, completion: @escaping ([ItemList]?) -> Void) {
        networkService?.requestAllFiles(token: token, path: path) { [weak self] (dataList, error) in
            DispatchQueue.main.async { [weak self] in
                guard let dataList = dataList else {
                    if error?.localizedDescription == Constants.Text.internetError {
                        self?.delegate?.presentNoInternetAlert()
                        self?.coreDataModel?.showAllFilesItems()
                        self?.items = self?.coreDataModel?.items ?? []
                        self?.delegate?.setupTableView()
                    }
                    return
                }
                self?.coreDataModel?.deleteAllFilesViewContext()
                if self?.items != nil {
                    self?.items.removeAll()
                    self?.coreDataModel?.items.removeAll()
                }
                if dataList.embedded.items.isEmpty {
                    self?.delegate?.presentNoFilesAlert()
                } else {
                    dataList.embedded.items.forEach { items in
                        self?.items.append(items)
                        self?.coreDataModel?.items.append(items)
                    }
                    self?.items.sort(by: { items1, items2 in
                        items2.type ?? "" > items1.type ?? ""
                    })
                    self?.coreDataModel?.saveAllFilesItems()
                    self?.delegate?.setupTableView()
                }
            }
        }
    }
}
