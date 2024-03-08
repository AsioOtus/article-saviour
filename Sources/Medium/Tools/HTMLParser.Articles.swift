import Foundation
import RegexBuilder
import SwiftSoup

extension HTMLParser {
	struct Articles {
		static let `default` = Self()

		let dateFormatter = DateFormatter.default

		func parseHtml (htmlData: Data) throws -> Article {
			guard let htmlString = String(data: htmlData, encoding: .utf8)
			else { throw HTMLParser.Error.decodingFailure }

			let document: Document = try parse(htmlString)

			let meta = try extractMeta(document: document, htmlString: htmlString)
			try extractContent(document: document)
			try prepareContent(document: document)
			let content = try document.outerHtml()

			let article = Article(
				meta: meta,
				content: content
			)

			return article
		}
	}
}

private extension HTMLParser.Articles {
	func extractContent (document: Document) throws {
		guard 
			let article = try document
				.select("article")
				.first()?
				.select("section")
				.first()?
				.select("div.ab.ca > div:first-child")
				.first(),
			let body = document.body()
		else { throw HTMLParser.Error.parsingFailure("content") }

		try body.html(article.outerHtml())
	}

	func prepareContent (document: Document) throws {
		try document.select("img").forEach { img in
			try img.removeAttr("loading")
			let dataSrc = try img.attr("data-src")
			try img.attr("src", dataSrc)
		}

		let head = document.head()!
		try head.append(
			"""
			<style>
			.ch {
				min-width: 1000px !important;
				padding: 50px !important;
			}
			</style>
			"""
		)
	}

	func extractMeta (document: Document, htmlString: String) throws -> Article.Meta {
		try .init(
			username: username(document: document),
			title: title(document: document),
			date: .init(),//date(htmlString: htmlString),
			tags: tags(document: document)
		)
	}

	func username (document: Document) throws -> String {
		guard let href = try? document.select("a[data-testid=\"authorName\"]").first()?.attr("href")
		else { throw HTMLParser.Error.parsingFailure("username parsing") }

		let nameRegex = Regex {
			"/@"
			Capture {
				OneOrMore(.any)
			}
			Lookahead("?")
		}

		guard let name = href.firstMatch(of: nameRegex)?.output.1
		else { throw HTMLParser.Error.parsingFailure("username regex") }

		return String(name)
	}

	func title (document: Document) throws -> String {
		guard let title = try? document.select("h1.pw-post-title").first()?.text()
		else { throw HTMLParser.Error.parsingFailure("title") }
		return title
	}

	func date (htmlString: String) throws -> Date {
		guard
			let dateSubstring = htmlString.firstMatch(of: #/"datePublished":".*?"/#)?.output,
			let date = dateFormatter.create(String(dateSubstring))
		else { throw HTMLParser.Error.parsingFailure("date") }

		return date
	}

	func tags (document: Document) throws -> Set<String> {
		let tags = try document
			.select("div.qz.ra.ab.iz > div > a > div")
			.map { try $0.text() }
			.compactMap{ $0 }

		return Set(tags)
	}
}
