import Foundation

extension Article {
	public struct Content {
		public let meta: Meta
		public let content: String

		public init (
			meta: Meta,
			content: String
		) {
			self.meta = meta
			self.content = content
		}
	}
}

extension Article.Content {
	var info: String {
	"""
		ARTICLE CONTENT
			Username: \(meta.username)
			Title: \(meta.title)
			Date: \(meta.date)
			Hubs: \(meta.hubs.joined(separator: ", "))
	"""
	}
}
