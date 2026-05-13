import Testing
@testable import SwiftSnippets
import CustomDump

@Suite
struct AccessLevelTests {
	@Test
	func rawValues() async throws {
		expectNoDifference(
			"private",
			Snippets.AccessLevel<String>.private.rawValue
		)

		expectNoDifference(
			"fileprivate",
			Snippets.AccessLevel<String>.fileprivate.rawValue
		)

		expectNoDifference(
			"internal",
			Snippets.AccessLevel<String>.internal.rawValue
		)

		expectNoDifference(
			"package",
			Snippets.AccessLevel<String>.package.rawValue
		)

		expectNoDifference(
			"public",
			Snippets.AccessLevel<String>.public.rawValue
		)

		expectNoDifference(
			"open",
			Snippets.AccessLevel<String>.open.rawValue
		)
	}

	@Test
	func rendering() async throws {
		let entries = Snippets.AccessLevel<String>.allCases

		let actual = entries.map { $0.render() }
		let expected = entries.map { $0.rawValue }

		expectNoDifference(expected, actual)
	}
}
