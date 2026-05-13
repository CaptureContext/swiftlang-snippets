import Snippets
import Dependencies
import Casification

extension Snippets {
	public struct WithCasification<
		Output: SnippetRepresentableString,
		Contents: Snippet<Output>
	>: Snippet {
		@usableFromInline
		internal let config: String.Casification.Configuration

		@usableFromInline
		internal let contents: Contents

		public init(
			_ config: String.Casification.Configuration = .current,
			@SnippetBuilder<Output> content: () -> Contents
		) {
			self.config = config
			self.contents = content()
		}

		public func render() -> Output {
			withCasification(config) { contents.render() }
		}
	}
}

extension Snippet where Output: SnippetRepresentableString {
	@inlinable
	public func casification(_ config: String.Casification.Configuration) -> some Snippet<Output> {
		Snippets.WithCasification(config) { self }
	}

	@inlinable
	public func casification<Value>(
		_ keyPath: WritableKeyPath<
			String.Casification.Configuration,
			Value
		>,
		_ newValue: Value
	) -> some Snippet<Output> {
		var config = Self.environment(\.currentCasification)
		config[keyPath: keyPath] = newValue
		return casification(config)
	}
}
