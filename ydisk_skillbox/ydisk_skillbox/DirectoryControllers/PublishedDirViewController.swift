import UIKit

final class PublishedDirViewController: DirViewController {
    override func createDetailViewController(view: UIView,
                                             dateString: String,
                                             textImageLabel: String,
                                             pathToFile: String,
                                             newPath: String? ) {
        let controller = FilesPreviewViewController.createFilesPreviewVC(view: view)
        controller.textDateLabel = String.transformDate(date: dateString)
        controller.textImageLabel = textImageLabel
        controller.pathToFile = pathToFile
        controller.newPath = newPath
        controller.hidesBottomBarWhenPushed = true
        controller.screenItems.editButton.isHidden = true
        controller.screenItems.shareButton.isHidden = true
        controller.screenItems.deleteButton.isHidden = true
        navigationController?.pushViewController(controller, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let model = viewModel?.contents[indexPath.row] else {return}
        let mediaType = model.mediaType
        let mimeType = model.mimeType
        switch model.type {
        case "file":
            if mediaType == "image" {
                createDetailViewController(view: FilesPreviewViewController.imageView,
                                           dateString: model.created ?? "",
                                           textImageLabel: model.name ?? "",
                                           pathToFile: model.path ?? "",
                                           newPath: path)
            } else if mimeType == "application/pdf"{
                createDetailViewController(view: FilesPreviewViewController.pdfView,
                                           dateString: model.created ?? "",
                                           textImageLabel: model.name ?? "",
                                           pathToFile: model.path ?? "",
                                           newPath: path)
            } else {
                createDetailViewController(view: FilesPreviewViewController.wkWebView,
                                           dateString: model.created ?? "",
                                           textImageLabel: model.name ?? "",
                                           pathToFile: model.path ?? "",
                                           newPath: path)
            }
        case "dir":
            if isOnInternet == true {
                let controller = PublishedDirViewController()
                controller.name = model.name
                controller.path = (model.path ?? "")
                navigationItem.backButtonTitle = ""
                self.navigationController?.pushViewController(controller, animated: false)
            } else {
                self.presentNoInternetDirAlert()
            }
        default:
            return
        }
    }
}
