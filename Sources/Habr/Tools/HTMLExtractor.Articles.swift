import Foundation
import SwiftSoup

extension HTMLExtractor {
	public struct Articles {
		public static let `default` = Self()
		
		public func extractArticleContent (htmlData: Data) throws -> Article.Content {
			guard let htmlString = String(data: htmlData, encoding: .utf8) 
			else { throw "Can not decode HTML data" }

			return try extractArticleContent(htmlString: htmlString)
		}

		public func extractArticleContent (htmlString: String) throws -> Article.Content {
			let username = try username(from: htmlString)
			let title =    try title(from: htmlString)
			let date =     try createDate(date(from: htmlString))! // TODO: Remove forced unwrapping
			let hubs =     try hubs(from: htmlString)
			let content =  try content(from: htmlString)
			
			return .init(
				meta: .init(
					username: username,
					title: title,
					date: date,
					hubs: hubs
				),
				content: content
			)
		}
		
		func username (from postHtmlString: String) throws -> String {
			let document: Document = try parse(postHtmlString)
			let name = try document.select(".tm-user-info__username").first()?.text()

			guard let name else { throw "Name cannot be extracted" }

			return name
		}
		
		func title (from postHtmlString: String) throws -> String {
			let document: Document = try parse(postHtmlString)
			let title = try document.select("h1.tm-title_h1 > span").first()!.text()
			return title
		}
		
		func date (from postHtmlString: String) throws -> String? {
			let document: Document = try parse(postHtmlString)
			
			let publicationDate = try document
				.select(".tm-article-datetime-published > time")
				.first()?
				.getAttributes()?
				.first(where: { attr in attr.getKey() == "datetime" })?
				.getValue()
			
			return publicationDate
		}
		
		func hubs (from postHtmlString: String) throws -> Set<String> {
			let document: Document = try parse(postHtmlString)
			
			let hubs = try document
				.select(".tm-publication-hubs > span > a > span:first-child")
				.map { try $0.text() }
				.compactMap{ $0 }
			
			return Set(hubs)
		}
		
		func content (from postHtmlString: String) throws -> String {
			let document: Document = try parse(postHtmlString)
			
			let article = try document.select("main").first()!.select("article").first()!
			try article.attr("style", "background-color:#fff")
			
			let body = document.body()!
			try body.html(article.outerHtml())
			try body.select("img").forEach { img in
				try img.removeAttr("src")
				let dataSrc = try img.attr("data-src")
				try img.attr("src", dataSrc)
			}

			try body.select(".spoiler").forEach { spoiler in
				try spoiler.addClass("spoiler_open")
			}

			let head = document.head()!
			try head.append(
				"""
				<style>
				body, html, .tm-page-width {
					min-width: 1000px !important;
				}
				article {
					padding: 50px !important;
				}
				</style>
				"""
			)

			return try document.outerHtml()
		}
		
		private func createDate (_ datetime: String?) -> Date? {
			guard let datetime = datetime else { return nil }
			
			let dateFormatter = DateFormatter()
			dateFormatter.locale = Locale(identifier: "en_US_POSIX")
			dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
			let date = dateFormatter.date(from: datetime)
			return date
		}
	}
}
