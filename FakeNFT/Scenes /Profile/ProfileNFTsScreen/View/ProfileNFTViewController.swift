import UIKit

final class ProfileNFTViewController: UIViewController {
    private var viewModel: ProfileNFTViewModelProtocol

    private lazy var sortButton: UIBarButtonItem = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 42, height: 42)
        button.setImage(.NavigationBar.sort, for: .normal)
        button.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
        button.tintColor = .Themed.black
        let barButton = UIBarButtonItem(customView: button)
        return barButton
    }()

    private lazy var backButton: UIBarButtonItem = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        button.setImage(.NavigationBar.backward, for: .normal)
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        button.tintColor = .Themed.black
        let barButton = UIBarButtonItem(customView: button)
        return barButton
    }()

    private lazy var titleView: UILabel = {
        let label = UILabel()
        label.font = .Bold.size17
        label.textColor = .Themed.black
        label.text = .ProfileTable.myNFTs
        return label
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .Themed.white
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        tableView.register(ProfileNFTTableViewCell.self)
        tableView.isHidden = true
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()

    private lazy var placeholder: UILabel = {
        let label = UILabel()
        label.font = .Bold.size17
        label.textColor = .Themed.black
        label.text = .ProfileNFT.placeholder
        return label
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

        viewModel.profileNFTsObservable.bind { [weak self] _ in
            guard let self = self else { return }
            self.updateTable()
        }

        viewModel.pickedSortTypeObservable.bind { [weak self] _ in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }

    private func setupView() {
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = backButton

        view.backgroundColor = .Themed.white

        [tableView, placeholder].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        setConstraints()
        hidePlaceholder(viewModel.hidePlaceholder)
    }

    private func setConstraints() {
        NSLayoutConstraint.activate([
            // tableView
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            // placeholder
            placeholder.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    private func hidePlaceholder(_ isHide: Bool) {
        guard isHide else { return }
        tableView.isHidden = false
        placeholder.isHidden = true
        navigationItem.rightBarButtonItem = sortButton
        navigationItem.titleView = titleView
    }

    private func updateTable() {
        tableView.performBatchUpdates {
            tableView.insertRows(at: [IndexPath(row: viewModel.insertIndex(), section: 0)], with: .middle)
        }
    }

    private func showAlert() {
        let alert = UIAlertController(
            title: .ProfileNFTSortAlert.title,
            message: nil,
            preferredStyle: .actionSheet
        )

        let byPrice = UIAlertAction(title: .ProfileNFTSortAlert.byPrice, style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.changeType(.byPrice)
        }

        let byRating = UIAlertAction(title: .ProfileNFTSortAlert.byRating, style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.changeType(.byRating)
        }

        let byName = UIAlertAction(title: .ProfileNFTSortAlert.byName, style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.changeType(.byName)
        }

        let cancel = UIAlertAction(title: .ProfileNFTSortAlert.cancel, style: .cancel)

        alert.addAction(byPrice)
        alert.addAction(byRating)
        alert.addAction(byName)
        alert.addAction(cancel)

        present(alert, animated: true)
    }

    @objc
    private func sortButtonTapped() {
        showAlert()
    }

    @objc
    private func backButtonTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
}

extension ProfileNFTViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sorted.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProfileNFTTableViewCell = tableView.dequeueReusableCell()
        cell.cellViewModel = viewModel.getCellViewModel(at: indexPath)
        return cell
    }
}

extension ProfileNFTViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}
