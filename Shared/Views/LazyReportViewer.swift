//
//  LazyReportViewer.swift
//  FinancialReportSplitter
//
//  Created by Fausto Ristagno on 06/08/22.
//

import SwiftUI

struct LazyReportViewer: View {
    @EnvironmentObject
    var reportsOrganizer: ReportsOrganizer

    @State
    var report: FinancialReport?

    var reportUrl: URL

    var body: some View {
        Group {
            if let report = report {
                ReportViewer(report: report)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            report = reportsOrganizer.report(at: reportUrl)
        }
    }
}
