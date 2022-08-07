//
//  ReportsOrganizerView.swift
//  FinancialReportSplitter
//
//  Created by Fausto Ristagno on 06/08/22.
//

import SwiftUI
import Combine

struct ReportsOrganizerView: View {
    @StateObject var vm = ViewModel()

    var body: some View {
        NavigationView {
            ReportsSidebar(selectedReport: $vm.activeReport)
            EmptyReportView()
        }
        .sheet(isPresented: $vm.isImportReportViewVisible, content: {
            ReportImportView()
        })
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
                    vm.showImportReportSheet()
                } label: {
                    Image(systemName: "tray.and.arrow.down")
                }
            }
            ToolbarItem(placement: .automatic) {
                Button {
                    vm.openReport()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

extension ReportsOrganizerView {
    @MainActor
    class ViewModel : ObservableObject {
        private var reportsOrganizer: ReportsOrganizer
        private var subscriptions = Set<AnyCancellable>()

        @Published
        var activeReport: ReportPreview? = nil

        @Published
        var isImportReportViewVisible: Bool = false

        @Published
        var lastErrorMessage: String? = nil

        init(reportsOrganizer: ReportsOrganizer = .default) {
            self.reportsOrganizer = reportsOrganizer

            self.reportsOrganizer.events
                .subscribe(on: DispatchQueue.main)
                .sink { [weak self] event in
                    if case .delete(_) = event {
                        self?.activeReport = nil
                    }
                }
                .store(in: &subscriptions)
        }

        func toggleSidebar() {
            #if os(iOS)
            #else
            NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
            #endif
        }

        func showImportReportSheet() {
            self.isImportReportViewVisible = true
        }

        func openReport() {
            let openPanel = NSOpenPanel()
            openPanel.allowedContentTypes = [.json]
            openPanel.allowsMultipleSelection = false
            openPanel.canChooseDirectories = false
            openPanel.canChooseFiles = true
            let response = openPanel.runModal()

            guard response == .OK, let url = openPanel.url else {
                return
            }

            do {
                try reportsOrganizer.addReport(at: url)
            } catch {
                self.lastErrorMessage = "Failed to add report to the organizer"
            }
        }
    }
}

struct ReportOrganizerView_Previews: PreviewProvider {
    static var previews: some View {
        ReportsOrganizerView()
    }
}
