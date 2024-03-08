import ArgumentParser
import HabrCommand
import MediumCommand
import Logging
import LoggingFormatAndPipe
import Utils

@main
struct ArticleSaviourCLI: AsyncParsableCommand {
	private static let loggingSystemInitialization = DispatchOnce {
		LoggingSystem.bootstrap { _ in
			var handler = Handler(
				formatter: BasicFormatter([.message]),
				pipe: LoggerTextOutputStreamPipe.standardOutput
			)
			handler.logLevel = .info
			return handler
		}
	}

	init () {
		Self.loggingSystemInitialization.perform()
	}
}

extension ArticleSaviourCLI {
	static let version = "1.0.0"
	static let commandName = "savea"
	static let versionString = "\(commandName) v\(version)"

	static var configuration = CommandConfiguration(
		commandName: commandName,
		abstract: "Utility for downloading articles from habr.com and medium.com.\n\(versionString)",
		version: versionString,
		subcommands: [
			HabrCommand.self,
			MediumCommand.self,
		],
		defaultSubcommand: HabrCommand.self
	)
}
