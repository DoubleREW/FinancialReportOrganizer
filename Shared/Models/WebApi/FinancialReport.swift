import Foundation

struct FinancialReport : Codable {
	let vendorName : String
	let sapVendorNumber : Int
	let lastSoldUnit : Int
	let reportDate : String
	let updatedDate : String
	let isPooled : Bool
	let isArcadeVendor : Bool
	let providerId : Int
	let hasConsolidatedReport : Bool
	let hasDetailedConsolidatedReport : Bool
	let hasSingaporeGSTReport : Bool
	let hasMalaysianSSTReport : Bool
	let hasThailandTOCReport : Bool
	let hasVendorTaxReport : Bool
	let reportSummaries : [ReportSummaries]

	enum CodingKeys: String, CodingKey {

		case vendorName = "vendorName"
		case sapVendorNumber = "sapVendorNumber"
		case lastSoldUnit = "lastSoldUnit"
		case reportDate = "reportDate"
		case updatedDate = "updatedDate"
		case isPooled = "isPooled"
		case isArcadeVendor = "isArcadeVendor"
		case providerId = "providerId"
		case hasConsolidatedReport = "hasConsolidatedReport"
		case hasDetailedConsolidatedReport = "hasDetailedConsolidatedReport"
		case hasSingaporeGSTReport = "hasSingaporeGSTReport"
		case hasMalaysianSSTReport = "hasMalaysianSSTReport"
		case hasThailandTOCReport = "hasThailandTOCReport"
		case hasVendorTaxReport = "hasVendorTaxReport"
		case reportSummaries = "reportSummaries"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		vendorName = try values.decode(String.self, forKey: .vendorName)
		sapVendorNumber = try values.decode(Int.self, forKey: .sapVendorNumber)
		lastSoldUnit = try values.decode(Int.self, forKey: .lastSoldUnit)
		reportDate = try values.decode(String.self, forKey: .reportDate)
		updatedDate = try values.decode(String.self, forKey: .updatedDate)
		isPooled = try values.decode(Bool.self, forKey: .isPooled)
		isArcadeVendor = try values.decode(Bool.self, forKey: .isArcadeVendor)
		providerId = try values.decode(Int.self, forKey: .providerId)
		hasConsolidatedReport = try values.decode(Bool.self, forKey: .hasConsolidatedReport)
		hasDetailedConsolidatedReport = try values.decode(Bool.self, forKey: .hasDetailedConsolidatedReport)
		hasSingaporeGSTReport = try values.decode(Bool.self, forKey: .hasSingaporeGSTReport)
		hasMalaysianSSTReport = try values.decode(Bool.self, forKey: .hasMalaysianSSTReport)
		hasThailandTOCReport = try values.decode(Bool.self, forKey: .hasThailandTOCReport)
		hasVendorTaxReport = try values.decode(Bool.self, forKey: .hasVendorTaxReport)
		reportSummaries = try values.decode([ReportSummaries].self, forKey: .reportSummaries)
	}

}

extension FinancialReport : Identifiable {
    var id: String {
        return "\(sapVendorNumber)_\(reportDate)"
    }
}
