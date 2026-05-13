import Snippets
import Casification

extension Snippets {
	/// Snippet for Swift type extension declaration
	public struct EnumDecl<
		Output: SnippetRepresentableString,
		Body: Snippet<Output>
	>: Snippet {
		@usableFromInline
		internal let attributes: AttributesList<Output>

		@usableFromInline
		internal let accessLevel: AccessLevel<Output>?

		@usableFromInline
		internal let identifier: IdentifierLiteral<Output>

		@usableFromInline
		internal let genericClause: GenericClause<Output>

		@usableFromInline
		internal let inheritanceClause: TypeInheritanceClause<Output>

		@usableFromInline
		internal let whereClause: WhereClause<Output>

		@usableFromInline
		internal let body: Body

		public init(
			attributes: AttributesList<Output> = [],
			accessLevel: AccessLevel<Output>? = nil,
			identifier: IdentifierLiteral<Output>,
			genericClause: GenericClause<Output> = [],
			inheritanceClause: TypeInheritanceClause<Output> = [],
			whereClause: WhereClause<Output> = [],
			@SnippetBuilder<Output> body: () -> Body
		) {
			self.attributes = attributes
			self.accessLevel = accessLevel
			self.identifier = identifier
			self.genericClause = genericClause
			self.inheritanceClause = inheritanceClause
			self.whereClause = whereClause
			self.body = body()
		}

		@inlinable
		public var content: some Snippet<Output> {
			Join(Const.newline) {
				attributes
				Join(Const.whitespace) {
					accessLevel
					"enum"
					Join {
						identifier
							.camelCaseMode(.pascal)
						genericClause
						inheritanceClause
					}
					whereClause
					DeclarationBlock { body }
				}
				.skipEmpty()
			}
			.skipEmpty()
		}
	}
}
