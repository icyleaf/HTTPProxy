import UIKit

class RequestFilterCell: UICollectionViewCell {

    @IBOutlet weak var roundedView: RoundedView!
    @IBOutlet weak var titleLabel: UILabel!
}

protocol RequestFilterViewControllerDelegate: class {
    func filterSelected(_ filter: HTTPProxyFilter)
}

class RequestFilterViewController: UIViewController {

    @IBOutlet private weak var collectionView: UICollectionView!
    var filters: [HTTPProxyFilter] = []
    weak var delegate: RequestFilterViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func filterSelected(_ filter: HTTPProxyFilter) {
        delegate?.filterSelected(filter)
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
}
