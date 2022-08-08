//
//  FinancialReportOrganizerApp.swift
//  Shared
//
//  Created by Fausto Ristagno on 01/08/22.
//

import SwiftUI

@main
struct FinancialReportOrganizerApp: App {
    var body: some Scene {
        WindowGroup {
            ReportsOrganizerView()
                .navigationTitle("Financial Report Organizer")
                .frame(minWidth: 800, maxWidth: .infinity, minHeight: 500, maxHeight: .infinity)
                .environmentObject(ReportsOrganizer.default)
                .environmentObject(AscConnector.shared)
                .environmentObject(ProceedsProcessor())
        }
        .commands {
            SidebarCommands()
        }
    }
}

#if DEBUG
extension FinancialReport {
    static var sample: FinancialReport {
        let sampleUrl = Bundle.main.url(forResource: "sample_report", withExtension: "json")!
        let sampleData = try! Data(contentsOf: sampleUrl)

        return try! JSONDecoder().decode(FinancialReport.self, from: sampleData)
    }
}
#endif
