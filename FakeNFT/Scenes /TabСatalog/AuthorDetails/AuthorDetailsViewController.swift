import UIKit
import WebKit
import ProgressHUD

final class AuthorDetailsViewController: UIViewController {
    
    // MARK: Internal properties
    
    var websiteURL: URL?
    
    // MARK: Private properties
    
    private let webView = WKWebView()
    private lazy var alertHelper = AlertHelper(delegate: self)
    
    // MARK: Override functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        
        setupNavigationBar()
        makeViewLayout()
        loadAuthorDetails()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        ProgressHUD.dismiss()
    }
    
    // MARK: Private functions
    
    private func setupNavigationBar() {
        guard let bar = navigationController?.navigationBar else {
            return
        }
        bar.topItem?.backBarButtonItem = UIBarButtonItem()
        bar.tintColor = .Themed.black
    }
    
    private func makeViewLayout() {
        view.backgroundColor = .Themed.white
        
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func loadAuthorDetails() {
        guard let url = websiteURL else {
            return
        }
        webView.load(URLRequest(url: url))
        ProgressHUD.show()
    }
    
    private func makeRetryAlertController() {
        let retryAlertModel = alertHelper.makeRetryAlertModel { [weak self] _ in
            guard let self = self else {
                return
            }
            self.loadAuthorDetails()
        }
        alertHelper.makeAlertController(from: retryAlertModel)
    }
}

// MARK: - WKNavigationDelegate

extension AuthorDetailsViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ProgressHUD.dismiss()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        makeRetryAlertController()
        ProgressHUD.dismiss()
    }
}

// MARK: - AlertHelperDelegate

extension AuthorDetailsViewController: AlertHelperDelegate {
    
    func didMakeAlert(controller: UIAlertController) {
        present(controller, animated: true)
    }
}
