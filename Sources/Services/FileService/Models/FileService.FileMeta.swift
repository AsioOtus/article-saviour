import Foundation

extension FileService {
	public struct FileMeta {
		public let title: String
		public let username: String
		public let date: Date

		public init (
			title: String,
			username: String,
			date: Date
		) {
			self.title = title
			self.username = username
			self.date = date
		}
	}
}
