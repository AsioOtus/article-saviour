import Foundation

extension User {
	public struct Raw {
		public let name: String
		public let articleSnippets: [Article.Snippet]

		public init (
			name: String,
			articleSnippets: [Article.Snippet]
		) {
			self.name = name
			self.articleSnippets = articleSnippets
		}
	}
}
