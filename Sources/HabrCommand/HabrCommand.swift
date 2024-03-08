import ArgumentParser

public struct HabrCommand: AsyncParsableCommand {
	public static var configuration = CommandConfiguration(
		commandName: "habr",
		subcommands: [HabrCommand.ArticlesCommand.self, HabrCommand.UsersCommand.self],
		defaultSubcommand: HabrCommand.ArticlesCommand.self
	)

	public init () { }
}
