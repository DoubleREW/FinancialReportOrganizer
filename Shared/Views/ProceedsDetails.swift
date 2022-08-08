//
//  ProceedsDetails.swift
//  FinancialReportOrganizer
//
//  Created by Fausto Ristagno on 07/08/22.
//

import SwiftUI

struct ProceedsDetails : View {
    @EnvironmentObject
    var processor: ProceedsProcessor

    @State
    var processedProceeds: ProcessedProceeds?

    @State
    var isErrorsPopupShowing: Bool = false

    var summary: ReportSummaries
    var report: FinancialReport

    var body: some View {
        VStack {
            if let processedProceeds = processedProceeds {
                HStack {
                    Text("Proceeds grouped by legal entities")
                    if processedProceeds.processingErrors.count > 0 {
                        Spacer()
                        Button {
                            isErrorsPopupShowing = true
                        } label: {
                            Image(systemName: "exclamationmark.triangle")
                        }
                        .popover(isPresented: $isErrorsPopupShowing, arrowEdge: .bottom) {
                            VStack(alignment: .leading) {
                                ForEach(processedProceeds.processingErrors, id: \.message) { error in
                                    Text(error.message)
                                }
                            }
                            .padding()
                        }
                    }
                }
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(processedProceeds.legalEntitiesProceeds, id: \.legalEntity) { legalEntityProceeds in
                            VStack(alignment: .leading) {
                                Text(legalEntityProceeds.legalEntity.name)
                                    .font(.headline)
                                Text(legalEntityProceeds.legalEntity.address)
                                    .padding([.top], 5)
                                    .padding([.bottom], 10)
                                Text("\(legalEntityProceeds.proceeds.formatted()) \(legalEntityProceeds.currency)")
                            }.padding()
                            Divider()
                        }
                    }
                }
                .border(.secondary, width: 1)
            }
        }
        .padding()
        .frame(width: 640, height: 480)
        .onAppear {
            processedProceeds = processor.process(summary: summary, of: report)
        }
    }
}

struct ProceedsDetails_Previews: PreviewProvider {
    static var previews: some View {
        ProceedsDetails(
            summary: FinancialReport.sample.reportSummaries.first!,
            report: FinancialReport.sample)
    }
}

