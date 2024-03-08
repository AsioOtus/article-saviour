import Foundation
import Utils

extension FileService {
	struct FileNameFormatter {
		let config: Configuration

		let dateFormatter = DateFormatter.default

		func format (
			_ fileMeta: FileMeta,
			_ config: Configuration
		) -> String {
			var fileName = prepareTitle(fileMeta.title)

			if config.useDate {
				fileName = "\(dateFormatter.string(from: fileMeta.date)) – \(fileName)"
			}

			if config.useUsername {
				fileName = "\(fileMeta.username) – \(fileName)"
			}

			return fileName
		}

		func prepareTitle (_ title: String) -> String {
			var title = title
				.replacingOccurrences(of: ":", with: " -")
				.replacingOccurrences(of: "/", with: "|")

			if title.hasSuffix(".") {
				title.removeLast()
			}

			return title
		}
	}
}
