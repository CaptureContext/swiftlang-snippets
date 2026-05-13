import Snippets

extension Snippets {
	/// Swift type composition (`First & Second`).
	public struct TypeComposition<
		Output: SnippetRepresentableString
	>: Snippet, ExpressibleByArrayLiteral {
		@usableFromInline
		internal let elements: [TypeExpr<Output>]

		public init(_ elements: [TypeExpr<Output>]) {
			self.elements = elements
		}

		@inlinable
		public init(arrayLiteral elements: TypeExpr<Output>...) {
			self.init(elements)
		}

		@inlinable
		public init(_ element: TypeExpr<Output>) {
			self.init([element])
		}

		@inlinable
		public var content: some Snippet<Output> {
			Join(Const(snippetLiteral: " & ")) {
				elements
			}
			.skipEmpty()
		}
	}

	/// Type inheritance clause (`: First, Second`).
	public struct TypeInheritanceClause<
		Output: SnippetRepresentableString
	>: Snippet, ExpressibleByArrayLiteral {
		@usableFromInline
		internal let elements: [TypeComposition<Output>]

		public init(_ elements: [TypeComposition<Output>]) {
			self.elements = elements
		}

		@inlinable
		public init(arrayLiteral elements: TypeComposition<Output>...) {
			self.init(elements)
		}

		@inlinable
		public init(_ element: TypeComposition<Output>) {
			self.init([element])
		}

		@inlinable
		public var content: some Snippet<Output> {
			if elements.isEmpty {
				Const.empty
			} else {
				Join {
					Const.colon
					Const.whitespace
					Join(Const.comma.suffixed(with: .whitespace)) {
						elements
					}
				}
			}
		}
	}
}
