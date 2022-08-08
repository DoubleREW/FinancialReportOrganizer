//
//  ProceedsProcessor.swift
//  FinancialReportSplitter
//
//  Created by Fausto Ristagno on 07/08/22.
//

import Foundation

struct ProcessedProceeds {
    let legalEntitiesProceeds: [LegalEntityProceeds]
    let processingErrors: [ProceedsProcessingError]
}

struct LegalEntityProceeds {
    let legalEntity: LegalEntity
    let proceeds: Decimal
    let currency: String
}

struct ProceedsProcessingError {
    let message: String
    let severity: Severity

    enum Severity {
        case info, warning, error
    }

    static func info(_ message: String) -> Self {
        .init(message: message, severity: .info)
    }

    static func warning(_ message: String) -> Self {
        .init(message: message, severity: .warning)
    }

    static func error(_ message: String) -> Self {
        .init(message: message, severity: .error)
    }
}

class ProceedsProcessor : ObservableObject {

    func process(summary: ReportSummaries, of report: FinancialReport) -> ProcessedProceeds {
        let currency = summary.currency
        let currencyFormat = Decimal.FormatStyle.Currency(
            code: currency,
            locale: .init(identifier: "en-US"))
        var proceedsByLegalEntity: [LegalEntity: Decimal] = [:]
        var legalEntitiesProceeds: [LegalEntityProceeds] = []
        var errors: [ProceedsProcessingError] = []

        for regionProceeds in summary.proceedsByRegion {
            let regionCode = regionProceeds.regionCurrency.regionCode

            guard let proceeds = try? Decimal(regionProceeds.proceeds, format: currencyFormat) else {
                errors.append(.error("Cannot convert region proceeds to decimal number for region \(regionCode): \(regionProceeds.proceeds)"))
                continue
            }

            guard let accountableEntity = LegalEntity.accountableLegalEntity(for: regionCode) else {
                errors.append(.error("Accountable legal entity not found for region \(regionCode)"))
                continue
            }

            if proceedsByLegalEntity[accountableEntity] == nil {
                proceedsByLegalEntity[accountableEntity] = 0
            }

            proceedsByLegalEntity[accountableEntity]! += proceeds
        }

        for (legalEntity, aggregatedProceeds) in proceedsByLegalEntity {
            legalEntitiesProceeds.append(
                .init(legalEntity: legalEntity, proceeds: aggregatedProceeds, currency: summary.currency)
            )
        }

        let globalAggregatedProceeds = proceedsByLegalEntity.values.reduce(Decimal.zero) { partialResult, current in
            partialResult + current
        }

        if let summaryAmount = try? Decimal(summary.amount, format: currencyFormat) {
            if summaryAmount != globalAggregatedProceeds {
                errors.append(.error("Aggregated proceeds (\(globalAggregatedProceeds)) does not match report summary amount (\(summaryAmount))"))
            }
        } else {
            errors.append(.error("Failed to parse summary amount"))
        }

        return .init(legalEntitiesProceeds: legalEntitiesProceeds, processingErrors: errors)
    }
}
