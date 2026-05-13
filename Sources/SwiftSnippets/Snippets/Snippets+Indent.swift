import Snippets
import Dependencies
import Foundation

extension Snippets {
	/// Indents rendered expression by 1 level using `currentIndentor` from the environment
	///
	/// Use ``WithIndentor`` snippet to override value for `currentIndentor`
	public struct Indent<
		Output: SnippetRepresentableString,
		Content: Snippet<Output>
	>: Snippet {
		@usableFromInline
		internal let underlying: Content

		public init(
			@SnippetBuilder<Output> content: () -> Content
		) {
			self.underlying = content()
		}

		@inlinable
		public func render() -> Output {
			let indentor = Self.environment(\.currentIndentor).render()
			let source = underlying.render()
			let lines = source.components(separatedBy: .newlines)
			let indented = lines.map { line in
				if line.isEmpty { line }
				else { indentor.appending(line) }
			}
			let result = indented.joined(separator: "\n")
			return Output(stringLiteral: result)
		}
	}
}
