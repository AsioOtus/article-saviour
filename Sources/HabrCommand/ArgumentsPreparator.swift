import Foundation
import Habr

struct ArgumentsExtractor {
	static let `default` = ArgumentsExtractor()
}

extension ArgumentsExtractor {
	func extractUsername (userLink: String) throws -> String? {
		if let username = try userLink.groups(for: try NSRegularExpression(pattern: #"habr\.com\/.*\/users\/([\w-]*)"#)).first?[safe: 1] { // TODO: Добавить обработку невалидных адресов
			return username
		} else if let _ = userLink.range(of: #"\w*"#, options: .regularExpression) {
			return userLink
		} else {
			return nil
		}
	}

	func extractArticleId (articleReference: String) throws -> String? {
		if let articleId = try articleReference.groups(for: try NSRegularExpression(pattern: #"habr\.com\/.*\/articles\/(\d*)"#)).first?[safe: 1] {
			return articleId
		} else if let _ = articleReference.range(of: #"\d*"#, options: .regularExpression) {
			return articleReference
		} else {
			return nil
		}
	}

	func extractArticleId (articleRelativePath: String) throws -> String? {
		if let articleId = try articleRelativePath.groups(for: try NSRegularExpression(pattern: #"articles\/(\d*)"#)).first?[safe: 1] {
			return articleId
		} else if let articleId = try articleRelativePath.groups(for: try NSRegularExpression(pattern: #"blog\/(\d*)"#)).first?[safe: 1] {
			return articleId
		} else if let _ = try articleRelativePath.groups(for: try NSRegularExpression(pattern: #"\d*"#)).first?[safe: 1] {
			return articleRelativePath
		} else {
			return nil
		}
	}

	func parse (directory: String) throws -> URL {
		let directoryUrl = URL(filePath: directory)
		guard !directoryUrl.isFileURL else { throw "Path is not a directory: \(directory)" }
		guard FileManager.default.fileExists(atPath: directoryUrl.absoluteString) else { throw "Path does not exist: \(directory)" }

		return directoryUrl
	}

	func extractLanguage (string: String) throws -> Language {
		guard let language = Language(rawValue: string)
		else { throw "Unsopported language: \(string) | Supported languages: \(Language.allCases.map { $0.rawValue }.joined(separator: ", "))" }

		return language
	}
}
