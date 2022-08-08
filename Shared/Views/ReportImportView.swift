//
//  ReportImportView.swift
//  FinancialReportSplitter
//
//  Created by Fausto Ristagno on 06/08/22.
//

import SwiftUI

struct ReportImportView: View {
    @EnvironmentObject
    var ascConnector: AscConnector

    @EnvironmentObject
    var reportsOrganizer: ReportsOrganizer

    @Binding
    var isPresented: Bool

    @State
    var isImporting: Bool = false

    @State
    var selectedMonth: Int = 6

    @State
    var selectedYear: Int = 2022

    @State
    var importError: Error? = nil

    @State
    var isErrorAlertShowing: Bool = false

    var canImport: Bool {
        ascConnector.isAuthenticated
    }

    var months: [String] = {
        DateFormatter().monthSymbols
    }()

    var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }

    var currentMonth: Int {
        Calendar.current.component(.month, from: Date())
    }

    enum Error: LocalizedError {
        case missingContentProvider
        case missingVendorNumber
        case importFailed(ReportsOrganizer.ImportError)

        var errorDescription: String? {
            switch self {
            case .missingContentProvider:
                return "Unable to find a content provider id connected to your account"
            case .missingVendorNumber:
                return "Unable to find a vendor number connected to your account"
            case .importFailed(_):
                return "Import failed"
            }
        }

        var recoverySuggestion: String? {
            return nil
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            if ascConnector.isAuthenticated {
                if isImporting {
                    VStack(alignment: .center) {
                        ProgressView()
                            .padding(.bottom, 10)
                        Text("Import in progress, this may take a few seconds.")
                    }
                } else {
                    VStack {
                        Text("Select month and year of the financial report you'd like to import.")
                            .padding(.bottom, 10)
                        HStack {
                            Picker("Month", selection: $selectedMonth) {
                                ForEach(1...12, id: \.self) { month in
                                    Text(months[month - 1])
                                        .tag(month)
                                }
                            }
                            .labelsHidden()
                            Picker("Year", selection: $selectedYear) {
                                ForEach(2000...currentYear, id: \.self) { year in
                                    Text(String(format: "%ld", year))
                                        .tag(year)
                                }
                            }
                            .labelsHidden()
                        }
                    }
                    .onAppear {
                        self.selectedMonth = currentMonth
                        self.selectedYear = currentYear
                    }
                }
            } else {
                VStack(alignment: .center) {
                    Text("In order to automatically import finacial reports you should login with the App Store Connect")
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 10)
                    Button("Login") {
                        ascConnector.presentAuthWindow()
                    }
                }
            }
            Spacer()
            HStack(alignment: .center) {
                Spacer()
                Button("Close") {
                    isPresented = false
                }
                if canImport {
                    Button("Import") {
                        launchImport()
                    }
                    .disabled(isImporting)
                }
            }
        }
        .padding()
        .frame(width: 360, height: 180)
        .alert(isPresented: .constant(importError != nil), error: importError) {
            Button(role: .cancel) {
                importError = nil
            } label: {
                Text("Cancel")
            }
        }
    }

    func launchImport() {
        isImporting = true
        Task {
            do {
                let userDetail = try await AscConnector.shared.fetchUserDetail()

                // TODO: Add support for multiple teams
                guard let provider = userDetail.associatedAccounts.first?.contentProvider.contentProviderId else {
                    importError = .missingContentProvider
                    return
                }

                let sapVendorNumbers = try await AscConnector.shared.fetchSapVendorNumbers(provider: provider)

                // TODO: Add support for multiple vendors for team (?)
                guard let vendor = sapVendorNumbers.first?.sapVendorNumber else {
                    importError = .missingVendorNumber
                    return
                }

                let result = try await AscConnector.shared.fetchReport(
                    provider: provider,
                    vendor: vendor,
                    month: selectedMonth,
                    year: selectedYear)

                try reportsOrganizer.addReport(with: result.rawData)
            } catch {
                if error is UnauthorizedError {
                    AscConnector.shared.presentAuthWindow()
                } else if error is ReportsOrganizer.ImportError {
                    importError = .importFailed(error as! ReportsOrganizer.ImportError)
                }
            }

            isImporting = false
            isPresented = false
        }
    }
}

struct ReportImportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportImportView(isPresented: .constant(true))
    }
}
