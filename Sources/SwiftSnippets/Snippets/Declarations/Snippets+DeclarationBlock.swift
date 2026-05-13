import Snippets
import Foundation

extension Snippets {
	public struct DeclarationBlock<
		Output: SnippetRepresentableString,
		Body: Snippet<Output>
	>: Snippet {
		@usableFromInline
		internal let body: Body

		public init(
			@SnippetBuilder<Output> body: () -> Body
		) {
			self.body = body()
		}

		@inlinable
		public func render() -> Output {
			let rendered = String(body.render())
				.components(separatedBy: .newlines)
				.map { line in
					var line = line
					while let last = line.last, last == " " || last == "\t" {
						line.removeLast()
					}
					return line
				}
				.joined(separator: "\n")

			if rendered.isEmpty {
				return Output(stringLiteral: "{}")
			} else {
				let indented = Indent {
					rendered
				}
				.render()

				return Output(stringLiteral: "{\n\(indented)\n}")
			}
		}
	}
}
