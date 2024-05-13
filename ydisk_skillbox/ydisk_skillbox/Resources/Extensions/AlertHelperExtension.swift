import UIKit

extension UIViewController {
    static func getTopViewController(completion: @escaping (UIViewController?) -> Void) {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
                completion(nil)
                return
            }
            var topViewController = rootViewController
            while let presentedViewController = topViewController.presentedViewController {
                topViewController = presentedViewController
            }
            completion(topViewController)
        }
    }
}
