//
//  ConnectBridge.swift
//  FinancialReportSplitter
//
//  Created by Fausto Ristagno on 01/08/22.
//

import Foundation
import WebKit

class WebViewController : NSViewController {
    var webView: WKWebView! {
        didSet {
            webView?.navigationDelegate = self
        }
    }
    var onDismiss: (() -> Void)!

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

    @objc func dismissSelf(_ sender: AnyObject?) {
        self.view.window!.close()
        self.onDismiss()
    }
}

struct UnauthorizedError : Error {}
struct FinancialDataUnavailable : Error {}
struct FetchError : Error {}

class ConnectBridge : NSObject, ObservableObject {
    static var shared: ConnectBridge = {
        return ConnectBridge()
    }()

    private static var loginUrl = "https://appstoreconnect.apple.com/login"
    private static var reportsUrl = "https://appstoreconnect.apple.com/WebObjects/iTunesConnect.woa/ra/paymentConsolidation/providers/%@/sapVendorNumbers/%@?year=%ld&month=%ld"

    private lazy var webView: WKWebView = {
        return WKWebView()
    }()

    private var requestedUrl: URL? = nil
    private var isAuthWindowPresented = false
    private var isAuthNeeded = true
    private var pendingReport: (provider: String, vendor: String, month: Int, year: Int)? = nil

    @Published
    @MainActor
    public var isFetchingReport = false

    @MainActor
    func fetchReport(provider: String, vendor: String, month: Int, year: Int) async throws -> FinancialReport {
        guard !self.isAuthNeeded else {
            // self.pendingReport = (provider, vendor, month, year)
            // self.isAuthNeeded = false
            // self.presentAuthWindow()

            throw UnauthorizedError()
        }

        isFetchingReport = true

        let url = String(format: Self.reportsUrl, provider, vendor, year, month)
        let script = "return await fetch(\"\(url)\").then(res => res.text()).catch(err => \"FETCH_FAILED\");"

        let reports: Any?
        do {
            reports = try await self.webView.callAsyncJavaScript(script, contentWorld: .page)
        } catch {
            reports = nil
            print("error \(error)")
            throw FetchError()
        }

        isFetchingReport = false

        guard let financialReportJson = reports as? String else {
            throw FetchError()
        }

        guard financialReportJson != "FETCH_FAILED" else {
            throw FetchError()
        }

        guard let financialReportData = financialReportJson.data(using: .utf8) else {
            throw FetchError()
        }

        let financialReport = try JSONDecoder().decode(FinancialReportResponse.self, from: financialReportData)

        guard let finalcialData = financialReport.data else {
            throw FinancialDataUnavailable()
        }

        return finalcialData
    }

    private func fetchPendingReport() {
        guard let report = self.pendingReport else {
            return
        }

        Task {
            try await self.fetchReport(
                provider: report.provider,
                vendor: report.vendor,
                month: report.month ,
                year: report.year)
        }
    }

    func presentAuthWindow() {
        let controller = WebViewController(nibName: nil, bundle: nil)
        controller.webView = self.webView
        controller.onDismiss = { [weak self] in
            self?.isAuthWindowPresented = false
            self?.fetchPendingReport()
        }
        let window = NSWindow(contentViewController: controller)
        window.title = "App Store Connect"

        let url = URL(string: Self.loginUrl)!
        let request = URLRequest(url: url)
        self.webView.load(request)

        NSApp.mainWindow?.beginSheet(window)

        self.isAuthWindowPresented = true
        self.isAuthNeeded = false
    }
}

extension WebViewController : WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {

        if let response = navigationResponse.response as? HTTPURLResponse {
            if response.statusCode == 200 && response.url?.absoluteString == "https://appstoreconnect.apple.com" {
                self.dismissSelf(nil)
            }
        }
        decisionHandler(.allow)
    }
}
