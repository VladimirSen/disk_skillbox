import Foundation

struct PublishedFilesModel: Decodable {
    var items: [ItemList]
    var limit: Int64
}
