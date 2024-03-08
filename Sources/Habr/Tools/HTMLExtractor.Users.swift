import Foundation
import SwiftSoup
import Utils

extension HTMLExtractor {
	struct Users {
		static let `default` = Self()

		func extractArticleSnippet (htmlString: String, username: String) throws -> [Article.Snippet] {
			let document: Document = try parse(htmlString)

			return try document
				.select("article")
				.compactMap { element in
					guard let id = element
						.getAttributes()?
						.first(where: { $0.getKey() == "id" })?
						.getValue()
					else { return nil }

					let title = try title(element: element)

					let hubs = try element
						.select(".tm-publication-hubs > span > a > span:first-child")
						.compactMap { try $0.text() }
						.set()

					let date = try createDate(date(element: element))!

					return Article.Snippet(
						id: id,
						meta: .init(
							username: username,
							title: title,
							date: date,
							hubs: hubs
						)
					)
				}
		}

		func title (element: Element) throws -> String {
			let title = try element.select("h2.tm-title > a > span").first()?.text()

			guard let title else { throw "Title cannot be extracted" }

			return title
		}

		func articleLinks (_ htmlString: String) throws -> [String] {
			let document: Document = try parse(htmlString)

			let postReferences = try document
				.select(".tm-title__link")
				.map {
					$0.getAttributes()?
						.first(where: { attr in attr.getKey() == "href" })?
						.getValue()
				}
				.compactMap { $0 }

			return postReferences
		}

		func date (element: Element) throws -> String? {
			let publicationDate = try element
				.select(".tm-article-datetime-published > time")
				.first()?
				.getAttributes()?
				.first(where: { attr in attr.getKey() == "datetime" })?
				.getValue()

			return publicationDate
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
