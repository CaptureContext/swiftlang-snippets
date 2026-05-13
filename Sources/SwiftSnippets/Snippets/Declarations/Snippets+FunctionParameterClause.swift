import Snippets
import Casification

extension Snippets {
	public struct FunctionParameter<
		Output: SnippetRepresentableString
	>: Snippet {
		@usableFromInline
		internal let label: IdentifierLiteral<Output>?

		@usableFromInline
		internal let name: IdentifierLiteral<Output>

		@usableFromInline
		internal let type: TypeExpr<Output>

		@usableFromInline
		internal let defaultValue: AnySnippet<Output>?

		public init(
			label: IdentifierLiteral<Output>? = nil,
			name: IdentifierLiteral<Output>,
			type: TypeExpr<Output>,
			defaultValue: AnySnippet<Output>? = nil
		) {
			self.label = label
			self.name = name
			self.type = type
			self.defaultValue = defaultValue
		}

		@inlinable
		public init(
			label: IdentifierLiteral<Output>? = nil,
			name: IdentifierLiteral<Output>,
			type: TypeExpr<Output>,
			defaultValue: some Snippet<Output>
		) {
			self.label = label
			self.name = name
			self.type = type
			self.defaultValue = AnySnippet(defaultValue)
		}

		@inlinable
		public init(
			label: IdentifierLiteral<Output>? = nil,
			name: IdentifierLiteral<Output>,
			type: TypeExpr<Output>,
			defaultValue: Output
		) {
			self.init(
				label: label,
				name: name,
				type: type,
				defaultValue: defaultValue.makeSnippet()
			)
		}

		@usableFromInline
		internal var renderedLabel: Output? {
			guard let label else { return nil }

			let renderedLabel = label.casifiedIfNeeded()
			if renderedLabel == "_" {
				return renderedLabel
			}

			let renderedName = name.render()
			if renderedLabel == renderedName {
				return nil
			} else {
				return renderedLabel
			}
		}

		@inlinable
		public var content: some Snippet<Output> {
			Join {
				if let renderedLabel {
					renderedLabel
					Const.whitespace
				}
				name
					.camelCaseMode(.camel)
				Const.colon
				Const.whitespace
				type
				if let defaultValue {
					Const.whitespace
					Const.equal
					Const.whitespace
					defaultValue
				}
			}
		}
	}

	public struct FunctionParameterClause<
		Output: SnippetRepresentableString
	>: Snippet, ExpressibleByArrayLiteral {
		@usableFromInline
		internal let parameters: [FunctionParameter<Output>]

		public init(_ parameters: [FunctionParameter<Output>]) {
			self.parameters = parameters
		}

		@inlinable
		public init(arrayLiteral elements: FunctionParameter<Output>...) {
			self.init(elements)
		}

		@inlinable
		public init(_ parameter: FunctionParameter<Output>) {
			self.init([parameter])
		}

		@usableFromInline
		internal var isMultiline: Bool {
			parameters.count > 1
		}

		@inlinable
		public func render() -> Output {
			if isMultiline {
				let renderedParameters = Indent {
					Join(Const.comma.suffixed(with: .newline)) {
						parameters
					}
				}
				.render()

				return Output(stringLiteral: "(\n\(renderedParameters)\n)")
			} else {
				let renderedParameters = Join(Const.comma.suffixed(with: .whitespace)) {
					parameters
				}
				.render()

				return Output(stringLiteral: "(\(renderedParameters))")
			}
		}
	}
}
