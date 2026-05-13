import Snippets
import Casification

extension Snippets {
	public struct FunctionDecl<
		Output: SnippetRepresentableString,
		Body: Snippet<Output>
	>: Snippet {
		@usableFromInline
		internal let attributes: AttributesList<Output>

		@usableFromInline
		internal let isolation: DeclarationIsolation<Output>?

		@usableFromInline
		internal let accessLevel: AccessLevel<Output>?

		@usableFromInline
		internal let isStatic: Bool

		@usableFromInline
		internal let identifier: IdentifierLiteral<Output>

		@usableFromInline
		internal let genericClause: GenericClause<Output>

		@usableFromInline
		internal let parameters: FunctionParameterClause<Output>

		@usableFromInline
		internal let effects: FunctionEffects<Output>

		@usableFromInline
		internal let returnType: TypeExpr<Output>?

		@usableFromInline
		internal let whereClause: WhereClause<Output>

		@usableFromInline
		internal let body: Body

		public init(
			attributes: AttributesList<Output> = [],
			isolation: DeclarationIsolation<Output>? = nil,
			accessLevel: AccessLevel<Output>? = nil,
			isStatic: Bool = false,
			identifier: IdentifierLiteral<Output>,
			genericClause: GenericClause<Output> = [],
			parameters: FunctionParameterClause<Output> = [],
			effects: FunctionEffects<Output> = [],
			returnType: TypeExpr<Output>? = nil,
			whereClause: WhereClause<Output> = [],
			@SnippetBuilder<Output> body: () -> Body
		) {
			self.attributes = attributes
			self.isolation = isolation
			self.accessLevel = accessLevel
			self.isStatic = isStatic
			self.identifier = identifier
			self.genericClause = genericClause
			self.parameters = parameters
			self.effects = effects
			self.returnType = returnType
			self.whereClause = whereClause
			self.body = body()
		}

		@inlinable
		public var content: some Snippet<Output> {
			Join(Const.newline) {
				attributes
				Join(.const(.whitespace)) {
					isolation
					accessLevel
					if isStatic { "static" }
					"func"
					Join {
						identifier
							.camelCaseMode(.camel)
						genericClause
						if !genericClause.parameters.isEmpty {
							Const.whitespace
						}
						parameters
						if !effects.isEmpty {
							Const.whitespace
							effects
						}
						if let returnType {
							Const.whitespace
							"->"
							Const.whitespace
							returnType
						}
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
