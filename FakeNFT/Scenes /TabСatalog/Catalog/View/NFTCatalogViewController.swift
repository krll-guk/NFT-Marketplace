import UIKit

final class NFTCatalogViewController: UIViewController {
    
    private let catalogTable: UITableView = {
        let table = UITableView(frame: .zero)
        
        table.register(NFTCatalogTableViewCell.self)
        table.separatorStyle = .none
        
        table.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        return table
    }()
    
    private let viewModel = NFTCatalogViewModel()
    
    // MARK: Override functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        catalogTable.dataSource = self
        catalogTable.delegate = self
        
        setupNavigationBar()
        makeViewLayout()
        
        viewModel.$catalogList.bind { [weak self] _ in
            guard let self = self else {
                return
            }
            self.catalogTable.reloadData()
        }
    }
    
    // MARK: Private functions
    
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

// MARK: - UITableViewDataSource

extension NFTCatalogViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.catalogList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NFTCatalogTableViewCell = tableView.dequeueReusableCell()
        cell.catalogModel = viewModel.catalogList[indexPath.row]
        return cell
    }
}

// MARK: - UITableViewDelegate

extension NFTCatalogViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let collectionController = NFTCollectionViewController(
            viewModel: NFTCollectionViewModel(
                collectionID: viewModel.catalogList[indexPath.row].id
            )
        )
        navigationController?.pushViewController(collectionController, animated: true)
    }
}
