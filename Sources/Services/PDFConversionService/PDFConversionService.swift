import Foundation
import WebKit

public class PDFConversionService: NSObject, WKNavigationDelegate {
	private lazy var webView: WKWebView = {
		let webView: WKWebView = WKWebView()
		webView.navigationDelegate = self
		return webView
	}()

	private var continuation: UnsafeContinuation<Data, Error>?

	@MainActor
	public func convert (htmlString: String) async throws -> Data {
		try await withUnsafeThrowingContinuation { continuation in
			self.continuation = continuation
			webView.loadHTMLString(htmlString, baseURL: nil)
		}
	}

	public func webView (_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		webView.createPDF { result in
			switch result {
			case .success(let success):
				self.continuation?.resume(returning: success)

			case .failure(let failure):
				self.continuation?.resume(throwing: failure)
			}
		}
	}

	public func webView (_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
		continuation?.resume(throwing: error)
	}

	public func webView (_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
		continuation?.resume(throwing: error)
	}
}
