import Foundation

extension HTMLParser {
	enum Error: Swift.Error {
		case decodingFailure
		case parsingFailure(String)
	}
}

extension HTMLParser.Error: LocalizedError {
	public var errorDescription: String? {
		switch self {
		case .decodingFailure:
			"Decoding failure"
		case .parsingFailure(let error):
			"Parsing failure – \(error)"
		}
	}
}
