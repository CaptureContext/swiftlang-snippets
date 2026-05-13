import Snippets
import Casification

extension Snippets {
	public struct PropertyGetterDecl<
		Output: SnippetRepresentableString,
		Body: Snippet<Output>
	>: Snippet {
		public struct Effects: OptionSet, Snippet {
			public var rawValue: UInt8

			public init(rawValue: UInt8) {
				self.rawValue = rawValue
			}

			public static var `async`: Self { .init(rawValue: 1 << 0) }
			public static var `throws`: Self { .init(rawValue: 1 << 1) }

			@inlinable
			public var content: some Snippet<Output> {
				Join(.const(.whitespace)) {
					if contains(.async) { "async" }
					if contains(.throws) { "throws" }
				}.skipEmpty()
			}
		}

		@usableFromInline
		internal var effects: Effects

		@usableFromInline
		internal var body: Body

		public init(
			effects: Effects = [],
			@SnippetBuilder<Output> body: () -> Body
		) {
			self.effects = effects
			self.body = body()
		}

		@inlinable
		public var content: some Snippet<Output> {
			Join(.const(.whitespace)) {
				"get"
				effects
				DeclarationBlock { body }
			}.skipEmpty()
		}
	}

	public struct PropertySetterDecl<
		Output: SnippetRepresentableString,
		Body: Snippet<Output>
	>: Snippet {
		public struct Effects: OptionSet, Snippet {
			public var rawValue: UInt8

			public init(rawValue: UInt8) {
				self.rawValue = rawValue
			}

			public static var `nonmutating`: Self { .init(rawValue: 1 << 0) }

			@inlinable
			public var content: some Snippet<Output> {
				Join(.const(.whitespace)) {
					if contains(.nonmutating) { "nonmutating" }
				}.skipEmpty()
			}
		}

		@usableFromInline
		internal var effects: Effects

		@usableFromInline
		internal var inputAlias: IdentifierLiteral<Output>?

		@usableFromInline
		internal var body: Body

		public init(
			effects: Effects = [],
			inputAlias: IdentifierLiteral<Output>? = nil,
			@SnippetBuilder<Output> body: () -> Body
		) {
			self.effects = effects
			self.inputAlias = inputAlias
			self.body = body()
		}

		@inlinable
		public var content: some Snippet<Output> {
			Join(.const(.whitespace)) {
				effects
				Join {
					"set"
					if let inputAlias {
						Bracket(in: .parenthesis) {
							inputAlias
								.camelCaseMode(.camel)
						}
					}
				}
				DeclarationBlock { body }
			}.skipEmpty()
		}
	}
}
