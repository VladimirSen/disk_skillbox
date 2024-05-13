import Foundation
import CoreData

protocol LastFilesViewControllerProtocol: AnyObject {
    func presentNoInternetAlert()
    func reloadData()
    func reloadData(deletedFile: String)
    func editName(oldName: String, newName: String)
    func setupTableView()
}

protocol LastFilesViewModelProtocol: AnyObject {
    func editName(oldName: String, newName: String)
    func reloadDataAfterDelete(deletedFile: String)
    func uploadData(token: String, completion: @escaping ([ItemList]?) -> Void)
}

final class LastFilesViewModel: LastFilesViewModelProtocol {
    var items: [ItemList] = []
    var contents: [ItemList] = []
    weak var delegate: LastFilesViewControllerProtocol?
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
    
    func editName(oldName: String, newName: String) {
        for (index, value) in items.enumerated() where value.name == oldName {
            items[index].name = newName
        }
        for (index, value) in contents.enumerated() where value.name == oldName {
            contents[index].name = newName
        }
        delegate?.reloadData()
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
        networkService?.requestLastFiles(token: token) { [weak self] (dataList, error) in
            DispatchQueue.main.async { [weak self] in
                guard let dataList = dataList else {
                    if error?.localizedDescription == Constants.Text.internetError {
                        self?.delegate?.presentNoInternetAlert()
                        self?.coreDataModel?.showLastFilesItems()
                        self?.items = self?.coreDataModel?.items ?? []
                        self?.delegate?.setupTableView()
                    }
                    return
                }
                self?.coreDataModel?.deleteLastFilesViewContext()
                if self?.items != nil {
                    self?.items.removeAll()
                    self?.coreDataModel?.items.removeAll()
                }
                self?.items = dataList.items
                self?.items.sort(by: { items1, items2 in
                    items1.created ?? "" > items2.created ?? ""
                })
                self?.coreDataModel?.items = dataList.items
                self?.coreDataModel?.saveLastFilesItems()
                self?.delegate?.setupTableView()
            }
        }
    }
}
