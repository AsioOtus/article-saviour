import Foundation
import Logging

extension Downloader {
	public struct Users {
		public static let `default` = Self()

		let logger = Logger(label: "Downloader.Users")

		let urlSession = URLSession(configuration: .default)
		let urlService = URLService.default
		let htmlExtractor = HTMLExtractor.Users.default

		public func downloadArticleSnippets (username: String, language: Language) async throws -> [Article.Snippet] {
			logger.debug("USER \(username) | Download STARTED")

			var currentPage = 1
			var articleSnippets = [Article.Snippet]()

			while true {
				logger.trace("USER \(username) | Page \(currentPage) | Download STARTED")
				let pageUrl = urlService.addPageComponents(
					username: username,
					language: language,
					page: currentPage
				)
				let (data, _) = try await download(pageUrl)

				logger.trace("USER \(username) | Page \(currentPage) | HTML decoding STARTED")
				guard let htmlString = String(data: data, encoding: .utf8)
				else {
					logger.warning("USER \(username) | Page \(currentPage) | HTML decoding failed")
					break
				}

				logger.trace("USER \(username) | Page \(currentPage) | HTML parsing STARTED")
				let currentPageArticleSnippets = try htmlExtractor.extractArticleSnippet(htmlString: htmlString, username: username)
				guard !currentPageArticleSnippets.isEmpty else {
					logger.trace("USER \(username) | Page \(currentPage) | No article snippets on the page")
					break
				}

				articleSnippets.append(contentsOf: currentPageArticleSnippets)

				let formattedArticleIds = currentPageArticleSnippets.isEmpty ? " | No articles" : "\n  " + currentPageArticleSnippets.map(\.id).joined(separator: " ")
				logger.trace("USER \(username) | Page \(currentPage) | Page download COMPLETED | Articles: \(articleSnippets.count)\(formattedArticleIds)")

				currentPage += 1
			}

			let formattedArticleIds = articleSnippets.isEmpty ? " | No articles" : "\n  " + articleSnippets.map(\.id).joined(separator: " ")
			logger.debug("USER \(username) | Download COMPLETED | Pages: \(currentPage - 1) | Articles: \(articleSnippets.count)\(formattedArticleIds)")
			return articleSnippets
		}

		func download (_ url: URL) async throws -> (Data, URLResponse) {
			try await urlSession.data(from: url)
		}
	}
}
