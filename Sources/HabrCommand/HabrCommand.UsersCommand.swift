import ArgumentParser
import Foundation
import Habr
import Logging

extension HabrCommand {
	struct UsersCommand: AsyncParsableCommand {
		private enum CodingKeys: String, CodingKey {
			case userReferences
			case directory
			case language
			case hubs
			case userUserGrouping
			case overwriteExistingFiles
			case useUserInFileName
			case userDateInFileName
		}

		static var configuration = CommandConfiguration(commandName: "users")

		let logger = Logger(label: "UsersDownloader")

		@Argument(parsing: .remaining)
		var userReferences: [String]

		@Option(name: .shortAndLong)
		var directory: String?

		@Option(name: .shortAndLong)
		var language: String?

		@Option(name: .shortAndLong, parsing: .upToNextOption)
		var hubs: [String] = []

		@Flag(name: [.customShort("g"), .customLong("group-by-user")])
		var userUserGrouping: Bool = false

		@Flag(name: [.customShort("o"), .customLong("override-existed-files")])
		var overwriteExistingFiles: Bool = false

		@Flag(name: [.customShort("u"), .customLong("user-in-file-name")])
		var useUserInFileName: Bool = false

		@Flag(name: [.customShort("t"), .customLong("date-in-file-name")])
		var userDateInFileName: Bool = false

		func run () async throws {
			let config = try prepareConfiguration()

			let formattedConfig = ConfigurationFormatter.default.format(config)
			logger.info("\(formattedConfig)")

			await Processor.Users(config: config).process()
		}

		private func prepareConfiguration () throws -> Configuration {
			let directory = try ArgumentsExtractor.default.parse(
				directory: directory ?? FileManager.default.currentDirectoryPath
			)

			let language = try language.map {
				try ArgumentsExtractor.default.extractLanguage(string: $0)
			} ?? Language.default

			let hubs = Set(hubs)

			let usernames = try userReferences
				.compactMap { userReference in
					try ArgumentsExtractor.default.extractUsername(userLink: userReference)
				}
				.uniqued()

			return .init(
				usernames: usernames,
				articles: [],
				directory: directory,
				language: language,
				hubs: hubs,
				useUserGrouping: userUserGrouping,
				overwriteExistingFiles: overwriteExistingFiles,
				useUsername: useUserInFileName,
				useDate: userDateInFileName
			)
		}
	}
}
