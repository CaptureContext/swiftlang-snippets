import Snippets
import Dependencies

extension Snippets {
	public struct WithIndentor<
		Output: SnippetRepresentableString,
		Indentor: Snippet<Output>,
		Contents: Snippet<Output>
	>: Snippet {
		@usableFromInline
		internal let indentor: Indentor

		@usableFromInline
		internal let contents: Contents

		public init(
			_ indentor: Indentor,
			@SnippetBuilder<Output> content: () -> Contents
		) {
			self.indentor = indentor
			self.contents = content()
		}

		public func render() -> Output {
			withDependencies {
				$0[snippetIndentorOf: .type(Output.self)] = AnySnippet(indentor)
			} operation: {
				contents.render()
			}
		}
	}
}

extension Snippet where Output: SnippetRepresentableString {
	@inlinable
	public func indentor(_ indentor: some Snippet<Output>) -> some Snippet<Output> {
		Snippets.WithIndentor(indentor) { self }
	}
}
