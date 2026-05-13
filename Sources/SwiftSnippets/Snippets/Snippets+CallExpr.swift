import Snippets
import ArrayBuilder

extension Snippets {
	public struct CallArgument<
		Output: SnippetRepresentableString
	>: Snippet {
		@usableFromInline
		internal let label: IdentifierLiteral<Output>?

		@usableFromInline
		internal let value: AnySnippet<Output>

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
		public init(
			label: IdentifierLiteral<Output>? = nil,
			value: Output
		) {
			self.init(
				label: label,
				value: value.makeSnippet()
			)
		}

		@inlinable
		public var content: some Snippet<Output> {
			Join {
				if let label {
					label.casifiedIfNeeded()
					Const.colon
					Const.whitespace
				}
				value
			}
		}
	}

	public struct CallArgumentsList<
		Output: SnippetRepresentableString
	>: Snippet, ExpressibleByArrayLiteral {
		@usableFromInline
		internal let arguments: [CallArgument<Output>]

		public init(_ arguments: [CallArgument<Output>]) {
			self.arguments = arguments
		}

		@inlinable
		public init(arrayLiteral elements: CallArgument<Output>...) {
			self.init(elements)
		}

		@inlinable
		public init(_ argument: CallArgument<Output>) {
			self.init([argument])
		}

		@usableFromInline
		internal var isMultiline: Bool {
			arguments.count > 1
		}

		@inlinable
		public var content: some Snippet<Output> {
			Join(isMultiline ? Const.comma.suffixed(with: .newline) : Const.comma.suffixed(with: .whitespace)) {
				arguments
			}
			.skipEmpty()
		}
	}

	public struct CallClause<
		Output: SnippetRepresentableString
	>: Snippet, ExpressibleByArrayLiteral {
		@usableFromInline
		internal let arguments: CallArgumentsList<Output>

		public init(_ arguments: CallArgumentsList<Output>) {
			self.arguments = arguments
		}

		@inlinable
		public init(arrayLiteral elements: CallArgument<Output>...) {
			self.init(.init(elements))
		}

		@inlinable
		public init(_ arguments: [CallArgument<Output>]) {
			self.init(.init(arguments))
		}

		@inlinable
		public init(_ argument: CallArgument<Output>) {
			self.init(.init(argument))
		}

		@inlinable
		public func render() -> Output {
			if arguments.isMultiline {
				let renderedArguments = Indent { arguments }.render()
				return Output(stringLiteral: "(\n\(renderedArguments)\n)")
			} else {
				return Output(stringLiteral: "(\(arguments.render()))")
			}
		}
	}

	public struct CallExpr<
		Output: SnippetRepresentableString
	>: Snippet {
		@usableFromInline
		internal let callee: AnySnippet<Output>

		@usableFromInline
		internal let clause: CallClause<Output>

		public init(
			callee: AnySnippet<Output>,
			clause: CallClause<Output>
		) {
			self.callee = callee
			self.clause = clause
		}

		public init(
			callee: some Snippet<Output>,
			clause: CallClause<Output>
		) {
			self.init(
				callee: AnySnippet(callee),
				clause: clause
			)
		}

		@inlinable
		public init(
			callee: Output,
			clause: CallClause<Output>
		) {
			self.init(
				callee: callee.makeSnippet(),
				clause: clause
			)
		}

		@inlinable
		public var content: some Snippet<Output> {
			Join {
				callee
				clause
			}
		}
	}
}
