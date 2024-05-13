import Foundation

struct ProfileModel: Decodable {
    var totalSpace: Int
    var usedSpace: Int
    
    enum CodingKeys: String, CodingKey {
        case totalSpace = "total_space"
        case usedSpace = "used_space"
    }
}
