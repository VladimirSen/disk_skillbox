import Foundation
import CoreData

extension LastFiles {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<LastFiles> {
        return NSFetchRequest<LastFiles>(entityName: "LastFiles")
    }
    @NSManaged public var created: String?
    @NSManaged public var mediaType: String?
    @NSManaged public var mimeType: String?
    @NSManaged public var modified: String?
    @NSManaged public var name: String?
    @NSManaged public var path: String?
    @NSManaged public var preview: String?
    @NSManaged public var size: Int64
    @NSManaged public var type: String?
}

extension LastFiles: Identifiable {}
