import Snippets

extension Snippets {
	/// Swift type expression.
	///
	/// Unlike ``IdentifierLiteral`` this snippet does not normalize or escape
	/// contents, so complex type syntax can be represented as-is.
	public struct TypeExpr<
		Output: SnippetRepresentableString
	>: SnippetExpressibleByLiteral {
		@usableFromInline
		internal let value: AnySnippet<Output>

		public init(_ value: AnySnippet<Output>) {
			self.value = value
		}

		public init(_ value: some Snippet<Output>) {
			self.init(AnySnippet(value))
		}

		@inlinable
		public init(snippetLiteral: Output) {
			self.init(Output.SnippetRepresentation(snippetLiteral: snippetLiteral))
		}

		@inlinable
		public init() {
			self.init(snippetLiteral: "")
		}

		@inlinable
		public var content: some Snippet<Output> {
			value
		}
	}
}
