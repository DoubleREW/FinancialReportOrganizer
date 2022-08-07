//
//  ReportsOrganizer.swift
//  FinancialReportSplitter
//
//  Created by Fausto Ristagno on 06/08/22.
//

import Foundation
import Combine

struct ReportsGroup : Identifiable, Hashable {
    let vendor: Int
    let year: Int
    let reports: [ReportPreview]

    var id: String {
        return "\(vendor)_\(year)"
    }
}

struct ReportPreview : Identifiable, Hashable {
    let vendor: Int
    let year: Int
    let month: Int
    let url: URL

    var id: String {
        return "\(vendor)_\(year)_\(month)"
    }
}

class ReportsOrganizer : ObservableObject {
    static var `default`: ReportsOrganizer = {
        ReportsOrganizer()
    }()

    var events: PassthroughSubject<Event, Never> = .init()

    enum Event {
        case add(FinancialReport), delete(URL)
    }

    enum ImportError : Error {
        case invalidFile(Error)
        case noData
        case unknownFormat
        case writeError(Error)
        case fileExists
    }

    func addReport(at url: URL, replaceIfExists replace: Bool = true) throws {
        let data = try Data(contentsOf: url)

        try self.addReport(with: data, replaceIfExists: replace)
    }

    func addReport(with reportResponseData: Data, replaceIfExists replace: Bool = true) throws {
        let report: FinancialReport

        do {
            let response = try JSONDecoder().decode(FinancialReportResponse.self, from: reportResponseData)

            guard let _report = response.data else {
                throw ImportError.noData
            }

            report = _report
        } catch {
            throw ImportError.invalidFile(error)
        }

        guard let reportDate = parseReportDate(report.reportDate) else {
            throw ImportError.unknownFormat
        }

        let reportDateComps = reportDateComponents(reportDate)
        let vendorNumber = report.sapVendorNumber
        let destDir = reportsFolder(vendorNumber: vendorNumber, year: reportDateComps.year)

        do {
            try FileManager.default.createDirectory(at: destDir, withIntermediateDirectories: true)
        } catch {
            throw ImportError.writeError(error)
        }

        let destFile = reportDocument(for: vendorNumber, year: reportDateComps.year, month: reportDateComps.month)

        if !replace && FileManager.default.fileExists(atPath: destFile.path) {
            throw ImportError.fileExists
        }

        guard
            let reportResponseObj = try? JSONSerialization.jsonObject(with: reportResponseData) as? [String: Any?],
            let reportResponseDataObj = reportResponseObj["data"] as? [String: Any?]
        else {
            throw ImportError.unknownFormat
        }

        do {
            let reportResponseDataObjData = try JSONSerialization.data(withJSONObject: reportResponseDataObj)

            try (reportResponseDataObjData as NSData)
                .compressed(using: .lzfse)
                .write(to: destFile)
        } catch {
            throw ImportError.writeError(error)
        }

        objectWillChange.send()
        events.send(.add(report))
    }

    func deleteReport(_ report: FinancialReport) -> Bool {
        let fm = FileManager.default
        let vendorNumber = report.sapVendorNumber

        guard let reportDate = parseReportDate(report.reportDate) else {
            return false
        }

        let reportDateComps = reportDateComponents(reportDate)
        let reportUrl = reportDocument(for: vendorNumber, year: reportDateComps.year, month: reportDateComps.month)

        do {
            try fm.removeItem(at: reportUrl)
        } catch {
            return false
        }

        objectWillChange.send()
        events.send(.delete(reportUrl))

        return true
    }

    func reportsGroups(for vendorNumber: Int) -> [ReportsGroup] {
        let fm = FileManager.default
        let vendorDir = reportsFolder(vendorNumber: vendorNumber)

        var isDir: ObjCBool = false
        if !(fm.fileExists(atPath: vendorDir.path, isDirectory: &isDir) && isDir.boolValue) {
            return []
        }

        guard let subdirs = try? fm.contentsOfDirectory(atPath: vendorDir.path) else {
            return []
        }

        var avbYears: [Int] = []
        var avbMonthsPerYear: [Int: [(month: Int, url: URL)]] = [:]
        for subdir in subdirs {
            // Validate folder name
            guard let year = Int(subdir) else {
                continue
            }

            // Check if the folder contains reports
            let docs = reportDocuments(for: vendorNumber, year: year)
            guard docs.count > 0 else {
                continue
            }

            avbYears.append(year)
            let avbMonths = docs.map {
                (month: Int(String($0.deletingPathExtension().deletingPathExtension().lastPathComponent.split(separator: "_").last!)), url: $0)
            }.filter { $0.month != nil } as! [(month: Int, url: URL)]
            avbMonthsPerYear[year] = avbMonths.sorted(by: { $0.month > $1.month })
        }

        return avbYears
            .sorted()
            .reversed()
            .map { year in
                ReportsGroup(
                    vendor: vendorNumber,
                    year: year,
                    reports: avbMonthsPerYear[year]!.map({ monthPair in
                        ReportPreview(
                            vendor: vendorNumber,
                            year: year,
                            month: monthPair.month,
                            url: monthPair.url)
                    }))
            }
    }

