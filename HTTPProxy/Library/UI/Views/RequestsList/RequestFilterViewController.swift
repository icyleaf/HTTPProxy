import UIKit

class RequestFilterCell: UICollectionViewCell {
    @IBOutlet weak var roundedView: RoundedView!
    @IBOutlet weak var titleLabel: UILabel!
}

protocol RequestFilterViewControllerDelegate: class {
    func filterDidUpdateHeight(_ height: CGFloat)
    func filterSelected(_ filter: HTTPProxyFilter)
    func editFilter(_ filter: HTTPProxyFilter)
    func deleteFilter(_ filter: HTTPProxyFilter)
}

class RequestFilterViewController: UIViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var collectionViewHeight: NSLayoutConstraint!
    private var height: CGFloat = 0.0
    
    var filters: [HTTPProxyFilter] = []
    weak var delegate: RequestFilterViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewCenterLayout()
        layout.estimatedItemSize = CGSize(width: 100, height: 30)
        collectionView.collectionViewLayout = layout
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let collectionViewHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        if collectionViewHeight != height {
            height = collectionViewHeight
            print("new height \(height)")
            delegate?.filterDidUpdateHeight(height)
        }
    }

    func loadFilters(_ filters: [HTTPProxyFilter]) {
        self.filters = filters
        collectionView.reloadData()
    }
    
    private func filterSelected(_ filter: HTTPProxyFilter) {
        delegate?.filterSelected(filter)
        collectionView.reloadData()
    }
    
    private func editFilter(_ filter: HTTPProxyFilter) {
        delegate?.editFilter(filter)
        collectionView.reloadData()
    }
    
    private func deleteFilter(_ filter: HTTPProxyFilter) {
        delegate?.deleteFilter(filter)
        collectionView.reloadData()
    }
}

extension RequestFilterViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RequestFilterCell", for: indexPath) as! RequestFilterCell
        let filter = filters[indexPath.row]
        cell.titleLabel.text = filter.name
        cell.titleLabel.textColor = .white
        cell.roundedView.backgroundColor = HTTPProxyUI.colorScheme.selectedColor
        cell.contentView.alpha = filter.enabled ? 1 : 0.6
        return cell
    }
}

extension RequestFilterViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filter = filters[indexPath.row]
        filterSelected(filter)
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let filter = filters[indexPath.row]
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(title: "Edit") { _ in
                self.editFilter(filter)
            }
            let deleteAction = UIAction(title: "Delete", attributes: .destructive, handler: { _ in
                self.deleteFilter(filter)
            })
            return UIMenu(title: "Options", image: nil, identifier: nil, children: [editAction, deleteAction])
        }
        
        return configuration
    }
}
