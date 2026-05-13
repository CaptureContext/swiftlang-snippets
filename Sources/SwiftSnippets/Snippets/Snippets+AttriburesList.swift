import Snippets
import ArrayBuilder

extension Snippets {
	/// Swift attribute, for example attached macro or properyWrapper
	public struct Attribute<
		Output: SnippetRepresentableString
	>: SnippetExpressibleByLiteral {
		@usableFromInline
		internal let identifier: TypeExpr<Output>

		@usableFromInline
		internal let clause: CallClause<Output>?

		public init(
			_ identifier: TypeExpr<Output>,
			clause: CallClause<Output>? = nil
		) {
			self.identifier = identifier
			self.clause = clause
		}

		public init(
			_ identifier: IdentifierLiteral<Output>.Composed,
			clause: CallClause<Output>? = nil
		) {
			self.init(
				TypeExpr(identifier),
				clause: clause
			)
		}

		@inlinable
		public init(snippetLiteral: Output) {
			self.init(TypeExpr(snippetLiteral: snippetLiteral))
		}

		@inlinable
		public init() {
			self.init(snippetLiteral: "")
		}

		@inlinable
		public var content: some Snippet<Output> {
			Join {
				"@"
				identifier
				clause
			}
		}

		@inlinable
		public static var mainActor: Self { .init(snippetLiteral: "MainActor") }

		@inlinable
		public static var observable: Self { .init(snippetLiteral: "Observable") }

		@inlinable
		public static var observableState: Self { .init(snippetLiteral: "ObservableState") }

		@inlinable
		public static var casePathable: Self { .init(snippetLiteral: "CasePathable") }

		@inlinable
		public static var reducer: Self { .init(snippetLiteral: "Reducer") }

		@inlinable
		public static var dependency: Self { .init(snippetLiteral: "Dependency") }

		@inlinable
		public static var swiftUIBindable: Self { .init(snippetLiteral: "SwiftUI.Bindable") }

		@inlinable
		public static var swiftUIState: Self { .init(snippetLiteral: "SwiftUI.State") }
	}

	/// List of Swift attributes, for example attached macros or properyWrappers
	///
	/// Rendered as empty output if no attributes are provided
	public struct AttributesList<
		Output: SnippetRepresentableString
	>: Snippet, ExpressibleByArrayLiteral {
		@usableFromInline
		internal let elements: [Attribute<Output>]

		public init(_ elements: [Attribute<Output>]) {
			self.elements = elements
		}

		@inlinable
		public init(arrayLiteral elements: Attribute<Output>...) {
			self.init(elements)
		}

		@inlinable
		public init(_ attribute: Attribute<Output>) {
			self.init([attribute])
		}

		@inlinable
		public var content: some Snippet<Output> {
			Join(.const(.newline)) {
				elements
			}
			.skipEmpty()
		}
	}
}
