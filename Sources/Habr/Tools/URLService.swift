import Foundation

public struct URLService {
	static let `default` = Self()

	func userUrl (
		_ username: String,
		_ language: Language
	) -> URL {
		URL(string: "https://habr.com/\(language.rawValue)/users/\(username)")!
	}

	func postUrl (
		_ postId: String,
		_ language: Language
	) -> URL {
		URL(string: "https://habr.com/\(language.rawValue)/post/\(postId)")!
	}

	func addPageComponents (
		username: String,
		language: Language,
		page: Int
	) -> URL {
		addPageComponents(
			userUrl: userUrl(username, language),
			page: page
		)
	}

	func addPageComponents (
		userUrl: URL,
		page: Int
	) -> URL {
		userUrl.appendingPathComponent("publications/articles").appendingPathComponent("page\(String(page))")
	}
}
