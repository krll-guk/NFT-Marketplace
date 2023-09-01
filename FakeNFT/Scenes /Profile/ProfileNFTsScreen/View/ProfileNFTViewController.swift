import UIKit

final class ProfileNFTViewController: UIViewController {
    private var viewModel: ProfileNFTViewModelProtocol

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.register(ProfileNFTTableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    init(_ viewModel: ProfileNFTViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()

        showLoader(true)
        viewModel.fetchProfileNFT()

        viewModel.profileNFTsObservable.bind { [weak self] _ in
            guard let self = self else { return }
            self.updateTable()
            self.viewModel.fetchProfileNFT()
            if self.viewModel.profile.nfts.count == self.viewModel.sorted.count {
                self.showLoader(false)
            }
        }

        viewModel.pickedSortTypeObservable.bind { [weak self] _ in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }

    private func setupView() {
        navigationItem.title = "sdjfkj"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(sort))

        view.backgroundColor = .Themed.white

        [tableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        setConstraints()
    }

    private func setConstraints() {
        NSLayoutConstraint.activate([
            // tableView
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }

    private func showLoader(_ isShow: Bool) {
        switch isShow {
        case true:
            UIBlockingProgressHUD.show()
        case false:
            UIBlockingProgressHUD.dismiss()
        }
    }

    private func updateTable() {
        tableView.performBatchUpdates {
            tableView.insertRows(at: [IndexPath(row: viewModel.insertIndex(), section: 0)], with: .middle)
        }
    }

    @objc
    private func sort() {
        viewModel.changeType(.byPrice)
    }
}

extension ProfileNFTViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sorted.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProfileNFTTableViewCell = tableView.dequeueReusableCell()
        cell.backgroundColor = .darkGray
        cell.cellViewModel = viewModel.getCellViewModel(at: indexPath)
        return cell
    }
}

extension ProfileNFTViewController: UITableViewDelegate {

}
