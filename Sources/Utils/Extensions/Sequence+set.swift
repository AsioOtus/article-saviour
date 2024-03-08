public extension Sequence where Element: Hashable {
	func set () -> Set<Element> {
		.init(self)
	}
}
