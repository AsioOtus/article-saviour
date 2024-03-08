import Foundation
import Services

public struct Configuration {
	public let usernames: [String]
	public let articleReferences: [Article.Reference]
	public let directory: URL
	public let tags: Set<String>
	public let useUserGrouping: Bool
	public let overwriteExistingFiles: Bool
	public let useUsername: Bool
	public let useDate: Bool

	public init (
		usernames: [String],
		articleReferences: [Article.Reference],
		directory: URL,
		tags: Set<String>,
		useUserGrouping: Bool,
		overwriteExistingFiles: Bool,
		useUsername: Bool,
		useDate: Bool
	) {
		self.usernames = usernames
		self.articleReferences = articleReferences
		self.directory = directory
		self.tags = tags
		self.useUserGrouping = useUserGrouping
		self.overwriteExistingFiles = overwriteExistingFiles
		self.useUsername = useUsername
		self.useDate = useDate
	}

	var fileServiceConfiguration: FileService.Configuration {
		.init(
			directory: directory,
			useUserGrouping: useUserGrouping,
			overwriteExistingFiles: overwriteExistingFiles,
			useUsername: useUsername,
			useDate: useDate
		)
	}
}
