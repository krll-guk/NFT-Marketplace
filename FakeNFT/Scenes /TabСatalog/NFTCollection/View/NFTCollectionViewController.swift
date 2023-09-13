import UIKit
import Kingfisher
import ProgressHUD

final class NFTCollectionViewController: UIViewController {
    
    // MARK: Private properties
    
    private let coverImage: UIImageView = {
        let image = UIImageView()
        
        image.layer.masksToBounds = true
        image.layer.cornerRadius = 12
        image.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        image.heightAnchor.constraint(equalToConstant: 310).isActive = true
        return image
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = .Themed.black
        label.font = .Bold.size22
        
        return label
    }()
    
    private lazy var authorButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.setTitleColor(.Universal.blue, for: .normal)
        button.titleLabel?.font = .Regular.size15
        
        button.addTarget(self, action: #selector(didTapAuthorButton), for: .touchUpInside)
        return button
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = .Themed.black
        label.font = .Regular.size13
        label.numberOfLines = 0
        
        return label
    }()
    
    private let nftCollection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        collection.register(NFTCollectionViewCell.self)
        collection.isScrollEnabled = false
        
        return collection
    }()
    
    private let widthParameters = CollectionWidthParameters(cellsNumber: 3, leftInset: 16, rightInset: 16, interCellSpacing: 10)
    private let scrollView = UIScrollView()
    private let viewModel: NFTCollectionViewModel
    
    private lazy var alertHelper = AlertHelper(delegate: self)
    
    // MARK: Initializers
    
    init(viewModel: NFTCollectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Override functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nftCollection.dataSource = self
        nftCollection.delegate = self
        
        setupNavigationBar()
        makeViewLayout()
        assignBindings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if viewModel.nftModels.isEmpty {
            viewModel.loadData()
            ProgressHUD.show()
        }
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        var insets = view.safeAreaInsets
        insets.top = 0 // ignore only top safe area inset
        scrollView.contentInset = insets
    }
    
    // MARK: Private functions
    
    @objc
    private func didTapAuthorButton() {
        guard let userModel = viewModel.userModel else {
            return
        }
        let authorController = AuthorDetailsViewController()
        authorController.websiteURL = URL(string: userModel.website)
        navigationController?.pushViewController(authorController, animated: true)
    }
    
    private func setupNavigationBar() {
        guard let bar = navigationController?.navigationBar else {
            return
        }
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        
        bar.standardAppearance = appearance
        bar.topItem?.backBarButtonItem = UIBarButtonItem()
        bar.tintColor = .Themed.black
    }
    
    private func makeViewLayout() {
        view.backgroundColor = .Themed.white
        
        let mainStack = makeMainStack()
        scrollView.contentInsetAdjustmentBehavior = .never // ignore safe area insets on all edges
        
        view.addSubview(scrollView)
        scrollView.addSubview(mainStack)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            scrollView.contentLayoutGuide.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollView.contentLayoutGuide.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollView.contentLayoutGuide.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            
            mainStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
        ])
    }
    
    private func makeMainStack() -> UIStackView {
        let mainStack = UIStackView()
        let authorStack = makeAuthorStack()
        
        mainStack.axis = .vertical
        mainStack.alignment = .center
        
        mainStack.addArrangedSubview(coverImage)
        mainStack.addArrangedSubview(titleLabel)
        mainStack.addArrangedSubview(authorStack)
        mainStack.addArrangedSubview(descriptionLabel)
        mainStack.addArrangedSubview(nftCollection)
        
        mainStack.setCustomSpacing(16, after: coverImage)
        mainStack.setCustomSpacing(8, after: titleLabel)
        
        NSLayoutConstraint.activate([
            coverImage.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor),
            coverImage.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor, constant: -16),
            
            authorStack.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor, constant: 16),
            authorStack.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor, constant: -16),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor, constant: -16),
            
            nftCollection.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor),
            nftCollection.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor),
        ])
        return mainStack
    }
    
    private func makeAuthorStack() -> UIStackView {
        let label = UILabel()
        label.text = NSLocalizedString("", value: "Автор коллекции:", comment: "")
        label.textColor = .Themed.black
        label.font = .Regular.size13
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(authorButton)
        stack.addArrangedSubview(UIView())
        
        return stack
    }
    
    private func assignBindings() {
        viewModel.$userModel.bind { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                self.coverImage.kf.indicatorType = .activity
                self.coverImage.kf.setImage(with: URL(string: self.viewModel.collectionModel.coverLink.percentEncoded))
                
                self.titleLabel.text = self.viewModel.collectionModel.title
                self.authorButton.setTitle(self.viewModel.userModel?.name, for: .normal)
                self.descriptionLabel.text = self.viewModel.collectionModel.description
            }
        }
        viewModel.$nftModels.bind { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                self.nftCollection.reloadData()
                let contentHeight = self.nftCollection.collectionViewLayout.collectionViewContentSize.height
                self.nftCollection.heightAnchor.constraint(equalToConstant: contentHeight).isActive = true
                ProgressHUD.dismiss()
            }
        }
        viewModel.$orderModel.bind { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                self.nftCollection.reloadData()
                ProgressHUD.dismiss()
            }
        }
        viewModel.$profileModel.bind { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                self.nftCollection.reloadData()
                ProgressHUD.dismiss()
            }
        }
        viewModel.$isNetworkError.bind { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                self.makeRetryAlertController()
                ProgressHUD.dismiss()
            }
        }
    }
    
    private func makeRetryAlertController() {
        let retryAlertModel = alertHelper.makeRetryAlertModel { [weak self] _ in
            guard let self = self else {
                return
            }
            self.viewModel.loadData()
        }
        alertHelper.makeAlertController(from: retryAlertModel)
    }
}

// MARK: - UICollectionViewDataSource

extension NFTCollectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.collectionModel.nftIDs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: NFTCollectionViewCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        
        cell.delegate = self
        cell.nftModel = viewModel.nftModelForCell(at: indexPath)
        cell.orderModel = viewModel.orderModel
        cell.profileModel = viewModel.profileModel
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension NFTCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width - widthParameters.widthInsets
        let cellWidth =  availableWidth / CGFloat(widthParameters.cellsNumber)
        return CGSize(width: cellWidth, height: 192)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: widthParameters.leftInset, bottom: 20, right: widthParameters.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

// MARK: - NFTCollectionViewCellDelegate

extension NFTCollectionViewController: NFTCollectionViewCellDelegate {
    
    func didTapCart(in cell: NFTCollectionViewCell) {
        guard let indexPath = nftCollection.indexPath(for: cell) else {
            return
        }
        ProgressHUD.show(interaction: false)
        viewModel.toggleCartForNFT(at: indexPath)
    }
    
    func didTapLike(in cell: NFTCollectionViewCell) {
        guard let indexPath = nftCollection.indexPath(for: cell) else {
            return
        }
        ProgressHUD.show(interaction: false)
        viewModel.toggleLikeForNFT(at: indexPath)
    }
}

// MARK: - AlertHelperDelegate

extension NFTCollectionViewController: AlertHelperDelegate {
    
    func didMakeAlert(controller: UIAlertController) {
        present(controller, animated: true)
    }
}
