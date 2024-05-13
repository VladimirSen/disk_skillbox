import Foundation

struct AllFilesModel: Decodable {
    var embedded: Embedded
    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
    }
}

struct Embedded: Decodable {
    var path: String?
    var items: [ItemList]
}
