public struct HubsFilter {
	public static let `default` = Self()

	public func filterArticleSnippets (
		articleSnippets: [Article.Snippet],
		hubs: Set<String>
	) -> [Article.Snippet] {
		guard !hubs.isEmpty
		else { return articleSnippets }

		return articleSnippets.filter { !$0.meta.hubs.isDisjoint(with: hubs) }
	}
}
