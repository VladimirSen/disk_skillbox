import Foundation

enum Constants {
    enum Text {
        static let yaDisk = "https://cloud-api.yandex.net/v1/disk/"
        static let yaDiskResourses = "\(yaDisk)resources"
        static let yandexId = "token&client_id=3e80c71fd96d4cc2bcef5abaf1b3b017"
        static let loginUrl = "https://oauth.yandex.by/authorize?response_type="
        static let loginUrlAbString = "https://oauth.yandex.ru/verification_code#access_token="
        static let fatalError = "init(coder:) has not been implemented"
        static let onboarding1 = "Теперь все ваши документы в одном месте".localized()
        static let onboardind2 = "Доступ к файлам без интернета".localized()
        static let onboardind3 = "Делитесь Вашими файлами с другими".localized()
        static let logout = "Вы уверены, что хотите выйти? Все локальные данные будут удалены!".localized()
        static let noInt = "Нет подключения к интернету!\nОтображаются файлы последней загрузки.".localized()
        static let noDir = "Нет подключения к интернету!\nПодключитесь, чтобы просмотреть cодержимое папки.".localized()
        static let noIntFile = "Нет подключения к интернету!\nПодключитесь, чтобы просмотреть файл.".localized()
        static let noFiles = "Данная папка не содержит файлов.".localized()
        static let internetError = "Вероятно, соединение с интернетом прервано.".localized()
    }
}
