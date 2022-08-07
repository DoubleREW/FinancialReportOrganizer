import Foundation

struct FinancialReportResponse : Response {
	let data : FinancialReport?
	let messages : ResponseMessages?
	let statusCode : String?
}
