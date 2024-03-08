import ArgumentParser
import Foundation
import Logging
import Medium
import Utils

extension MediumCommand {
	struct ArticlesCommand: AsyncParsableCommand {
		private enum CodingKeys: String, CodingKey {
			case articleReferences
			case useDateInFileName
			case useUserInFileName
			case overwriteExistingFiles
			case useUserGrouping
			case directory
		}

		static var configuration = CommandConfiguration(commandName: "articles")

		let logger = Logger(label: "ArticlesDownloader")

		let argumentExtractor = ArgumentsExtractor.default
		let configurationFormatter = MediumConfigurationFormatter.default

		@Argument(parsing: .remaining)
		var articleReferences: [String]

		@Option(name: .shortAndLong)
		var directory: String?

		@Flag(name: [.customShort("g"), .customLong("group-by-user")])
		var useUserGrouping: Bool = false

		@Flag(name: [.customShort("o"), .customLong("override-existed-files")])
		var overwriteExistingFiles: Bool = false

		@Flag(name: [.customShort("u"), .customLong("user-in-file-name")])
		var useUserInFileName: Bool = false

		@Flag(name: [.customShort("t"), .customLong("date-in-file-name")])
		var useDateInFileName: Bool = false

		mutating func run () async throws {
			let config = try prepareConfiguration()

			let formattedConfig = configurationFormatter.format(config)
			logger.info("\n\(formattedConfig)")

			await Processor.Articles(config: config).process()
		}

		private func prepareConfiguration () throws -> Configuration {
			let directory = try argumentExtractor.parse(
				directory: directory ?? FileManager.default.currentDirectoryPath
			)

			let articleReferences = articleReferences
				.compactMap { articleReference in
					do {
						return try argumentExtractor.extractArticleReference(articleReference: articleReference)
					} catch {
						logger.error("\(error.localizedDescription)")
						return nil
					}
				}
				.uniqued()

			return .init(
				usernames: [],
				articleReferences: articleReferences,
				directory: directory,
				tags: [],
				useUserGrouping: useUserGrouping,
				overwriteExistingFiles: overwriteExistingFiles,
				useUsername: useUserInFileName,
				useDate: useDateInFileName
			)
		}
	}
}
