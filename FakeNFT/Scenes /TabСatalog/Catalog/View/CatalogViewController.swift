import UIKit

final class CatalogViewController: UIViewController {
    
    private let catalogTable: UITableView = {
        let table = UITableView(frame: .zero)
        
        table.register(CatalogTableViewCell.self)
        table.separatorStyle = .none
        table.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        table.allowsSelection = false
        
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        catalogTable.dataSource = self
        
        setupNavigationBar()
        makeViewLayout()
    }
    
    @objc
    private func didTapSortButton() {
    }
    
    private func setupNavigationBar() {
        guard let bar = navigationController?.navigationBar else {
            return
        }
        let sortButton = UIBarButtonItem(
            image: .NavigationBar.sort,
            style: .plain,
            target: self,
            action: #selector(didTapSortButton)
        )
        bar.topItem?.setRightBarButton(sortButton, animated: false)
        bar.tintColor = .Themed.black
    }
    
    private func makeViewLayout() {
        view.addSubview(catalogTable)
        catalogTable.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            catalogTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            catalogTable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            catalogTable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            catalogTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

extension CatalogViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CatalogTableViewCell = tableView.dequeueReusableCell()
        cell.configure(cover: UIImage(named: "TestCoverCell"), caption: "Test (\(indexPath.row))")
        return cell
    }
}
