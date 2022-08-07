//
//  ContentView.swift
//  Shared
//
//  Created by Fausto Ristagno on 01/08/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var vm = ViewModel()
    var months: [String] = {
        DateFormatter().monthSymbols
    }()

    var body: some View {
        NavigationView {
            List {
                Text("AAA")
                Text("BBB")
                Text("CCC")
            }
            VStack {
                Form {
                    Picker("Month", selection: $vm.month) {
                        ForEach(1...12, id: \.self) { month in
                            Text(months[month - 1]).tag(month)
                        }
                    }
                    Picker("Year", selection: $vm.year) {
                        ForEach(2000...vm.currentYear, id: \.self) { year in
                            Text("\(year)").tag(year)
                        }
                    }
                }
                Button("Carica") {
                    Task {
                        await vm.fetchReport(
                            month: vm.month,
                            year: vm.year)
                    }
                }
                if let report = vm.report {
                    Table(report.reportSummaries.first!.proceedsByRegion) {
                        TableColumn("Region", value: \.regionCurrency.regionName)
                        TableColumn("Proceeds", value: \.proceeds)
                    }
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    vm.toggleSidebar()
                } label: {
                    Image(systemName: "sidebar.leading")
                }

            }
            ToolbarItem(placement: .automatic) {
                Button {

                } label: {
                    Image(systemName: "tray.and.arrow.down")
                }
            }
            ToolbarItem(placement: .automatic) {
                Button {

                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }


}

extension ContentView {
    @MainActor
    class ViewModel : ObservableObject {
        var currentYear: Int {
            Calendar.current.component(.year, from: Date())
        }

        var currentMonth: Int {
            Calendar.current.component(.month, from: Date())
        }

        @Published
        var month: Int = 6
        @Published
        var year: Int = 2022
        @Published
        var report: FinancialReport? = nil

        init() {
            self.month = currentMonth
            self.year = currentYear
        }

        func fetchReport(month: Int, year: Int) async {
            do {
                let userDetail = try await AscConnector.shared.fetchUserDetail()
                guard let provider = userDetail.associatedAccounts.first?.contentProvider.contentProviderId else {
                    return
                }

                let sapVendorNumbers = try await AscConnector.shared.fetchSapVendorNumbers(provider: provider)

                guard let vendor = sapVendorNumbers.first?.sapVendorNumber else {
                    return
                }

                self.report = try await AscConnector.shared.fetchReport(
                    provider: provider,
                    vendor: vendor,
                    month: month,
                    year: year).report
            } catch {
                if error is UnauthorizedError {
                    AscConnector.shared.presentAuthWindow()
                }
            }

            // Process report
            if let report = report {
                processReport(report)
            }
        }

        func processReport(_ report: FinancialReport, summaryIndex: Int = 0) {
            precondition(summaryIndex < report.reportSummaries.count, "Missing report summary \(summaryIndex)")

            let reportSummary = report.reportSummaries[summaryIndex]
            let currency = reportSummary.currency
            let currencyFormat = Decimal.FormatStyle.Currency(
                code: currency,
                locale: .init(identifier: "en-US"))
            var proceedsByLegalEntity: [LegalEntity: Decimal] = [:]

            for regionProceeds in reportSummary.proceedsByRegion {
                let regionCode = regionProceeds.regionCurrency.regionCode
                guard let proceeds = try? Decimal(regionProceeds.proceeds, format: currencyFormat) else {
                    print("Cannot convert region proceeds to decimal number for region \(regionCode): \(regionProceeds.proceeds)")
                    continue
                }

                guard let accountableEntity = LegalEntity.accountableLegalEntity(for: regionCode) else {
                    print("Accountable legal entity not found for region \(regionCode)")
                    continue
                }

                if proceedsByLegalEntity[accountableEntity] == nil {
                    proceedsByLegalEntity[accountableEntity] = 0
                }

                proceedsByLegalEntity[accountableEntity]! += proceeds
            }

            for (legalEntity, aggregatedProceeds) in proceedsByLegalEntity {
                print("\(legalEntity.name): \(aggregatedProceeds) \(currency)")
            }

            let globalAggregatedProceeds = proceedsByLegalEntity.values.reduce(Decimal.zero) { partialResult, current in
                partialResult + current
            }

            print("Global aggregated proceeds: \(globalAggregatedProceeds)")
        }

        func toggleSidebar() { // 2
            #if os(iOS)
            #else
            NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
            #endif
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
