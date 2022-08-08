//
//  SapVendorNumbersResponse.swift
//  FinancialReportOrganizer
//
//  Created by Fausto Ristagno on 05/08/22.
//

import Foundation

struct SapVendorNumbersResponse : Response {
    let data : [SapVendorNumber]?
    let messages : ResponseMessages?
    let statusCode : String?
}
