import Snippets
import Casification

extension Snippets {
	public struct ComputedPropertyDecl<
		Output: SnippetRepresentableString,
		GetterBody: Snippet<Output>,
		SetterBody: Snippet<Output>
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
		internal let type: TypeExpr<Output>

		@usableFromInline
		internal let getter: PropertyGetterDecl<Output, GetterBody>

		@usableFromInline
		internal let setter: PropertySetterDecl<Output, SetterBody>?

		public init(
			attributes: AttributesList<Output> = [],
			isolation: DeclarationIsolation<Output>? = nil,
			accessLevel: AccessLevel<Output>? = nil,
			isStatic: Bool = false,
			identifier: IdentifierLiteral<Output>,
			type: TypeExpr<Output>,
			getter: PropertyGetterDecl<Output, GetterBody>,
			setter: PropertySetterDecl<Output, SetterBody>?
		) {
			self.attributes = attributes
			self.isolation = isolation
			self.accessLevel = accessLevel
			self.isStatic = isStatic
			self.identifier = identifier
			self.type = type
			self.getter = getter
			self.setter = setter
		}

		@inlinable
		public var content: some Snippet<Output> {
			Join(Const.newline) {
				attributes
				Join(.const(.whitespace)) {
					isolation
					accessLevel
					if isStatic { "static" }
					"var"
					Join {
						identifier
							.camelCaseMode(.camel)
						Const.colon
					}
					type
					DeclarationBlock {
						if setter == nil, getter.effects.isEmpty {
							getter.body
						} else {
							getter
						}
						if let setter {
							setter
						}
					}
				}
				.skipEmpty()
			}
			.skipEmpty()
		}
	}
}

extension Snippets.ComputedPropertyDecl {
	@inlinable
	public init(
		attributes: Snippets.AttributesList<Output> = [],
		isolation: Snippets.DeclarationIsolation<Output>? = nil,
		accessLevel: Snippets.AccessLevel<Output>? = nil,
		isStatic: Bool = false,
		identifier: Snippets.IdentifierLiteral<Output>,
		type: Snippets.TypeExpr<Output>,
		getter: Snippets.PropertyGetterDecl<Output, GetterBody>
	) where SetterBody == Snippets.Const<Output> {
		self.init(
			attributes: attributes,
			isolation: isolation,
			accessLevel: accessLevel,
			isStatic: isStatic,
			identifier: identifier,
			type: type,
			getter: getter,
			setter: nil
		)
	}
}
