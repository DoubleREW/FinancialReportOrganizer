//
//  ReportViewer.swift
//  FinancialReportOrganizer
//
//  Created by Fausto Ristagno on 06/08/22.
//

import SwiftUI

struct ReportViewer: View {
    @StateObject
    var vm = ViewModel()

    var _inputReport: FinancialReport

    init(report: FinancialReport) {
        self._inputReport = report
    }

    @ViewBuilder
    func Heading() -> some View {
        HStack {
            VStack(alignment: .leading) {
                if let reportDate = vm.reportDate {
                    Text(reportDate.formatted(.dateTime.month(.wide).year()))
                        .font(.title)
                }
                Text(vm.report.vendorName)
                    .font(.title2)
                Text(String(format: "Vendor #%ld", vm.report.sapVendorNumber))
                    .font(.title3)
                    .foregroundColor(.secondary)
                if vm.report.reportSummaries.count > 1 {
                    Picker("Summary", selection: $vm.summaryIndex) {
                        ForEach(0..<vm.report.reportSummaries.count, id: \.self) { i in
                            Text("Summary \(i + 1)").tag(i)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(vm.reportSummary.status.replacingOccurrences(of: "_", with: " "))
                    .padding(5)
                    .background(vm.bgColorForSummaryStatus(vm.reportSummary.status))
                    .cornerRadius(5)
                    .foregroundColor(vm.textColorForSummaryStatus(vm.reportSummary.status))
                Text("\(vm.reportSummary.amount) \(vm.reportSummary.currency)")
                if vm.reportSummary.status == "PAID" {
                    Text("\(vm.reportSummary.bankName) \(vm.reportSummary.maskedBankAccount)")
                }
            }
        }
    }

    var body: some View {
        VStack {
            if vm.report != nil {
                Heading()
                Table(vm.sortedProceedsByRegion, sortOrder: $vm.sortOrder) {
                    TableColumn("Region", value: \.regionCurrency.regionName)
                    TableColumn("Region code", value: \.regionCurrency.regionCode)
                    TableColumn("Owed", value: \.totalOwed)
                    TableColumn("Currency", value: \.regionCurrency.currencyCode)
                    TableColumn("Ratio", value: \.exchangeRate)
                    TableColumn("Proceeds (\(vm.reportSummary.currency))", value: \.proceeds)
                }
            }
        }
        .padding()
        .onAppear {
            vm.report = _inputReport
        }
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button {
                    vm.showDeleteReportAlert()
                } label: {
                    Image(systemName: "trash")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    vm.showProceedsDetailsSheet()
                } label: {
                    Image(systemName: "square.grid.2x2")
                }
            }
        }
        .alert("Are you sure you want to delete this report?", isPresented:  $vm.isDeleteAlertShowing) {
            Button(role: .destructive) {
                vm.deleteReport()
            } label: {
                Text("Delete")
            }
            Button(role: .cancel) {
                vm.isDeleteAlertShowing = false
            } label: {
                Text("Cancel")
            }
        }
        .alert(isPresented: .constant(vm.lastError != nil), error: vm.lastError) {
            Button(role: .cancel) {
                vm.lastError = nil
            } label: {
                Text("Cancel")
            }
        }
        .sheet(isPresented: $vm.isProceedsDetailsSheetShowing) {
            VStack(alignment: .leading) {
                ProceedsDetails(summary: vm.reportSummary, report: vm.report)
                VStack(alignment: .trailing) {
                    Button(role: .cancel) {
                        vm.isProceedsDetailsSheetShowing = false
                    } label: {
                        Text("Close")
                    }
                }
                .padding()
            }
        }
    }
}

extension ReportViewer {
    @MainActor
    class ViewModel : ObservableObject {
        private var reportsOrganizer: ReportsOrganizer

        @Published
        var summaryIndex: Int = 0

        @Published
        var sortOrder: [KeyPathComparator<ProceedsByRegion>] = [
            .init(\.regionCurrency.regionName, order: SortOrder.forward),
            .init(\.regionCurrency.regionCode, order: SortOrder.forward),
            .init(\.totalOwed, order: SortOrder.forward),
            .init(\.regionCurrency.currencyCode, order: SortOrder.forward),
            .init(\.exchangeRate, order: SortOrder.forward),
            .init(\.proceeds, order: SortOrder.forward),
        ]

        @Published
        var isDeleteAlertShowing: Bool = false

        @Published
        var isErrorAlertShowing: Bool = false

        @Published
        var isProceedsDetailsSheetShowing: Bool = false

        @Published
        var lastError: Error? = nil {
            didSet {
                isErrorAlertShowing = lastError != nil
            }
        }

        lazy var jsonDateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = .init(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

            return dateFormatter
        }()

        var report: FinancialReport! {
            didSet {
                objectWillChange.send()
            }
        }

        var reportDate: Date? {
            jsonDateFormatter.date(from: report.reportDate)
        }

        var reportSummary: ReportSummaries {
            report.reportSummaries[summaryIndex]
        }

        var sortedProceedsByRegion: [ProceedsByRegion] {
            reportSummary.proceedsByRegion.sorted(using: sortOrder)
        }

        enum Error: LocalizedError {
            case reportDeletionFailed

            var errorDescription: String? {
                switch self {
                case .reportDeletionFailed:
                    return "Report deletion failed"
                }
            }

            var recoverySuggestion: String? {
                switch self {
                case .reportDeletionFailed:
                    return nil
                }
            }
        }

        init(reportsOrganizer: ReportsOrganizer = .default) {
            self.reportsOrganizer = reportsOrganizer
        }

        func bgColorForSummaryStatus(_ status: String) -> Color {
            if status == "PAID" {
                return Color.green
            } else {
                return Color.indigo
            }
        }

        func textColorForSummaryStatus(_ status: String) -> Color {
            if status == "PAID" {
                return Color.white
            } else {
                return Color.white
            }
        }

        func showDeleteReportAlert() {
            isDeleteAlertShowing = true
        }

        func deleteReport() {
            if !reportsOrganizer.deleteReport(report) {
                lastError = .reportDeletionFailed
            }
        }

        func showProceedsDetailsSheet() {
            self.isProceedsDetailsSheetShowing = true
        }
    }
}

struct ReportViewer_Previews: PreviewProvider {
    static var previews: some View {
        ReportViewer(report: FinancialReport.sample)
    }
}
