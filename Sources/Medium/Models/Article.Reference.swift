extension Article {
	public struct Reference: Hashable {
		let referenceId: String
		let username: String

		public init (
			referenceId: String,
			username: String
		) {
			self.referenceId = referenceId
			self.username = username
		}
	}
}

extension Article.Reference: CustomStringConvertible {
	public var description: String {
		username + "/" + referenceId
	}
}
