import UIKit

protocol HeadersListControllerDelegate: class {

    func didSelectItem(at index: Int)
}
    
class HeadersListController: NSObject {

    static let cellIdentifier = "RequestDetailsViewCellId"

    private var tableView: UITableView
    private var dataSource: HeadersListDataSource?
    
    weak var delegate: HeadersListControllerDelegate?
    
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()

        let nib = UINib(nibName: "RequestsListCell", bundle: HTTPProxyPresenter.bundle)
        tableView.register(nib, forCellReuseIdentifier: HeadersListController.cellIdentifier)

        UITableViewHeaderFooterView.appearance().tintColor = .clear
        UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self]).textColor = HTTPProxyPresenter.shared.colorScheme.primaryTextColor
    }
    
    func load(sections: [SearchableListSection]) {
        load(sections: sections, textToHighlight: nil)
    }
    
    func load(sections: [SearchableListSection], textToHighlight: String?) {
        DispatchQueue.main.async {
            self.dataSource = HeadersListDataSource(sections: sections, textToHighlight: textToHighlight)
            self.dataSource?.delegate = self.delegate
            self.tableView.dataSource = self.dataSource
            self.tableView.delegate = self.dataSource
            self.tableView.reloadData()
        }
    }
}

class HeadersListDataSource: NSObject {

    var sections: [SearchableListSection] = []
    let textToHighlight: String?
    weak var delegate: HeadersListControllerDelegate?
    
    init(sections: [SearchableListSection], textToHighlight: String?) {
        self.sections = sections
        self.textToHighlight = textToHighlight
        super.init()
    }
}

extension HeadersListDataSource: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HeadersListController.cellIdentifier, for: indexPath) as? RequestsListCell else {
            fatalError()
        }
        
        cell.configure(with: sections[indexPath.section].items[indexPath.row])
        if let text = textToHighlight {
            cell.emphasize(text: text)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let title = sections[section].title {
            return title + " (\(sections[section].items.count))"
        }
        return nil
    }
}

extension HeadersListDataSource: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectItem(at: indexPath.row)
    }
}
