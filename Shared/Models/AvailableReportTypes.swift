import Foundation

struct AvailableReportTypes : Codable {
	let name : String
	let displayKey : String?

	enum CodingKeys: String, CodingKey {

		case name = "name"
		case displayKey = "displayKey"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		name = try values.decode(String.self, forKey: .name)
		displayKey = try values.decodeIfPresent(String.self, forKey: .displayKey)
	}

}
