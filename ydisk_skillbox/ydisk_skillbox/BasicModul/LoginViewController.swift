import UIKit
import WebKit

final class LoginViewController: UIViewController {
    private var webView = WKWebView()
    private let yandexId = Constants.Text.yandexId
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
    }
    
    override func loadView() {
        webView.navigationDelegate = self
        view = webView
    }
    
    private func setupWebView() {
        navigationItem.hidesBackButton = true
        DispatchQueue.main.async {
            URLCache.shared.removeAllCachedResponses()
            HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
            WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) {records in
                records.forEach { record in
                    WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes,
                                                            for: [record],
                                                            completionHandler: {})
                }
            }
        }
        guard let url = URL(string: "\(Constants.Text.loginUrl)\(yandexId)") else {return}
            webView.load(URLRequest(url: url))
            webView.allowsBackForwardNavigationGestures = true
    }
}

extension LoginViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping ((WKNavigationActionPolicy) -> Void)) {
        if let url = navigationAction.request.url {
            if url.absoluteString.hasPrefix(Constants.Text.loginUrlAbString) {
                let yTok = url.absoluteString.components(separatedBy: "token=").last?.components(separatedBy: "&").first
                guard let token = yTok else {return}
                UserDefaults.standard.token = token
                let viewController = TabBarController()
                viewController.modalPresentationStyle = .fullScreen
                self.present(viewController, animated: true)
            }
       }
        decisionHandler(.allow)
    }
}
