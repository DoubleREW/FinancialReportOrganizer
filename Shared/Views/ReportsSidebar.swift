//
//  ReportsSidebar.swift
//  FinancialReportOrganizer
//
//  Created by Fausto Ristagno on 06/08/22.
//

import SwiftUI

struct ReportsSidebar: View {
    @EnvironmentObject
    var reportsOrganizer: ReportsOrganizer

    @State
    var vendorNumbers: [Int] = []

    @State
    var vendorNumber: Int? = nil

    @Binding
    var selectedReport: ReportPreview?

    var months: [String] = {
        DateFormatter().monthSymbols
    }()

    var body: some View {
        VStack {
            List(selection: $selectedReport) {
                if let vendorNumber = vendorNumber {
                    ForEach(reportsOrganizer.reportsGroups(for: vendorNumber)) { group in
                        Section(header: Text(String(format: "%ld", group.year))) {
                            ForEach(group.reports) { reportPreview in
                                NavigationLink {
                                    LazyReportViewer(reportUrl: reportPreview.url)
                                } label: {
                                    Text(monthLabel(reportPreview.month))
                                }
                                .tag(reportPreview)
                            }
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            Divider()
            if let vendorNumber = vendorNumber {
                Menu {
                    ForEach(vendorNumbers, id: \.self) { vn in
                        Button(String(format: "%ld", vn)) {
                            self.vendorNumber = vn
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "person.circle")
                        Spacer()
                        Text(String(format: "%ld", vendorNumber))
                    }
                }
                .menuStyle(.borderlessButton)
                .padding([.horizontal])
                .padding([.bottom], 10)
                .padding([.top], 5)
            }
        }
        .onAppear {
            vendorNumbers = reportsOrganizer.availableVendorNumbers()
            if vendorNumber == nil {
                vendorNumber = vendorNumbers.first
            }
        }
    }

    func monthLabel(_ number: Int) -> String {
        return months[number - 1]
    }
}

struct ReportsSidebar_Previews: PreviewProvider {
    static var previews: some View {
        ReportsSidebar(selectedReport: .constant(nil))
    }
}
