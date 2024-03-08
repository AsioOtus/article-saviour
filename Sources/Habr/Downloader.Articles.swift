import Foundation
import OSLog

extension Downloader {
	public struct Articles {
		public static let `default` = Self()

		let urlSession = URLSession(configuration: .default)
		let urlService = URLService.default

		public func download (articleId: String, language: Language) async throws -> Data {
			let url = urlService.postUrl(articleId, language)
			let (data, _) = try await download(url)
			return data
		}

		public func download (_ url: URL) async throws -> (Data, URLResponse) {
			try await urlSession.data(from: url)
		}
	}
}
