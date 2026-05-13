import Snippets
import Dependencies
import Foundation

extension Snippets {
	/// Represents swift access level
	public enum AccessLevel<Output: SnippetRepresentableString>: String, CaseIterable, Snippet {
		/// Declaration is visible only in local scope
		case `private`     = "private"

		/// Declaration is visible only in file scope
		case `fileprivate` = "fileprivate"

		/// Declaration is visible only in module scope
		case `internal`    = "internal"

		/// Declaration is visible only in package scope
		case `package`     = "package"

		/// Declaration is publically visible unless guarded with `@_spi` attribute
		case `public`      = "public"

		/// Declaration is publically visible and overridable
		case `open`        = "open"

		public var content: some Snippet<Output> {
			Output(stringLiteral: self.rawValue)
		}
	}
}
