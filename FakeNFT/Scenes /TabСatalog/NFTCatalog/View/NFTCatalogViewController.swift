import UIKit
import ProgressHUD

final class NFTCatalogViewController: UIViewController {
    
    // MARK: Private properties
    
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
        assignBindings()
        
        if viewModel.catalogModels.isEmpty {
            ProgressHUD.show()
        }
    }
    
    // MARK: Private functions
    
    @objc
    private func didTapSortButton() {
        let controller = UIAlertController(
            title: NSLocalizedString("", value: "Сортировка", comment: ""),
            message: nil,
            preferredStyle: .actionSheet
        )
        controller.addAction(
            UIAlertAction(
                title: NSLocalizedString("", value: "По названию", comment: ""),
                style: .default,
                handler: { [weak self] _ in
                    guard let self = self else {
                        return
                    }
                    self.viewModel.sortCatalogs(by: .title)
                }
            )
        )
        controller.addAction(
            UIAlertAction(
                title: NSLocalizedString("", value: "По количеству NFT", comment: ""),
                style: .default,
                handler: { [weak self] _ in
                    guard let self = self else {
                        return
                    }
                    self.viewModel.sortCatalogs(by: .count)
                }
            )
        )
        controller.addAction(
            UIAlertAction(
                title: NSLocalizedString("", value: "Закрыть", comment: ""),
                style: .cancel
            )
        )
        present(controller, animated: true)
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
        view.backgroundColor = .Themed.white
        
        view.addSubview(catalogTable)
        catalogTable.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            catalogTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            catalogTable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            catalogTable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            catalogTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func assignBindings() {
        viewModel.$catalogModels.bind { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                self.catalogTable.reloadData()
                ProgressHUD.dismiss()
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension NFTCatalogViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.catalogModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NFTCatalogTableViewCell = tableView.dequeueReusableCell()
        cell.catalogModel = viewModel.catalogModels[indexPath.row]
        return cell
    }
}

// MARK: - UITableViewDelegate

extension NFTCatalogViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let collectionController = NFTCollectionViewController(
            viewModel: NFTCollectionViewModel(
                collectionModel: NFTCollectionModel(from: viewModel.catalogModels[indexPath.row])
            )
        )
        navigationController?.pushViewController(collectionController, animated: true)
    }
}
