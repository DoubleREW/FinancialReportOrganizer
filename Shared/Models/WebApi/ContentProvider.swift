//
//  ContentProvider.swift
//  FinancialReportSplitter
//
//  Created by Fausto Ristagno on 05/08/22.
//

import Foundation

struct ContentProvider : Codable {
    let contentProviderId: Int
    let contentProviderPublicId: String
    let name: String
    let contentProviderTypes: [String]
    let subType: String
}
