import Testing
@testable import SwiftSnippets
import CustomDump
import SwiftKeywords

@Suite
struct IdentifierTests {
	@Test
	func escapesReservedSwiftKeywords() async throws {
		let reserved = Set<String>.reservedSwiftKeywords.sorted(by: <)
		let expected = reserved.map { "`\($0)`" }
		let processed = reserved.map { Snippets.IdentifierLiteral<String>(snippetLiteral: $0).render() }
		expectNoDifference(expected, processed)
	}

	@Test
	func doesntEscapeNonReservedIdentifiers() async throws {
		var notReserved = Set<String>.swiftKeywords.subtracting(.reservedSwiftKeywords).sorted(by: <)

		notReserved.append("someValidIdentifier")
		notReserved.append("AnotherValidIdentifier")

		let expected = notReserved
		let processed = notReserved.map { Snippets.IdentifierLiteral<String>(snippetLiteral: $0).render() }
		expectNoDifference(expected, processed)
	}

	@Test
	func doesntModifyValidEscapedReservedIdentifiers() {
		let reserved = Set<String>.reservedSwiftKeywords.sorted(by: <)
		let expected = reserved.map { "`\($0)`" }
		let processed = expected.map { Snippets.IdentifierLiteral<String>(snippetLiteral: $0).render() }
		expectNoDifference(expected, processed)
	}

	@Test
	func camelCasesInvalidIdenifiers() async throws {
		do { // automatic mode by default
			let expected = "someSwiftString"
			let actual = Snippets.IdentifierLiteral<String>(snippetLiteral: "some swift string").render()
			expectNoDifference(expected, actual)
		}

		do { // automatic mode by default
			let expected = "SomeSwiftString"
			let actual = Snippets.IdentifierLiteral<String>(snippetLiteral: "Some swift string").render()
			expectNoDifference(expected, actual)
		}

		do { // respects mode
			let expected = "someSwiftString"
			let actual = Snippets.IdentifierLiteral<String>(
				snippetLiteral: "Some swift string"
			).camelCaseMode(.camel).render()
			expectNoDifference(expected, actual)
		}
	}
}
