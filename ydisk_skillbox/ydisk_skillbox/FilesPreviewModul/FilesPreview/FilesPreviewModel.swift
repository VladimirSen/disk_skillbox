import Foundation

struct FilesPreviewModel: Decodable {
    var file: String
    var name: String
    var publicUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case file
        case name
        case publicUrl = "public_url"
    }
}

struct FilesLinkModel: Codable {
    let href: String
}
