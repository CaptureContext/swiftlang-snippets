import Snippets

extension Snippets {
	public enum DeclarationIsolation<
		Output: SnippetRepresentableString
	>: Snippet {
		case nonisolated(unsafe: Bool = false)

		@inlinable
		public func render() -> Output {
			switch self {
			case let .nonisolated(isUnsafe):
				if isUnsafe {
					return Output(stringLiteral: "nonisolated(unsafe)")
				} else {
					return Output(stringLiteral: "nonisolated")
				}
			}
		}
	}

	public struct FunctionEffects<
		Output: SnippetRepresentableString
	>: OptionSet, Snippet {
		public var rawValue: UInt8

		public init(rawValue: UInt8) {
			self.rawValue = rawValue
		}

		public static var `async`: Self { .init(rawValue: 1 << 0) }
		public static var `throws`: Self { .init(rawValue: 1 << 1) }
		public static var `rethrows`: Self { .init(rawValue: 1 << 2) }

		@inlinable
		public var content: some Snippet<Output> {
			Join(Const.whitespace) {
				if contains(.async) { "async" }
				if contains(.rethrows) {
					"rethrows"
				} else if contains(.throws) {
					"throws"
				}
			}
			.skipEmpty()
		}
	}
}
