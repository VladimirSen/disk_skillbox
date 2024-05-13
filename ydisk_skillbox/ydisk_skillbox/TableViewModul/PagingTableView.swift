import UIKit

protocol PagingTableViewProtocol: AnyObject {
    func didPaginate(_ tableView: PagingTableView, to page: Int)
    func paginate(_ tableView: PagingTableView, to page: Int)
}

final class PagingTableView: UITableView {
    var pagingDelegate: PagingTableViewProtocol? {
        didSet {
            pagingDelegate?.paginate(self, to: page)
        }
    }
    var isLoading: Bool = false {
        didSet {
            isLoading ? showLoading() : hideLoading()
        }
    }
    private lazy var loadingView: UIView = {
        let view = UIView(frame: CGRect(x: 0,
                                        y: 0,
                                        width: frame.width,
                                        height: 50))
        return view
    }()
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.color = UIColor.gray
        activityIndicator.style = .medium
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    private var page: Int = 0
    private var currentPage: Int = 0
    private var previousItemCount: Int = 0
    
    public override func dequeueReusableCell(withIdentifier identifier: String,
                                             for indexPath: IndexPath) -> UITableViewCell {
        paginate(self, forIndexAt: indexPath)
        return super.dequeueReusableCell(withIdentifier: identifier,
                                         for: indexPath)
    }
    
    private func reset() {
        page = 0
        previousItemCount = 0
        pagingDelegate?.paginate(self, to: page)
    }
    
    private func paginate(_ tableView: PagingTableView, forIndexAt indexPath: IndexPath) {
        let itemCount = tableView.dataSource?.tableView(tableView, numberOfRowsInSection: indexPath.section) ?? 0
        guard indexPath.row == itemCount - 1 else { return }
        guard previousItemCount != itemCount else { return }
        page += 1
        previousItemCount = itemCount
        pagingDelegate?.paginate(self, to: page)
    }
    
    private func showLoading() {
        loadingView.addSubview(activityIndicator)
        centerIndicator()
        activityIndicator.startAnimating()
        tableFooterView = loadingView
    }
    
    private func hideLoading() {
        reloadData()
        pagingDelegate?.didPaginate(self, to: page)
        tableFooterView = nil
    }
    
    private func centerIndicator() {
        let xCenterConstraint = NSLayoutConstraint(item: loadingView,
                                                   attribute: .centerX,
                                                   relatedBy: .equal,
                                                   toItem: activityIndicator,
                                                   attribute: .centerX,
                                                   multiplier: 1,
                                                   constant: 0
        )
        loadingView.addConstraint(xCenterConstraint)
        let yCenterConstraint = NSLayoutConstraint(item: loadingView,
                                                   attribute: .centerY,
                                                   relatedBy: .equal,
                                                   toItem: activityIndicator,
                                                   attribute: .centerY,
                                                   multiplier: 1,
                                                   constant: 0
        )
        loadingView.addConstraint(yCenterConstraint)
    }
}
