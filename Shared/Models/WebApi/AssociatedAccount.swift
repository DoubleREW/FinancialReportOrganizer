//
//  AssociatedAccount.swift
//  FinancialReportOrganizer
//
//  Created by Fausto Ristagno on 05/08/22.
//

import Foundation

struct AssociatedAccount : Codable {
    let contentProvider: ContentProvider
    let roles: [String]
    let lastLogin: Int
}
