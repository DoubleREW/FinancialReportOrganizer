import Foundation

struct RegionCurrency : Codable {
	let regionCurrencyId : Int
	let regionId : Int
	let regionCode : String
	let regionName : String
	let regionNameKey : String
	let currencyCode : String

	enum CodingKeys: String, CodingKey {

		case regionCurrencyId = "regionCurrencyId"
		case regionId = "regionId"
		case regionCode = "regionCode"
		case regionName = "regionName"
		case regionNameKey = "regionNameKey"
		case currencyCode = "currencyCode"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		regionCurrencyId = try values.decode(Int.self, forKey: .regionCurrencyId)
		regionId = try values.decode(Int.self, forKey: .regionId)
		regionCode = try values.decode(String.self, forKey: .regionCode)
		regionName = try values.decode(String.self, forKey: .regionName)
		regionNameKey = try values.decode(String.self, forKey: .regionNameKey)
		currencyCode = try values.decode(String.self, forKey: .currencyCode)
	}

}

extension RegionCurrency : Identifiable {
    var id: Int {
        return regionId
    }
}
