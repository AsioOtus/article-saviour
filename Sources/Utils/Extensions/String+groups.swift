import Foundation

public extension String {
	func groups (for regex: NSRegularExpression) throws -> [[String]] {
		let matches = regex.matches(
			in: self,
			range: NSRange(self.startIndex..., in: self)
		)

		return matches.map { match in
			(0..<match.numberOfRanges).map {
				let rangeBounds = match.range(at: $0)
				guard let range = Range(rangeBounds, in: self) else { return "" }
				return String(self[range])
			}
		}
	}
}
