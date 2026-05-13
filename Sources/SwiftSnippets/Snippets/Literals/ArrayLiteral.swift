import Snippets

extension Snippets {
	public struct ArrayLiteral<
		Output: SnippetRepresentableString
	>: Snippet, ExpressibleByArrayLiteral {
		@usableFromInline
		let elements: [AnySnippet<Output>]

		public init(elements: [AnySnippet<Output>]) {
			self.elements = elements
		}

		@inlinable
		public init<S: Sequence<Snippet<Output>>>(_ sequence: S) {
			self.init(elements: sequence.map { $0.eraseToAnySnippet() })
		}

		@inlinable
		public init(arrayLiteral elements: AnySnippet<Output>...) {
			self.init(elements: elements)
		}

		@inlinable
		public var content: some Snippet<Output> {
			if elements.isEmpty { "[]" } else {
				Bracket(in: .brackets.withInner(.init(
					leading: .newline,
					trailing: .empty
				))) {
					Indent {
						Join {
							ForEach(elements) { element in
								element
									.withSuffix(Const(.comma))
									.withSuffix(Const(.newline))
							}
						}
					}
				}
			}
		}
	}
}
