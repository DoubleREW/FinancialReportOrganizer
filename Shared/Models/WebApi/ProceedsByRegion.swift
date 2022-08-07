import Foundation

struct ProceedsByRegion : Codable {
	let regionCurrency : RegionCurrency
	let financialReportType : String
	let unitsSold : Int
	let beginBalance : String
	let earned : String
	let total : String
	let taxesAndFees : String
	let withHoldingTax : String
	let withHoldingTaxAndAdjustment : String
	let inputTax : String
	let inputTaxDetails : [String]
	let adjustmentAmount : String
	let totalOwed : String
	let exchangeRate : String
	let proceeds : String
	let availableReportTypes : [AvailableReportTypes]

	enum CodingKeys: String, CodingKey {

		case regionCurrency = "regionCurrency"
		case financialReportType = "financialReportType"
		case unitsSold = "unitsSold"
		case beginBalance = "beginBalance"
		case earned = "earned"
		case total = "total"
		case taxesAndFees = "taxesAndFees"
		case withHoldingTax = "withHoldingTax"
		case withHoldingTaxAndAdjustment = "withHoldingTaxAndAdjustment"
		case inputTax = "inputTax"
		case inputTaxDetails = "inputTaxDetails"
		case adjustmentAmount = "adjustmentAmount"
		case totalOwed = "totalOwed"
		case exchangeRate = "exchangeRate"
		case proceeds = "proceeds"
		case availableReportTypes = "availableReportTypes"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		regionCurrency = try values.decode(RegionCurrency.self, forKey: .regionCurrency)
		financialReportType = try values.decode(String.self, forKey: .financialReportType)
		unitsSold = try values.decode(Int.self, forKey: .unitsSold)
		beginBalance = try values.decode(String.self, forKey: .beginBalance)
		earned = try values.decode(String.self, forKey: .earned)
		total = try values.decode(String.self, forKey: .total)
		taxesAndFees = try values.decode(String.self, forKey: .taxesAndFees)
		withHoldingTax = try values.decode(String.self, forKey: .withHoldingTax)
		withHoldingTaxAndAdjustment = try values.decode(String.self, forKey: .withHoldingTaxAndAdjustment)
		inputTax = try values.decode(String.self, forKey: .inputTax)
		inputTaxDetails = try values.decode([String].self, forKey: .inputTaxDetails)
		adjustmentAmount = try values.decode(String.self, forKey: .adjustmentAmount)
		totalOwed = try values.decode(String.self, forKey: .totalOwed)
		exchangeRate = try values.decode(String.self, forKey: .exchangeRate)
		proceeds = try values.decode(String.self, forKey: .proceeds)
		availableReportTypes = try values.decode([AvailableReportTypes].self, forKey: .availableReportTypes)
	}

}

extension ProceedsByRegion : Identifiable {
    var id: Int {
        return regionCurrency.regionId
    }
}
