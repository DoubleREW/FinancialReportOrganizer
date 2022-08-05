//
//  LegalEntity.swift
//  FinancialReportSplitter
//
//  Created by Fausto Ristagno on 03/08/22.
//

import Foundation

///
/// Regions references:
///  - App Store Connect API regions list: https://help.apple.com/app-store-connect/?lang=en#/dev63d64d955
///  - EXHIBIT A of Apple paid apps contract
struct LegalEntity {
    let name: String
    let regions: Set<String>

    static let appleCanada: LegalEntity = .init(name: "Apple Canada, Inc.", regions: Set([
        "CA", // Canada
    ]))

    static let appleInc: LegalEntity = .init(name: "Apple Inc.", regions: Set([
        "US", // United States
    ]))

    static let applePty: LegalEntity = .init(name: "Apple Pty Limited", regions: Set([
        "AU", // Australia
        "NZ", // New Zeland
    ]))

    static let appleLatamLlc: LegalEntity = .init(name: "Apple Services LATAM LLC", regions: Set([
        "LL", // Latin America and the Caribbean
        "BR", // Brazil
        "CO", // Colombia
        "MX", // Mexico
        "PE", // Peru

        // Listed both in Latin Americas and specific region
        "CL", // Chile
    ]))

    static let itunesKk: LegalEntity = .init(name: "iTunes KK", regions: Set([
        "JP", // Japan
    ]))

    static let appleDistributionLtd: LegalEntity = .init(name: "Apple Distribution International Ltd.", regions: Set([
        "EU", // Euro-Zone
        "WW", // Rest of World

        "CN", // China
        "DK", // Denmark
        "HK", // Hong Kong
        "IN", // India
        "ID", // Indonesia
        "IL", // Istrael
        "NO", // Norway
        "RU", // Russia
        "SA", // Saudi Arabia
        "SG", // Singapore
        "ZA", // South Africa
        "SE", // Sweden
        "CH", // Switzerland
        "TW", // Taiwan
        "TH", // Thailand
        "TR", // Turkey
        "AE", // United Arab Emirates
        "GB", // United Kingdom

        // Listed both in Euro-Zone and specific region
        "BG", // Bulgaria
        "CZ", // Czech Republic
        "HU", // Hungary
        "PL", // Poland
        "RO", // Romania

        // Listed both in Rest-of-World and specific region
        "HR", // Croatia
        "EG", // Egypt
        "KZ", // Kazakhstan
        "KR", // Republic of Korea
        "MY", // Malaysia
        "NG", // Nigeria
        "PK", // Pakistan
        "PH", // Philippines
        "QA", // Qatar
        "TZ", // Tanzania
        "VN", // Vietnam
    ]))

    static func accountableLegalEntity(for regionCode: String) -> LegalEntity? {
        for legalEntity in Self.allCases {
            if legalEntity.regions.contains(regionCode) {
                return legalEntity
            }
        }

        return nil
    }
}

extension LegalEntity : CaseIterable {
    static var allCases: [LegalEntity] {
        [
            .appleCanada,
            .appleInc,
            .applePty,
            .appleLatamLlc,
            .itunesKk,
            .appleDistributionLtd,
        ]
    }
}

extension LegalEntity : Hashable { }
