import Foundation

protocol ProfileViewControllerProtocol: AnyObject {
    func setupProfileData()
    var isOnInternet: Bool {get set}
}

protocol ProfileViewModelProtocol: AnyObject {
    var delegate: ProfileViewControllerProtocol? {get set}
    var data: ProfileModel? {get set}
    func uploadData()
}

final class ProfileViewModel: ProfileViewModelProtocol {
    weak var delegate: ProfileViewControllerProtocol?
    var data: ProfileModel?
    private var networkService: NetworkServiceProtocol? = NetworkService()
    
    func uploadData() {
        networkService?.requestProfileData { [weak self] (dataList, error) in
            DispatchQueue.main.async { [weak self] in
                guard let dataList = dataList else {
                    if error?.localizedDescription == Constants.Text.internetError {
                        self?.delegate?.isOnInternet = false
                        self?.delegate?.setupProfileData()
                    }
                    return
                }
                self?.data = dataList
                self?.delegate?.setupProfileData()
            }
        }
    }
}
