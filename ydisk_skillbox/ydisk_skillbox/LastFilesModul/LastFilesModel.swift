import Foundation

struct MainList: Decodable {
    var items: [ItemList]
    var limit: Int64
}

struct ItemList: Decodable, Hashable {
    var name: String?
    var preview: String?
    var created: String?
    var modified: String?
    var mediaType: String?
    var path: String?
    var type: String?
    var mimeType: String?
    var size: Int64?
    
    enum CodingKeys: String, CodingKey {
        case name
        case preview
        case created
        case modified
        case mediaType = "media_type"
        case path
        case type
        case mimeType = "mime_type"
        case size
    }
}
