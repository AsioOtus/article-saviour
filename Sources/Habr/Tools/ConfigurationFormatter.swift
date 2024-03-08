public struct ConfigurationFormatter {
	public static let `default` = Self()
	
	public func format (_ config: Configuration) -> String {
		"""
		CONFIGURATION
			\(format(collection: config.usernames, label: "Usernames:", isMultiline: true))
			\(format(collection: config.articles, label: "Articles:", isMultiline: true))
			\(format(string: config.useDate.description, label: "Use date in file name:"))
			\(format(string: config.useUsername.description, label: "Use username in file name:"))
			\(format(string: config.overwriteExistingFiles.description, label: "Overwrite existing files:"))
			\(format(string: config.useUserGrouping.description, label: "Use user grouping:"))
			\(format(collection: config.hubs, label: "Hubs:"))
			\(format(string: config.language.rawValue, label: "Language:"))
			\(format(string: config.directory.absoluteString.removingPercentEncoding!, label: "Directory:"))

		"""
	}

	private func format (string: String, label: String) -> String {
		label + " " + string
	}

	private func format (collection: any Collection<String>, label: String, isMultiline: Bool = false) -> String {
		label + (isMultiline ? "\n" : " ") + collection.joined(separator: isMultiline ? "\n\t\t" : ", ")
	}
}
