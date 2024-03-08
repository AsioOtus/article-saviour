import Foundation

extension Article {
	public struct Meta {
		public let username: String
		public let title: String
		public let date: Date
		public let hubs: Set<String>

		public init (
			username: String,
			title: String,
			date: Date,
			hubs: Set<String>
		) {
			self.username = username
			self.title = title
			self.date = date
			self.hubs = hubs
		}
	}
}
