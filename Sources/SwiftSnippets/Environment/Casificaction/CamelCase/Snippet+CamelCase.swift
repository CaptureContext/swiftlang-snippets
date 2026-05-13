import Snippets
import Casification
import SwiftKeywords

extension Snippets {
	public struct CamelCaseLiteral<
		Output: SnippetRepresentableString
	>: SnippetExpressibleByLiteral {
		@usableFromInline
		internal let literal: Output.SnippetRepresentation

		public init(snippetLiteral: Output) {
			self.literal = snippetLiteral.makeSnippet()
		}

		public init() {
			self.init(snippetLiteral: .const(""))
		}

		@inlinable
		public func render() -> Output {
			let mode = Self.environment(\.currentCamelCaseMode)
			let outputString = String(literal.render()).case(.camel(mode))
			return Output(stringLiteral: outputString)
		}
	}

	public struct CamelCase<
		Output: SnippetRepresentableString,
		Contents: Snippet<Output>
	>: Snippet {
		@usableFromInline
		internal let contents: Contents

		public init(
			@SnippetBuilder<Output> content: () -> Contents
		) {
			self.contents = content()
		}

		@inlinable
		public func render() -> Output {
			let mode = Self.environment(\.currentCamelCaseMode)
			let outputString = String(contents.render()).case(.camel(mode))
			return Output(stringLiteral: outputString)
		}
	}
}

extension Snippet where Output: SnippetRepresentableString {
	public func camelCase() -> some Snippet<Output> {
		Snippets.CamelCase { self }
	}

	public func camelCase(
		_ mode: String.Casification.Configuration.CamelCase.Mode
	) -> some Snippet<Output> {
		Snippets.CamelCase { self }.camelCaseMode(mode)
	}
}
