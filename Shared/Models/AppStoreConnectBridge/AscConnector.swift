//
//  AscConnector.swift
//  FinancialReportOrganizer
//
//  Created by Fausto Ristagno on 01/08/22.
//

import Foundation
import WebKit

struct UnauthorizedError : Error {}
enum FetchError : Error {
    case genericError
    case fetchFailed
    case invalidResponse
    case decodingError
    case requestFailed
    case noData
}

class AscConnector : ObservableObject {
    static var shared: AscConnector = {
        return AscConnector()
    }()

    private static let loginUrl = "https://appstoreconnect.apple.com/login?targetUrl=%2Fitc%2Fpayments_and_financial_reports"
    private static let userDetailUrl = "https://appstoreconnect.apple.com/WebObjects/iTunesConnect.woa/ra/user/detail"
    private static let sapVendorNumbersUrl = " https://appstoreconnect.apple.com/WebObjects/iTunesConnect.woa/ra/paymentConsolidation/providers/%ld/sapVendorNumbers"
    private static let reportsUrl = "https://appstoreconnect.apple.com/WebObjects/iTunesConnect.woa/ra/paymentConsolidation/providers/%ld/sapVendorNumbers/%ld?year=%ld&month=%ld"

    private lazy var webView: WKWebView = {
        return WKWebView()
    }()

    private static let authTimeout: TimeInterval = 15 * 60
    private var authTimer: Timer? = nil

    @Published
    public private(set) var isAuthWindowPresented = false

    @Published
    public private(set) var isAuthenticated = false {
        didSet {
            authTimer?.invalidate()
            authTimer = nil

            if isAuthenticated {
                authTimer = Timer.scheduledTimer(withTimeInterval: Self.authTimeout, repeats: false, block: { [weak self] timer in
                    self?.isAuthenticated = false
                })
            }
        }
    }

    func presentAuthWindow() {
        let controller = AscAuthViewController(nibName: nil, bundle: nil)
        controller.webView = self.webView
        controller.onDismiss = { [weak self] isAuthenticated in
            self?.isAuthenticated = isAuthenticated
            self?.isAuthWindowPresented = false
        }

        let window = NSWindow(contentViewController: controller)
        window.title = "App Store Connect Login"

        let url = URL(string: Self.loginUrl)!
        let request = URLRequest(url: url)
        self.webView.load(request)

        NSApp.keyWindow?.beginSheet(window)

        self.isAuthWindowPresented = true
    }

    func fetchUserDetail() async throws -> UserDetail {
        return try await self.fetchWebApi(Self.userDetailUrl, UserDetailResponse.self).payload
    }

    func fetchSapVendorNumbers(provider: Int) async throws -> [SapVendorNumber] {
        let url = String(format: Self.sapVendorNumbersUrl, provider)

        return try await self.fetchWebApi(url, SapVendorNumbersResponse.self).payload
    }

    func fetchReport(provider: Int, vendor: Int, month: Int, year: Int) async throws -> (report: FinancialReport, rawData: Data) {
        let url = String(format: Self.reportsUrl, provider, vendor, year, month)
        let res = try await self.fetchWebApi(url, FinancialReportResponse.self)

        return (res.payload, res.rawData)
    }

    private func fetchWebApi<R: Response>(_ url: String, _ ofType: R.Type, requireAuth: Bool = true) async throws -> (payload: R.Payload, rawData: Data) {
        guard !requireAuth || self.isAuthenticated else {
            throw UnauthorizedError()
        }

        let script = "return await fetch(\"\(url)\").then(res => res.text()).catch(err => \"__FETCH_FAILED__\");"

        let response: Any?
        do {
            response = try await self.webView.callAsyncJavaScript(script, contentWorld: .page)
        } catch {
            response = nil
            throw FetchError.genericError
        }

        guard let responseJson = response as? String else {
            throw FetchError.invalidResponse
        }

        guard responseJson != "__FETCH_FAILED__" else {
            throw FetchError.fetchFailed
        }

        guard let responseData = responseJson.data(using: .utf8) else {
            throw FetchError.invalidResponse
        }

        let responseObj: R
        do {
            responseObj = try JSONDecoder().decode(R.self, from: responseData)
        } catch {
            throw FetchError.decodingError
        }

        guard responseObj.statusCode == "SUCCESS" else {
            throw FetchError.requestFailed
        }

        guard let responseObjData = responseObj.data else {
            throw FetchError.noData
        }

        return (responseObjData, responseData)
    }
}
