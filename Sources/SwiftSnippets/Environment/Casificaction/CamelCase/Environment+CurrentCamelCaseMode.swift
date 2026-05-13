import Snippets
import Dependencies
import Casification

extension DependencyValues {
	private enum SnippetCamelCaseModeKey: DependencyKey {
		static var liveValue: String.Casification.Configuration.CamelCase.Mode { .default }
		static var testValue: String.Casification.Configuration.CamelCase.Mode { .default }
		static var previewValue: String.Casification.Configuration.CamelCase.Mode { .default }
	}

	@_spi(Internals)
	public var snippetCamelCaseMode: String.Casification.Configuration.CamelCase.Mode {
		get { self[SnippetCamelCaseModeKey.self] }
		set { self[SnippetCamelCaseModeKey.self] = newValue }
	}
}

extension SnippetEnvironmentValues where Output: SnippetRepresentableString {
	public var currentCamelCaseMode: String.Casification.Configuration.CamelCase.Mode {
		dependency(\.snippetCamelCaseMode)
	}
}
