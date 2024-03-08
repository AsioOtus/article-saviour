import Foundation
import Services

public struct Configuration {
	public let usernames: [String]
	public let articles: [String]
	public let directory: URL
	public let language: Language
	public let hubs: Set<String>
	public let useUserGrouping: Bool
	public let overwriteExistingFiles: Bool
	public let useUsername: Bool
	public let useDate: Bool

	public init (
		usernames: [String],
		articles: [String],
		directory: URL,
		language: Language,
		hubs: Set<String>,
		useUserGrouping: Bool,
		overwriteExistingFiles: Bool,
		useUsername: Bool,
		useDate: Bool
	) {
		self.usernames = usernames
		self.articles = articles
		self.directory = directory
		self.language = language
		self.hubs = hubs
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
