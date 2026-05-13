import Snippets
import ArrayBuilder

extension Snippets {
	/// Where clause for generic constraints.
	///
	/// Includes `where` keyword, rendered as empty output if no requirements are provided.
	public struct WhereClause<
		Output: SnippetRepresentableString
	>: Snippet, ExpressibleByArrayLiteral {
		public struct Requirement: Snippet {
			@usableFromInline
			internal let subject: TypeExpr<Output>

			@usableFromInline
			internal let constraints: TypeComposition<Output>

			public init(
				subject: TypeExpr<Output>,
				constraints: TypeComposition<Output>
			) {
				self.subject = subject
				self.constraints = constraints
			}

			@inlinable
			public var content: some Snippet<Output> {
				Join {
					subject
					Const.colon
					Const.whitespace
					constraints
				}
			}
		}

		@usableFromInline
		internal let requirements: [Requirement]

		public init(_ requirements: [Requirement]) {
			self.requirements = requirements
		}

		@inlinable
		public init(arrayLiteral elements: Requirement...) {
			self.init(elements)
		}

		@inlinable
		public init(_ requirement: Requirement) {
			self.init([requirement])
		}

		@inlinable
		public var content: some Snippet<Output> {
			if requirements.isEmpty {
				Const.empty
			} else {
				Join {
					"where "
					Const.newline
					Indent {
						Join(Const.comma.suffixed(with: .newline)) {
							requirements
						}
					}
				}
			}
		}
	}
}
