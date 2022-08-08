//
//  Response.swift
//  FinancialReportOrganizer
//
//  Created by Fausto Ristagno on 05/08/22.
//

import Foundation

protocol Response : Codable {
    associatedtype Payload

    var data : Payload? { get }
    var messages : ResponseMessages? { get }
    var statusCode : String? { get }

    init(data: Payload?, messages: ResponseMessages?, statusCode: String?)
}

enum ResponseCodingKeys: String, CodingKey {
    case data = "data"
    case messages = "messages"
    case statusCode = "statusCode"
}

extension Response where Payload : Codable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: ResponseCodingKeys.self)
        let data = try values.decodeIfPresent(Payload.self, forKey: .data)
        let messages = try values.decodeIfPresent(ResponseMessages.self, forKey: .messages)
        let statusCode = try values.decodeIfPresent(String.self, forKey: .statusCode)

        self.init(data: data, messages: messages, statusCode: statusCode)
    }
}
