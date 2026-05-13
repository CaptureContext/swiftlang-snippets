import Snippets
import ArrayBuilder
import Casification

extension Snippets {
	/// Diamond-bracketed list of generic parameters.
	///
	/// Rendered as empty output if no parameters are provided.
	public struct GenericClause<
		Output: SnippetRepresentableString
	>: Snippet, ExpressibleByArrayLiteral {
		public struct Parameter: Snippet {
			@usableFromInline
			internal let identifier: IdentifierLiteral<Output>

			@usableFromInline
			internal let constraints: TypeComposition<Output>

			public init(
				identifier: IdentifierLiteral<Output>,
				constraints: TypeComposition<Output> = []
			) {
				self.identifier = identifier
				self.constraints = constraints
			}

			@inlinable
			public var content: some Snippet<Output> {
				Join {
					identifier
						.camelCaseMode(.pascal)
					if !constraints.elements.isEmpty {
						Const.colon
						Const.whitespace
						constraints
					}
				}
			}
		}

		@usableFromInline
		internal let parameters: [Parameter]

		public init(_ parameters: [Parameter]) {
			self.parameters = parameters
		}

		@inlinable
		public init(arrayLiteral elements: Parameter...) {
			self.init(elements)
		}

		@inlinable
		public init(_ parameter: Parameter) {
			self.init([parameter])
		}

		@inlinable
		public var content: some Snippet<Output> {
			if parameters.isEmpty {
				Const.empty
			} else {
				Bracket(in: .diamond.withInner(.init(.newline))) {
					Indent {
						Join(Const.comma.suffixed(with: .newline)) {
							parameters
						}
					}
				}
			}
		}
	}
}
