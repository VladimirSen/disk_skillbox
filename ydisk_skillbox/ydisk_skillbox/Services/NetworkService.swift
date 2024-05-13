import UIKit

protocol NetworkServiceProtocol: AnyObject {
    func requestProfileData(completion: @escaping (ProfileModel?, Error?) -> Void)
    func requestPublishedFiles(token: String, completion: @escaping (PublishedFilesModel?, Error?) -> Void)
    func requestDeletePublishedFile(_ pathToFile: String)
    func requestLastFiles(token: String, completion: @escaping (MainList?, Error?) -> Void)
    func requestAllFiles(token: String, path: String?, completion: @escaping (AllFilesModel?, Error?) -> Void)
    func requestPreveiwFile(_ pathToFile: String, completion: @escaping (FilesPreviewModel?, Error?) -> Void)
    func requestEditFile(from pathToFile: String?, to toPath: String)
    func requestDeleteFile(_ pathToFile: String)
    func requestLoadLink(_ pathToFile: String, completion: @escaping (FilesPreviewModel?) -> Void)
    func requestShareFile(_ pathToFile: String, completion: @escaping (FilesLinkModel?) -> Void)
}

final class NetworkService: NetworkServiceProtocol {
    static func loadImage(url: String, token: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: url) else {return}
        var request = URLRequest(url: url)
        request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else { return }
            DispatchQueue.main.async {
                completion(UIImage(data: data))
            }
        }
        task.resume()
    }
    
    func requestProfileData(completion: @escaping (ProfileModel?, Error?) -> Void) {
        let urlComponents = URLComponents(string: Constants.Text.yaDisk)
        guard let url = urlComponents?.url else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("OAuth \(UserDefaults.standard.string(forKey: "token") ?? "")",
                            forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            DispatchQueue.main.async {
                guard let error = error else {return}
                completion(nil, error)
                return
            }
            if response != nil {
                guard let data = data else { return }
                do {
                    let dataList = try JSONDecoder().decode(ProfileModel.self, from: data)
                    completion(dataList, nil)
                } catch {
                    AlertHelper.showAlert(withMessage: "\(error)")
                }
            }
        }
        task.resume()
    }
    
    func requestPublishedFiles(token: String, completion: @escaping (PublishedFilesModel?, Error?) -> Void) {
        var urlComponents = URLComponents(string: "\(Constants.Text.yaDiskResourses)/public")
        urlComponents?.queryItems = [URLQueryItem(name: "limit", value: "50"),
                                     URLQueryItem(name: "preview_size", value: "60x60"),
                                     URLQueryItem(name: "preview_crop", value: "true")]
        guard let url = urlComponents?.url else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            DispatchQueue.main.async {
                guard let error = error else {return}
                completion(nil, error)
                return
            }
            if response != nil {
                guard let data = data else { return }
                do {
                    let dataList = try JSONDecoder().decode(PublishedFilesModel.self, from: data)
                    completion(dataList, nil)
                } catch {
                    AlertHelper.showAlert(withMessage: "\(error)")
                }
            }
        }
        task.resume()
    }
    
    func requestDeletePublishedFile(_ pathToFile: String) {
        var urlComponents = URLComponents(string: "\(Constants.Text.yaDiskResourses)/unpublish")
        urlComponents?.queryItems = [URLQueryItem(name: "path", value: pathToFile)]
        guard let url = urlComponents?.url else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("OAuth \(UserDefaults.standard.string(forKey: "token") ?? "")",
                            forHTTPHeaderField: "Authorization")
        urlRequest.httpMethod = "PUT"
        let task = URLSession.shared.dataTask(with: urlRequest)
        task.resume()
    }
    
    func requestLastFiles(token: String, completion: @escaping (MainList?, Error?) -> Void) {
        var urlComponents = URLComponents(string: "\(Constants.Text.yaDiskResourses)/last-uploaded")
        urlComponents?.queryItems = [URLQueryItem(name: "limit", value: "50"),
                                     URLQueryItem(name: "preview_size", value: "60x60"),
                                     URLQueryItem(name: "preview_crop", value: "true")]
        guard let url = urlComponents?.url else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            DispatchQueue.main.async {
                guard let error = error else {return}
                completion(nil, error)
                return
            }
            if response != nil {
                guard let data = data else { return }
                do {
                    let dataList = try JSONDecoder().decode(MainList.self, from: data)
                    completion(dataList, nil)
                } catch {
                    AlertHelper.showAlert(withMessage: "\(error)")
                }
            }
        }
        task.resume()
    }
    
    func requestAllFiles(token: String, path: String?, completion: @escaping (AllFilesModel?, Error?) -> Void) {
        var urlComponents = URLComponents(string: Constants.Text.yaDiskResourses)
        urlComponents?.queryItems = [URLQueryItem(name: "path", value: path != nil ? path : "disk:/"),
                                     URLQueryItem(name: "limit", value: "1000"),
                                     URLQueryItem(name: "preview_size", value: "60x60"),
                                     URLQueryItem(name: "preview_crop", value: "true"),
                                     URLQueryItem(name: "sort", value: "-created")]
        guard let url = urlComponents?.url else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            DispatchQueue.main.async {
                    guard let error = error else {return}
                        completion(nil, error)
                    return
                }
            if response != nil {
                guard let data = data else { return }
                do {
                    let dataList = try JSONDecoder().decode(AllFilesModel.self, from: data)
                    completion(dataList, nil)
                } catch {
                    AlertHelper.showAlert(withMessage: "\(error)")
                }
            }
        }
        task.resume()
    }
    
    func requestPreveiwFile(_ pathToFile: String, completion: @escaping (FilesPreviewModel?, Error?) -> Void) {
        var urlComponents = URLComponents(string: Constants.Text.yaDiskResourses)
        urlComponents?.queryItems = [URLQueryItem(name: "path", value: pathToFile)]
        guard let url = urlComponents?.url else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("OAuth \(UserDefaults.standard.string(forKey: "token") ?? "")",
                            forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            DispatchQueue.main.async {
                    guard let error = error else {return}
                        completion(nil, error)
                    return
                }
            if response != nil {
                guard let data = data else { return }
                do {
                    let dataList = try JSONDecoder().decode(FilesPreviewModel.self, from: data)
                    completion(dataList, nil)
                } catch {
                    AlertHelper.showAlert(withMessage: "\(error)")
                }
            }
        }
        task.resume()
    }
    
    func requestEditFile(from pathToFile: String?, to toPath: String) {
        var urlComponents = URLComponents(string: "\(Constants.Text.yaDiskResourses)/move")
        urlComponents?.queryItems = [URLQueryItem(name: "from", value: pathToFile),
                                     URLQueryItem(name: "path", value: toPath),
                                     URLQueryItem(name: "overwrite", value: "true")]
        guard let url = urlComponents?.url else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("OAuth \(UserDefaults.standard.string(forKey: "token") ?? "")",
                            forHTTPHeaderField: "Authorization")
        urlRequest.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: urlRequest)
        task.resume()
    }
    
    func requestDeleteFile(_ pathToFile: String) {
        var urlComponents = URLComponents(string: Constants.Text.yaDiskResourses)
        urlComponents?.queryItems = [URLQueryItem(name: "path", value: pathToFile),
                                     URLQueryItem(name: "permanently", value: "true")]
        guard let url = urlComponents?.url else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("OAuth \(UserDefaults.standard.string(forKey: "token") ?? "")",
                            forHTTPHeaderField: "Authorization")
        urlRequest.httpMethod = "DELETE"
        let task = URLSession.shared.dataTask(with: urlRequest)
        task.resume()
    }
    
    func requestLoadLink(_ pathToFile: String, completion: @escaping (FilesPreviewModel?) -> Void) {
        var urlComponents = URLComponents(string: Constants.Text.yaDiskResourses)
        urlComponents?.queryItems = [URLQueryItem(name: "path", value: pathToFile)]
        guard let url = urlComponents?.url else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("OAuth \(UserDefaults.standard.string(forKey: "token") ?? "")",
                            forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            DispatchQueue.main.async {
                guard let data = data else { return }
                do {
                    let dataList = try JSONDecoder().decode(FilesPreviewModel.self, from: data)
                    completion(dataList)
                } catch {
                    AlertHelper.showAlert(withMessage: "\(error)")
                }
            }
        }
        task.resume()
    }   
    
    func requestShareFile(_ pathToFile: String, completion: @escaping (FilesLinkModel?) -> Void) {
        var urlComponents = URLComponents(string: "\(Constants.Text.yaDiskResourses)/publish")
        urlComponents?.queryItems = [URLQueryItem(name: "path", value: pathToFile)]
        guard let url = urlComponents?.url else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("OAuth \(UserDefaults.standard.string(forKey: "token") ?? "")",
                            forHTTPHeaderField: "Authorization")
        urlRequest.httpMethod = "PUT"
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            DispatchQueue.main.async {
                guard let data = data else { return }
                do {
                    let dataList = try JSONDecoder().decode(FilesLinkModel.self, from: data)
                    completion(dataList)
                } catch {
                    AlertHelper.showAlert(withMessage: "\(error)")
                }
            }
        }
        task.resume()
    }
}
