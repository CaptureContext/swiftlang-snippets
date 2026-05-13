import Snippets

extension Snippets {
	public struct TupleExpr<
		Output: SnippetRepresentableString
	>: Snippet, ExpressibleByArrayLiteral {
		public struct Component: Snippet {
			@usableFromInline
			internal var label: IdentifierLiteral<Output>?

			@usableFromInline
			internal var value: AnySnippet<Output>

			public init(
				label: IdentifierLiteral<Output>? = nil,
				value: AnySnippet<Output>
			) {
				self.label = label
				self.value = value
			}

			public init(
				label: IdentifierLiteral<Output>? = nil,
				value: some Snippet<Output>
			) {
				self.init(
					label: label,
					value: AnySnippet(value)
				)
			}

			@inlinable
			public var content: some Snippet<Output> {
				Join(.const(.colon.suffixed(with: .whitespace))) {
					label
					value
				}
				.skipEmpty()
			}
		}

		@usableFromInline
		internal let components: [Component]

		@usableFromInline
		var isMultiline: Bool { components.count > 2 }

		public init(_ components: [Component]) {
			self.components = components
		}

		@inlinable
		public init(arrayLiteral elements: Component...) {
			self.init(elements)
		}

		@inlinable
		public init(
			component: Component
		) {
			self.init([component])
		}

		public var content: some Snippet<Output> {
			Bracket(in: .parenthesis) {
				if isMultiline {
					Indent {
						Join(.const(.comma.suffixed(with: .newline))) {
							components
						}
					}
				} else {
					Join(.const(.comma.suffixed(with: .whitespace))) {
						components
					}
				}
			}
		}
	}
}
