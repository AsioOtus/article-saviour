import Foundation

extension FileService {
	public struct Configuration {
		public let directory: URL
		public let useUserGrouping: Bool
		public let overwriteExistingFiles: Bool
		public let useUsername: Bool
		public let useDate: Bool

		public init (
			directory: URL,
			useUserGrouping: Bool,
			overwriteExistingFiles: Bool,
			useUsername: Bool,
			useDate: Bool
		) {
			self.directory = directory
			self.useUserGrouping = useUserGrouping
			self.overwriteExistingFiles = overwriteExistingFiles
			self.useUsername = useUsername
			self.useDate = useDate
		}
	}
}
