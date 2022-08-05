import Foundation

struct ReportSummaries : Codable {
	let status : String
	let returnMessage : String?
	let rejectMessageKey : String?
	let amount : String
	let currency : String
	let bankName : String
	let maskedBankAccount : String
	let isPaymentExpected : Bool
	let paidOrExpectingPaymentDate : String
	let proceedsByRegion : [ProceedsByRegion]
	let externalPaymentIdentifier : String
	let lastFourDigitOfBankAccountNumber : String

	enum CodingKeys: String, CodingKey {

		case status = "status"
		case returnMessage = "returnMessage"
		case rejectMessageKey = "rejectMessageKey"
		case amount = "amount"
		case currency = "currency"
		case bankName = "bankName"
		case maskedBankAccount = "maskedBankAccount"
		case isPaymentExpected = "isPaymentExpected"
		case paidOrExpectingPaymentDate = "paidOrExpectingPaymentDate"
		case proceedsByRegion = "proceedsByRegion"
		case externalPaymentIdentifier = "externalPaymentIdentifier"
		case lastFourDigitOfBankAccountNumber = "lastFourDigitOfBankAccountNumber"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		status = try values.decode(String.self, forKey: .status)
		returnMessage = try values.decodeIfPresent(String.self, forKey: .returnMessage)
		rejectMessageKey = try values.decodeIfPresent(String.self, forKey: .rejectMessageKey)
		amount = try values.decode(String.self, forKey: .amount)
		currency = try values.decode(String.self, forKey: .currency)
		bankName = try values.decode(String.self, forKey: .bankName)
		maskedBankAccount = try values.decode(String.self, forKey: .maskedBankAccount)
		isPaymentExpected = try values.decode(Bool.self, forKey: .isPaymentExpected)
		paidOrExpectingPaymentDate = try values.decode(String.self, forKey: .paidOrExpectingPaymentDate)
		proceedsByRegion = try values.decode([ProceedsByRegion].self, forKey: .proceedsByRegion)
		externalPaymentIdentifier = try values.decode(String.self, forKey: .externalPaymentIdentifier)
		lastFourDigitOfBankAccountNumber = try values.decode(String.self, forKey: .lastFourDigitOfBankAccountNumber)
	}

}
