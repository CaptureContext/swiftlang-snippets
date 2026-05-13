import Testing
@testable import SwiftSnippets
import CustomDump

@Suite
struct CommentTests {
	@Test
	func singleLineDoc() async throws {
		expectNoDifference(
			"/// test",
			Snippets.Comment(.doc) {
				"test"
			}.render()
		)
	}

	@Test
	func singleLineRegular() async throws {
		expectNoDifference(
			"// test",
			Snippets.Comment(.regular) {
				"test"
			}.render()
		)
	}

	@Test
	func multilineLineDoc() async throws {
		expectNoDifference(
			"""
			/// test
			///
			/// body
			""",
			Snippets.Comment(.doc) {
				"""
				test
				
				body
				"""
			}.render()
		)
	}

	@Test
	func multilineLineRegular() async throws {
		expectNoDifference(
			"""
			// test
			//
			// body
			""",
			Snippets.Comment(.regular) {
				"""
				test
				
				body
				"""
			}.render()
		)
	}

	@Test
	func multilineLineDocWithJoin() async throws {
		expectNoDifference(
			"""
			/// test
			///
			/// body
			/// > note
			""",
			Snippets.Comment(.doc) {
				Snippets.Join(.const(.newlines(2))) {
					"test"

					"""
					body
					> note
					"""
				}
			}.render()
		)
	}

	@Test
	func multilineLineRegularWithJoin() async throws {
		expectNoDifference(
			"""
			// test
			//
			// body
			// > note
			""",
			Snippets.Comment(.regular) {
				Snippets.Join(.const(.newlines(2))) {
					"test"

					"""
					body
					> note
					"""
				}
			}.render()
		)
	}
}