    func reports(for vendorNumber: Int, year: Int) -> [FinancialReport] {
        let fm = FileManager.default
        let reportsDir = reportsFolder(vendorNumber: vendorNumber, year: year)
        var isDir: ObjCBool = false

        if !(fm.fileExists(atPath: reportsDir.path, isDirectory: &isDir) && isDir.boolValue) {
            return []
        }

        return reportDocuments(for: vendorNumber, year: year).map(report(at:)).filter { $0 != nil } as! [FinancialReport]
    }

    private func parseReportDate(_ date: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

        return dateFormatter.date(from: date)
    }

    private func reportDateComponents(_ date: Date) -> (year: Int, month: Int) {
        let calendar = Calendar(identifier: .iso8601)
        let reportMonth = calendar.component(.month, from: date)
        let reportYear = calendar.component(.year, from: date)

        return (reportYear, reportMonth)
    }

    private func reportDocument(for vendorNumber: Int, year reportYear: Int, month reportMonth: Int) -> URL {
        let destDir = reportsFolder(vendorNumber: vendorNumber, year: reportYear)
        let fileName = "\(vendorNumber)_\(reportYear)_\(reportMonth).json.lzfse"

        return destDir.appendingPathComponent(fileName)
    }

    private func reportDocuments(for vendorNumber: Int, year: Int) -> [URL] {
        let fm = FileManager.default
        let vendorDir = reportsFolder(vendorNumber: vendorNumber)
        let yearDir = vendorDir.appendingPathComponent(String(format: "%ld", year))

        // Check if is a folder
        var isDir: ObjCBool = false
        fm.fileExists(atPath: yearDir.path, isDirectory: &isDir)
        if !isDir.boolValue {
            return []
        }

        // Check if the folder contains reports
        let reportDocumentUrls = ((try? fm.contentsOfDirectory(atPath: yearDir.path)) ?? []).filter {
            $0.hasSuffix(".json.lzfse")
        }.map {
            yearDir.appendingPathComponent($0)
        }

        return reportDocumentUrls
    }

    func report(at url: URL) -> FinancialReport? {
        guard
            let compressedReportData = try? Data(contentsOf: url),
            let reportData = try? (compressedReportData as NSData).decompressed(using: .lzfse)
        else {
            return nil
        }

        return try? JSONDecoder().decode(FinancialReport.self, from: reportData as Data)
    }

    func availableVendorNumbers() -> [Int] {
        let fm = FileManager.default
        let reportsFolder = reportsFolder()

        guard let subdirs = try? fm.contentsOfDirectory(atPath: reportsFolder.path) else {
            return []
        }

        let vendorNumbers: [Int?] = subdirs.map { subdir in
            var isDir: ObjCBool = false

            if fm.fileExists(atPath: reportsFolder.appendingPathComponent(subdir).path, isDirectory: &isDir) && isDir.boolValue {
                return Int(subdir)
            } else {
                return nil
            }
        }.filter { $0 != nil }

        return vendorNumbers as! [Int]
    }

    private func reportsFolder() -> URL {
        let appSupportDirUrl = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!

        return appSupportDirUrl
            .appendingPathComponent(Bundle.main.bundleIdentifier!)
            .appendingPathComponent("Documents")
            .appendingPathComponent("Reports")
    }

    private func reportsFolder(vendorNumber: Int) -> URL {
        return reportsFolder()
            .appendingPathComponent("\(vendorNumber)")
    }

    private func reportsFolder(vendorNumber: Int, year: Int) -> URL {
        return reportsFolder(vendorNumber: vendorNumber)
            .appendingPathComponent("\(year)")
    }
}
