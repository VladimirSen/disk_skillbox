import Foundation
import CoreData

protocol CoreDataServiseProtocol: AnyObject {
    var items: [ItemList] {get set}
    var container: NSPersistentContainer {get}
    func savePudlishedFilesItems()
    func saveLastFilesItems()
    func saveAllFilesItems()
    func showPublishedFilesItems()
    func showLastFilesItems()
    func showAllFilesItems()
    func deletePublishedFilesViewContext()
    func deleteLastFilesViewContext()
    func deleteAllFilesViewContext()
}

final class CoreDataService: CoreDataServiseProtocol {
    lazy var resultPublishedFilesController: NSFetchedResultsController <PublishedFiles> = {
        let request = PublishedFiles.fetchRequest()
        let sort = NSSortDescriptor(key: "name", ascending: false)
        request.sortDescriptors = [sort]
        let resultController = NSFetchedResultsController(fetchRequest: request,
                                                          managedObjectContext: container.viewContext,
                                                          sectionNameKeyPath: nil,
                                                          cacheName: nil)
        return resultController
    }()
    lazy var resultLastFilesController: NSFetchedResultsController <LastFiles> = {
        let request = LastFiles.fetchRequest()
        let sort = NSSortDescriptor(key: "name", ascending: false)
        request.sortDescriptors = [sort]
        let resultController = NSFetchedResultsController(fetchRequest: request,
                                                          managedObjectContext: container.viewContext,
                                                          sectionNameKeyPath: nil,
                                                          cacheName: nil)
        return resultController
    }()
    lazy var resultAllFilesController: NSFetchedResultsController <AllFiles> = {
        let request = AllFiles.fetchRequest()
        let sort = NSSortDescriptor(key: "name", ascending: false)
        request.sortDescriptors = [sort]
        let resultController = NSFetchedResultsController(fetchRequest: request,
                                                          managedObjectContext: container.viewContext,
                                                          sectionNameKeyPath: nil,
                                                          cacheName: nil)
        return resultController
    }()
    let container = NSPersistentContainer(name: "ydisk_skillbox")
    var items: [ItemList] = []
    
    init() {
        container.loadPersistentStores { _, error in
            if let error = error {
                AlertHelper.showAlert(withMessage: "\(error)")
            } else {
                do {
                    try self.resultPublishedFilesController.performFetch()
                    try self.resultLastFilesController.performFetch()
                    try self.resultAllFilesController.performFetch()
                } catch {
                    AlertHelper.showAlert(withMessage: "\(error)")
                }
            }
        }
    }
    
    func savePudlishedFilesItems() {
        do {
            items.forEach({ [weak self] itemList in
                if let context = self?.container.viewContext,
                   let entity = NSEntityDescription.entity(forEntityName: "PublishedFiles", in: context) {
                    let object = PublishedFiles(entity: entity, insertInto: context)
                    object.name = itemList.name
                    object.preview = itemList.preview
                    object.created = itemList.created
                    object.size = itemList.size ?? 0
                    object.mimeType = itemList.mimeType
                    object.mediaType = itemList.mediaType
                    object.type = itemList.type
                }
            })
            try self.container.viewContext.save()
        } catch {
            AlertHelper.showAlert(withMessage: "\(error.localizedDescription)")
        }
    }
    
    func saveLastFilesItems() {
        do {
            items.forEach({ [weak self] itemList in
                if let context = self?.container.viewContext,
                   let entity = NSEntityDescription.entity(forEntityName: "LastFiles", in: context) {
                    let object = LastFiles(entity: entity, insertInto: context)
                    object.name = itemList.name
                    object.preview = itemList.preview
                    object.created = itemList.created
                    object.size = itemList.size ?? 0
                    object.mimeType = itemList.mimeType
                    object.mediaType = itemList.mediaType
                    object.type = itemList.type
                }
            })
            try self.container.viewContext.save()
        } catch {
            AlertHelper.showAlert(withMessage: "\(error.localizedDescription)")
        }
    }
    
    func saveAllFilesItems() {
        do {
            items.forEach({ [weak self] itemList in
                if let context = self?.container.viewContext,
                   let entity = NSEntityDescription.entity(forEntityName: "AllFiles", in: context) {
                    let object = AllFiles(entity: entity, insertInto: context)
                    object.name = itemList.name
                    object.preview = itemList.preview
                    object.created = itemList.created
                    object.size = itemList.size ?? 0
                    object.mimeType = itemList.mimeType
                    object.mediaType = itemList.mediaType
                    object.type = itemList.type
                }
            })
            try self.container.viewContext.save()
        } catch {
            AlertHelper.showAlert(withMessage: "\(error.localizedDescription)")
        }
    }
    
    func showPublishedFilesItems() {
        guard let arrayLinkFiles = try? self.container.viewContext.fetch(PublishedFiles.fetchRequest()) else {return}
        self.items = arrayLinkFiles.map({ fetchObjects in
            ItemList(name: fetchObjects.name,
                     preview: fetchObjects.preview,
                     created: fetchObjects.created,
                     modified: fetchObjects.modified,
                     mediaType: fetchObjects.mediaType,
                     path: fetchObjects.path,
                     type: fetchObjects.type,
                     mimeType: fetchObjects.mimeType,
                     size: fetchObjects.size)
        })
        self.items.sort(by: { items1, items2 in
            items2.type ?? "" > items1.type ?? ""
        })
    }
    
    func showLastFilesItems() {
        guard let arrayLastFiles = try? self.container.viewContext.fetch(LastFiles.fetchRequest()) else {return}
        self.items = arrayLastFiles.map({ fetchObjects in
            ItemList(name: fetchObjects.name,
                     preview: fetchObjects.preview,
                     created: fetchObjects.created,
                     modified: fetchObjects.modified,
                     mediaType: fetchObjects.mediaType,
                     path: fetchObjects.path,
                     type: fetchObjects.type,
                     mimeType: fetchObjects.mimeType,
                     size: fetchObjects.size)
        })
        self.items.sort(by: { items1, items2 in
            items1.created ?? "" > items2.created ?? ""
        })
    }
    
    func showAllFilesItems() {
        guard let arrayAllFiles = try? self.container.viewContext.fetch(AllFiles.fetchRequest()) else {return}
        self.items = arrayAllFiles.map({ fetchObjects in
            ItemList(name: fetchObjects.name,
                     preview: fetchObjects.preview,
                     created: fetchObjects.created,
                     modified: fetchObjects.modified,
                     mediaType: fetchObjects.mediaType,
                     path: fetchObjects.path,
                     type: fetchObjects.type,
                     mimeType: fetchObjects.mimeType,
                     size: fetchObjects.size)
        })
        self.items.sort(by: { items1, items2 in
            items2.type ?? "" > items1.type ?? ""
        })
    }
    
    func deletePublishedFilesViewContext() {
        if let objects = try? self.container.viewContext.fetch(PublishedFiles.fetchRequest()) {
            objects.forEach({ object in
                self.container.viewContext.delete(object)
            })
        }
    }
    
    func deleteLastFilesViewContext() {
        if let objects = try? self.container.viewContext.fetch(LastFiles.fetchRequest()) {
            objects.forEach({ object in
                self.container.viewContext.delete(object)
            })
        }
    }
    
    func deleteAllFilesViewContext() {
        if let objects = try? self.container.viewContext.fetch(AllFiles.fetchRequest()) {
            objects.forEach({ object in
                self.container.viewContext.delete(object)
            })
        }
    }
}
