import Snippets
import Dependencies
import Casification

extension Snippets {
	public struct WithCamelCaseMode<
		Output: SnippetRepresentableString,
		Contents: Snippet<Output>
	>: Snippet {
		@usableFromInline
		internal let mode: String.Casification.Configuration.CamelCase.Mode

		@usableFromInline
		internal let contents: Contents

		public init(
			_ mode: String.Casification.Configuration.CamelCase.Mode,
			@SnippetBuilder<Output> content: () -> Contents
		) {
			self.mode = mode
			self.contents = content()
		}

		public func render() -> Output {
			withDependencies {
				$0.snippetCamelCaseMode = mode
			} operation: {
				contents.render()
			}
		}
	}
}

extension Snippet where Output: SnippetRepresentableString {
	@inlinable
	public func camelCaseMode(
		_ mode: String.Casification.Configuration.CamelCase.Mode
	) -> some Snippet<Output> {
		Snippets.WithCamelCaseMode(mode) { self }
	}
}
