//
//  UserDetailResponse.swift
//  FinancialReportOrganizer
//
//  Created by Fausto Ristagno on 05/08/22.
//

import Foundation

struct UserDetailResponse : Response {
    let data : UserDetail?
    let messages : ResponseMessages?
    let statusCode : String?
}
