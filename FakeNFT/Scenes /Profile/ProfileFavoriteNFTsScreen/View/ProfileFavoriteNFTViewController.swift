import UIKit

final class ProfileFavoriteNFTViewController: UIViewController {
    var completionHandler: ((Profile) -> Void)?

    private let viewModel: ProfileFavoriteNFTViewModelProtocol
    private let alert: AlertProtocol

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
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.register(ProfileFavoriteNFTCollectionViewCell.self)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    private lazy var placeholder: UILabel = {
        let label = UILabel()
        label.font = .Bold.size17
        label.textColor = .Themed.black
        label.text = .ProfileFavoriteNFT.placeholder
        return label
    }()

    init(_ viewModel: ProfileFavoriteNFTViewModelProtocol) {
        self.viewModel = viewModel
        self.alert = Alert()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()

        viewModel.showAlertObservable.bind { [weak self] _ in
            guard let self = self else { return }
            switch self.viewModel.alertType {
            case .updateError:
                self.alert.present(
                    title: .ProfileErrorAlert.title,
                    message: .ProfileErrorAlert.updateMessage,
                    actions: .cancel(handler: {
                        self.returnWithoutChanges()
                    }), .retry(handler: {
                        self.viewModel.updateProfileLikes()
                    }),
                    from: self
                )
            case .loadError:
                self.alert.present(
                    title: .ProfileErrorAlert.title,
                    message: .ProfileErrorAlert.loadMessage,
                    actions: .cancel(handler: {
                        self.returnWithoutChanges()
                    }),
                    .retry(handler: {
                        self.viewModel.fetch()
                    }),
                    from: self
                )
            }
        }

        viewModel.hidePlaceholderObservable.bind { [weak self] _ in
            guard let self = self else { return }
            self.hidePlaceholder(self.viewModel.hidePlaceholder)
        }

        viewModel.profileNFTsObservable.bind { [weak self] _ in
            guard let self = self else { return }
            self.updateCollection()
        }

        viewModel.profileObservable.bind { [weak self] profile in
            guard let self = self else { return }
            self.completionHandler?(profile)
            self.navigationController?.popToRootViewController(animated: true)
        }
    }

    private func setupView() {
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = backButton
        navigationItem.titleView = titleView

        view.backgroundColor = .Themed.white

        [collectionView, placeholder].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        setConstraints()
        hidePlaceholder(viewModel.hidePlaceholder)
    }

    private func setConstraints() {
        NSLayoutConstraint.activate([
            // tableView
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            // placeholder
            placeholder.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    private func hidePlaceholder(_ isHide: Bool) {
        if isHide {
            collectionView.isHidden = false
            placeholder.isHidden = true
            titleView.text = .ProfileTable.myLikes
        } else {
            collectionView.isHidden = true
            placeholder.isHidden = false
            titleView.text = ""
        }
    }

    private func updateCollection() {
        collectionView.performBatchUpdates {
            collectionView.insertItems(at: [IndexPath(row: viewModel.insertIndex(), section: 0)])
        }
    }

    @objc
    private func backButtonTapped() {
        if viewModel.syncLikes() {
            returnWithoutChanges()
        }
    }

    private func returnWithoutChanges() {
        completionHandler?(viewModel.profile)
        navigationController?.popToRootViewController(animated: true)
    }
}

extension ProfileFavoriteNFTViewController: ProfileFavoriteNFTCollectionViewCellDelegate {
    func heartTapped(_ cell: ProfileFavoriteNFTCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        viewModel.checkLikes(at: indexPath)
        collectionView.deleteItems(at: [indexPath])
    }
}

extension ProfileFavoriteNFTViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.newProfileFavoriteNFTs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ProfileFavoriteNFTCollectionViewCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.cellViewModel = viewModel.getCellViewModel(at: indexPath)
        cell.delegate = self
        return cell
    }
}

extension ProfileFavoriteNFTViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 7 - 16 - 16) / 2, height: 80)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
    }
}
