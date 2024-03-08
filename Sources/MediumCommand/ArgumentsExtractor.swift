import Foundation
import Medium
import RegexBuilder

struct ArgumentsExtractor {
	static let `default` = ArgumentsExtractor()

	func extractArticleReference (articleReference: String) throws -> Article.Reference {
		let stringStart = ChoiceOf {
			OneOrMore {
				OneOrMore(.any)
				"medium.com/"
			}
			"medium.com/"
			"/"
			Anchor.startOfLine
		}

		let usernameCapture = Capture {
			OneOrMore(.any)
			Lookahead("/")
		}

		let articleIdCapture = Capture {
			OneOrMore(.word)
			Lookahead {
				ChoiceOf {
					"/"
					Anchor.endOfLine
				}
			}
		}

		let regex = Regex {
			stringStart
			Optionally("@")
			usernameCapture
			"/"
			Optionally {
				OneOrMore(.any)
				"-"
			}
			articleIdCapture
		}

		guard let (_, username, articleId) = articleReference.firstMatch(of: regex)?.output
		else { throw "Reference '\(articleReference)' parsing failed" }

		let articleReference = Article.Reference(
			referenceId: String(articleId),
			username: String(username)
		)

		return articleReference
	}

	func parse (directory: String) throws -> URL {
		let directoryUrl = URL(filePath: directory)
		let isDirectory = (try directoryUrl.resourceValues(forKeys: [.isDirectoryKey])).isDirectory
		guard isDirectory == true else { throw "Path is not a directory or does not exist: \(directory)" }

		return directoryUrl
	}
}
