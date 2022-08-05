import Foundation

struct FinancialReportResponse : Codable {
	let data : FinancialReport?
	let messages : ResponseMessages?
	let statusCode : String?

	enum CodingKeys: String, CodingKey {

		case data = "data"
		case messages = "messages"
		case statusCode = "statusCode"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		data = try values.decodeIfPresent(FinancialReport.self, forKey: .data)
		messages = try values.decodeIfPresent(ResponseMessages.self, forKey: .messages)
		statusCode = try values.decodeIfPresent(String.self, forKey: .statusCode)
	}

}
