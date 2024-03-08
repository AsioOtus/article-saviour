import Foundation

extension Downloader {
	public struct Articles {
		public static let `default` = Self()

		let urlSession = URLSession(configuration: .default)
		let urlService = URLController.default

		public func download (referenceId: String, username: String) async throws -> Data {
			let url = urlService.articleUrl(referenceId: referenceId, username: username)
			let (data, _) = try await download(url)
			return data
		}

		private func download (_ url: URL) async throws -> (Data, URLResponse) {
			try await urlSession.data(from: url)
		}
	}
}
