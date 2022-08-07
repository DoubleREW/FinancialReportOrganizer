import Foundation

struct ResponseMessages : Codable {
	let error : [String]?
	let warn : [String]?
	let info : [String]?

	enum CodingKeys: String, CodingKey {

		case error = "error"
		case warn = "warn"
		case info = "info"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		error = try values.decodeIfPresent([String].self, forKey: .error)
		warn = try values.decodeIfPresent([String].self, forKey: .warn)
		info = try values.decodeIfPresent([String].self, forKey: .info)
	}

}
