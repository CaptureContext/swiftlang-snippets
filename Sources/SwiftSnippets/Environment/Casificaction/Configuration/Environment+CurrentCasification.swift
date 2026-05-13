import Snippets
import Dependencies
import Casification

extension SnippetEnvironmentValues where Output: SnippetRepresentableString {
	public var currentCasification: String.Casification.Configuration {
		String.Casification.Configuration.current
	}
}
