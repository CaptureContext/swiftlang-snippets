import Snippets
import Dependencies

extension DependencyValues {
	private enum SnippetIndentorKey<Output: SnippetRepresentableString>: SnippetEnvironmentKey {
		typealias Value = AnySnippet<Output>
		static var defaultValue: AnySnippet<Output> { .defaultIndentor }
	}

	@_spi(Internals)
	public struct SnippetIndentorKeyID<Output: SnippetRepresentableString>: Hashable, Sendable {
		let id: ObjectIdentifier = .init(Output.self)
		public static func type(_ type: Output.Type) -> Self { .init() }
	}

	@_spi(Internals)
	public subscript<Output: SnippetRepresentableString>(
		snippetIndentorOf _: SnippetIndentorKeyID<Output>
	) -> AnySnippet<Output> {
		get { self[SnippetIndentorKey<Output>.self] }
		set { self[SnippetIndentorKey<Output>.self] = newValue }
	}
}

extension SnippetEnvironmentValues where Output: SnippetRepresentableString {
	public var currentIndentor: AnySnippet<Output> {
		return dependency(\.[snippetIndentorOf: .type(Output.self)])
	}
}

extension AnySnippet where Output: SnippetRepresentableString {
	public static var defaultIndentor: Self {
		AnySnippet(Output.SnippetRepresentation(snippetLiteral: .const(.tab)))
	}
}
