import Foundation

public extension DateFormatter {
	static let `default`: DateFormatter = {
		let f = DateFormatter()
		f.dateFormat = "yyyy.MM.dd"
		return f
	}()

	public func create (_ datetime: String?) -> Date? {
		guard let datetime else { return nil }

		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
		let date = dateFormatter.date(from: datetime)
		return date
	}
}
