//
//  UserViewScreenViewController.swift
//  FakeNFT
//
//  Created by Igor Ignatov on 28.08.2023.
//

import UIKit
import Kingfisher
import SafariServices

final class UserViewScreenViewController: UIViewController {
    private var viewModel: UserViewScreenViewModel!
    private let userId: String

    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().tintColor = UIColor.Themed.black
        view.tintColor = UIColor.Themed.black

        let model = UserVIewScreenModel()
        viewModel = UserViewScreenViewModel(model: model)
        viewModel.onChange = { [weak self] in
            self?.configure()
        }
        viewModel.onError = { [weak self] error, retryAction in
            let alert = UIAlertController(title: "Ошибка при загрузке данных пользователя", message: error.localizedDescription, preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "Попробовать снова", style: .default) { _ in
                   retryAction()
               })
               alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
               self?.present(alert, animated: true, completion: nil)
        }
        viewModel.getUser(userId: userId)
        setupAppearance()
        view.backgroundColor = UIColor.Themed.white
    }

    init(userId: String) {
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
    }

    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var nameView: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.Themed.black
        label.font = UIFont.Bold.size22
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var avatarView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = view.frame.size.width / 2
        view.clipsToBounds = true

        return view
    }()

    private lazy var descriptionView: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor.Themed.black
        label.font = UIFont.Regular.size13
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var siteButton: UIButton = {
        let button = UIButton()
        button.setTitle("Перейти на сайт пользователя", for: .normal)
        button.setTitleColor(UIColor.Themed.black, for: .normal)
        button.titleLabel?.font = UIFont.Regular.size15
        button.layer.cornerRadius = 17
        button.clipsToBounds = true
        button.tintColor = .clear
        button.layer.borderColor = UIColor.Themed.black?.cgColor
        button.layer.borderWidth = 1.0
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(openWebView), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    private lazy var collectionButtonLabel: UILabel = {
        let label = UILabel()
        label.text = "Коллекция NFT"
        label.textColor = UIColor.Themed.black
        label.font = UIFont.Bold.size17
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage.NavigationBar.backward, for: .normal)
        button.contentMode = .scaleAspectFit // Set content mode
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30) // Set the desired size
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        return button
    }()

    private lazy var collectionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(openWebView), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center

        let iconImageView = UIImageView(image: UIImage.NavigationBar.forward?.withTintColor(UIColor.Themed.black ?? .blue))
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        stackView.addArrangedSubview(collectionButtonLabel)
        stackView.addArrangedSubview(iconImageView)

        button.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -8),
            stackView.topAnchor.constraint(equalTo: button.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: button.bottomAnchor)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openNFTCollection))
        stackView.addGestureRecognizer(tapGesture)
        stackView.isUserInteractionEnabled = true

        return button
    }()

    func configure() {
        guard let user = viewModel.user else {return}
        guard  let validUrl = URL(string: user.avatar) else {return}
        let imageSize = CGSize(width: 70, height: 70)
        let placeholderSize = CGSize(width: 70, height: 70)
        let options: KingfisherOptionsInfo = [
            .scaleFactor(UIScreen.main.scale),
            .transition(.fade(1)),
            .cacheOriginalImage
        ]

        avatarView.kf.setImage(with: validUrl, placeholder: UIImage(named: "avatar")?.kf.resize(to: placeholderSize), options: options) { result in
             switch result {
             case .success(let value):
                 DispatchQueue.main.async { [weak self] in
                     self?.avatarView.image = value.image
                     self?.avatarView.layer.cornerRadius = imageSize.width / 2
                     self?.avatarView.layer.masksToBounds = true
                 }
             case .failure(let error):
                 print("Image download failed: \(error)")
                 let alert = UIAlertController(title: "Ошибка при загрузке аватара", message: error.localizedDescription, preferredStyle: .alert)
                   alert.addAction(UIAlertAction(title: "Попробовать снова", style: .default) { _ in
                       self.viewModel.getUser(userId: self.userId)
                   })
                   alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                   self.present(alert, animated: true, completion: nil)
             }
         }
        
        nameView.text = user.name
        nameView.font = UIFont.Bold.size22
        descriptionView.text = user.description
        collectionButtonLabel.text = "Коллекция NFT (\(user.nfts.count))"
        collectionButtonLabel.tintColor = UIColor.Themed.black
        collectionButtonLabel.font = UIFont.Bold.size17
    }

    @objc
    private func openWebView() {
        guard
            let urlString = viewModel.user?.website,
            let url = URL(string: urlString)
        else { return }
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true)
    }

    @objc
    private func openNFTCollection() {

    }

    func setupAppearance() {
        view.backgroundColor = UIColor.Themed.white

        view.addSubview(avatarView)
        view.addSubview(nameView)
        view.addSubview(descriptionView)
        view.addSubview(siteButton)
        view.addSubview(collectionButton)

        avatarView.layer.cornerRadius = 35
        avatarView.layer.masksToBounds = true
        navigationItem.titleView?.backgroundColor = UIColor.Themed.black
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationController?.navigationBar.tintColor = UIColor.Themed.black

        NSLayoutConstraint.activate([
            avatarView.widthAnchor.constraint(equalToConstant: 70),
            avatarView.heightAnchor.constraint(equalTo: avatarView.widthAnchor),
            avatarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            avatarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            nameView.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 16),
            nameView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),

            descriptionView.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 20),
            descriptionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            siteButton.topAnchor.constraint(equalTo: descriptionView.bottomAnchor, constant: 30),
            siteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            siteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            siteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            siteButton.heightAnchor.constraint(equalToConstant: 40),

            collectionButton.topAnchor.constraint(equalTo: siteButton.bottomAnchor, constant: 56),
            collectionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            collectionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionButton.heightAnchor.constraint(equalToConstant: 40),

            backButton.widthAnchor.constraint(equalToConstant: 20)
        ])
    }
}
