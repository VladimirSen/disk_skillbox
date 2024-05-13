import Foundation
import CoreData

extension AllFiles {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AllFiles> {
        return NSFetchRequest<AllFiles>(entityName: "AllFiles")
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

extension AllFiles: Identifiable {}
