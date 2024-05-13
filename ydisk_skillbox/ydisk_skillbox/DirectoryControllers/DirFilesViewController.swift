import UIKit

class DirViewController: AllFilesViewController {
    var name: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = name
    }
}
