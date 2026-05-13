import Testing
@testable import SwiftSnippets
import CustomDump

@Suite
struct CamelCaseTests {
	@Test(arguments: [
		("Some string", String.Casification.Configuration.CamelCase.Mode.automatic),
		("some string", String.Casification.Configuration.CamelCase.Mode.automatic),
		("Some string", String.Casification.Configuration.CamelCase.Mode.camel),
		("some string", String.Casification.Configuration.CamelCase.Mode.camel),
		("Some string", String.Casification.Configuration.CamelCase.Mode.pascal),
		("some string", String.Casification.Configuration.CamelCase.Mode.pascal),
	])
	func respectsCamelCaseMode(
		source: String,
		mode: String.Casification.Configuration.CamelCase.Mode,
	) async throws {
		expectNoDifference(
			source,
			source
				.makeSnippet()
				.camelCaseMode(mode)
				.render(),
			"`camelCaseMode` should not trigger casification"
		)

		expectNoDifference(
			source.case(.camel(mode)),
			source
				.makeSnippet()
				.camelCase(mode)
				.render(),
			"`camelCase(mode)` should not trigger casification with specified mode"
		)

		expectNoDifference(
			source.case(.camel(mode)),
			source
				.makeSnippet()
				.camelCase()
				.camelCaseMode(mode)
				.render(),
			"`camelCase()` should not trigger casification with current mode"
		)


		expectNoDifference(
			source.case(.camel(.automatic)),
			source
				.makeSnippet()
				.camelCase()
				.render(),
			"`camelCase()` should not trigger casification with automatic mode by default"
		)
	}
}
