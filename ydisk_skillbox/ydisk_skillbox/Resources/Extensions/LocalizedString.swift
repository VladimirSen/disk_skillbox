import Foundation

extension String {
    func localized() -> String {
        NSLocalizedString(self, comment: self)
    }
    
    static func transformDate(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "dd.MM.yy HH:mm"
        let dateStr = dateFormatter.string(from: date ?? Date())
        return dateStr
    }
}
