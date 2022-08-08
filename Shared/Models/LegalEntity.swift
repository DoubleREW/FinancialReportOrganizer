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
    let address: String
    let regions: Set<String>

    static let appleCanadaAddress = """
120 Bremner Boulevard, Suite 1600
Toronto, ON M5J 0A8
Canada
"""
    static let appleIncAddress = """
1 Apple Park Way
Cupertino, CA 95014
U.S.A.
"""
    static let applePtyAddress = """
1 Apple Park Way
Cupertino, CA 95014
U.S.A.
"""
    static let appleLatamLlcAddress = """
1 Apple Park Way, MS 169-5CL,
Cupertino, CA 95014
U.S.A.
"""
    static let itunesKkAddress = """
〒 106-6140
6-10-1 Roppongi, Minato-ku, Tokyo
Japan
"""
    static let appleDistributionLtdAddress = """
Internet Software & Services
Hollyhill Industrial Estate
Hollyhill, Cork
Republic of Ireland
VAT ID: IE9700053D
"""

    static let appleCanada: LegalEntity = .init(name: "Apple Canada, Inc.", address: appleCanadaAddress, regions: Set([
        "CA", // Canada
    ]))

    static let appleInc: LegalEntity = .init(name: "Apple Inc.", address: appleIncAddress, regions: Set([
        "US", // United States
    ]))

    static let applePty: LegalEntity = .init(name: "Apple Pty Limited", address: applePtyAddress, regions: Set([
        "AU", // Australia
        "NZ", // New Zeland
    ]))

    static let appleLatamLlc: LegalEntity = .init(name: "Apple Services LATAM LLC", address: appleLatamLlcAddress, regions: Set([
        "LL", // Latin America and the Caribbean
        "BR", // Brazil
        "CO", // Colombia
        "MX", // Mexico
        "M1", // Mexico (Mexico0056)
        "PE", // Peru

        // Listed both in Latin Americas and specific region
        "CL", // Chile
    ]))

    static let itunesKk: LegalEntity = .init(name: "iTunes KK", address: itunesKkAddress, regions: Set([
        "JP", // Japan
    ]))

    static let appleDistributionLtd: LegalEntity = .init(name: "Apple Distribution International Ltd.", address: appleDistributionLtdAddress, regions: Set([
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
