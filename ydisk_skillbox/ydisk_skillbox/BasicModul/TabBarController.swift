import UIKit

final class TabBarController: UITabBarController {
    private enum TabBarItem: Int {
        case profile
        case lastFiles
        case allFiles
        var iconName: String {
            switch self {
            case .profile:
                return "person"
            case .lastFiles:
                return "doc"
            case .allFiles:
                return "archivebox"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTabBar()
        navigationItem.hidesBackButton = true
    }
    
    private func setupTabBar() {
        let dataSource: [TabBarItem] = [.profile, .lastFiles, .allFiles]
        self.viewControllers = dataSource.map {
            switch $0 {
            case .profile:
                let profileViewController = ProfileViewController()
                return self.wrappedInNavigationController(with: profileViewController, title: "")
            case .lastFiles:
                let lastFilesViewController = LastFilesViewController()
                return self.wrappedInNavigationController(with: lastFilesViewController, title: "")
            case .allFiles:
                let allFilesViewController = AllFilesViewController()
                return self.wrappedInNavigationController(with: allFilesViewController, title: "")
            }
        }
        self.viewControllers?.enumerated().forEach {
            $1.tabBarItem.image = UIImage(systemName: dataSource[$0].iconName)
            $1.tabBarItem.imageInsets = UIEdgeInsets(top: 5,
                                                     left: .zero,
                                                     bottom: -5,
                                                     right: .zero)
        }
    }
    
    private func wrappedInNavigationController(with: UIViewController, title: Any?) -> UINavigationController {
        return UINavigationController(rootViewController: with)
    }
}
