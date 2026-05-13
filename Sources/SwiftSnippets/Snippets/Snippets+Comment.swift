import Snippets

extension Snippets {
	/// Snippet for comment declarations
	///
	/// Comments contents with `///` or `//` depending on the specified kind
	public struct Comment<
		Output: SnippetRepresentableString,
		Contents: Snippet<Output>
	>: Snippet {
		public enum Kind: String, Snippet, Codable, Equatable, Sendable {
			// `///`
			case doc

			// `//`
			case regular

			public func render() -> Output {
				switch self {
				case .doc: "///"
				case .regular: "//"
				}
			}
		}

		@usableFromInline
		internal let kind: Kind

		@usableFromInline
		internal let contents: Contents

		/// Initializes a new instance of `Comment` snippet
		///
		/// - Parameters:
		///   - kind: Kind of the comment `.doc` (`///`) or `.regular` (`//`)
		///   - content: Contents of the comment
		public init(
			_ kind: Kind,
			@SnippetBuilder<Output> content: () -> Contents
		) {
			self.kind = kind
			self.contents = content()
		}

		public func render() -> Output {
			let rendered = contents.render()
			let lines = rendered.components(separatedBy: .newlines)
			let commented = lines.map { line in
				// TODO: Keep trailing whitespace after kind for code blocks
				if line.isEmpty {
					 return kind.render()
				 } else {
					 return "\(kind.render()) \(line)"
				 }
			}
			let result = commented.joined(separator: "\n")
			return .init(stringLiteral: result)
		}
	}
}
