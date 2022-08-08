//
//  AscAuthViewController.swift
//  FinancialReportOrganizer
//
//  Created by Fausto Ristagno on 05/08/22.
//

import Foundation
import WebKit

class AscAuthViewController : NSViewController {
    var webView: WKWebView! {
        didSet {
            webView?.navigationDelegate = self
        }
    }
    var onDismiss: ((Bool) -> Void)!

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = NSView(frame: NSMakeRect(0.0, 0.0, 800, 600))

        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        let button = NSButton(title: "Close", target: self, action: #selector(dismissSelf(_:)))
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)

        NSLayoutConstraint.activate([
            webView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1, constant: -40),
            webView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),

            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
        ])
    }

    @objc func dismissSelf(_ sender: Any?) {
        self.dismissAndNotify(false)
    }

    func dismissAndNotify(_ isAuthenticated: Bool) {
        self.view.window!.close()
        self.onDismiss(isAuthenticated)
    }
}

extension AscAuthViewController : WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {

        if let response = navigationResponse.response as? HTTPURLResponse {
            if let resUrl = response.url?.absoluteString, response.statusCode == 200 && resUrl.starts(with: "https://appstoreconnect.apple.com/itc/payments_and_financial_reports") {
                self.dismissAndNotify(true)
            }
        }

        decisionHandler(.allow)
    }
}
