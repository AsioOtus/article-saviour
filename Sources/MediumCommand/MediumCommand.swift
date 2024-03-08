import ArgumentParser

public struct MediumCommand: AsyncParsableCommand {
	public static var configuration = CommandConfiguration(
		commandName: "medium",
		subcommands: [MediumCommand.ArticlesCommand.self],
		defaultSubcommand: MediumCommand.ArticlesCommand.self
	)

	public init () { }
}
