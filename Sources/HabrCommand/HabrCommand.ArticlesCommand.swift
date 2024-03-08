import ArgumentParser
import Foundation
import Habr
import Logging

extension HabrCommand {
	struct ArticlesCommand: AsyncParsableCommand {
		private enum CodingKeys: String, CodingKey {
			case userDateInFileName
			case useUserInFileName
			case overwriteExistingFiles
			case userUserGrouping
			case language
			case directory
			case articleReferences
		}

		static var configuration = CommandConfiguration(commandName: "articles")

		let logger = Logger(label: "ArticlesDownloader")

		@Argument(parsing: .remaining)
		var articleReferences: [String]

		@Option(name: .shortAndLong)
		var directory: String?

		@Option(name: .shortAndLong)
		var language: String?

		@Flag(name: [.customShort("g"), .customLong("group-by-user")])
		var userUserGrouping: Bool = false

		@Flag(name: [.customShort("o"), .customLong("override-existed-files")])
		var overwriteExistingFiles: Bool = false

		@Flag(name: [.customShort("u"), .customLong("user-in-file-name")])
		var useUserInFileName: Bool = false

		@Flag(name: [.customShort("t"), .customLong("date-in-file-name")])
		var userDateInFileName: Bool = false

		mutating func run () async throws {
			let config = try prepareConfiguration()

			let formattedConfig = ConfigurationFormatter.default.format(config)
			logger.info("\(formattedConfig)")

			await Processor.Articles(config: config).process()
		}

		private func prepareConfiguration () throws -> Configuration {
			let directory = try ArgumentsExtractor.default.parse(
				directory: directory ?? FileManager.default.currentDirectoryPath
			)

			let articlesId = try articleReferences
				.compactMap { articleReference in
					try ArgumentsExtractor.default.extractArticleId(articleReference: articleReference)
				}
				.uniqued()

			let language = try language.map {
				try ArgumentsExtractor.default.extractLanguage(string: $0)
			} ?? Language.default

			return .init(
				usernames: [],
				articles: articlesId,
				directory: directory,
				language: language,
				hubs: [],
				useUserGrouping: userUserGrouping,
				overwriteExistingFiles: overwriteExistingFiles,
				useUsername: useUserInFileName,
				useDate: userDateInFileName
			)
		}
	}
}
