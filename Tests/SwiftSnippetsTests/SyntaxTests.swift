import Testing
@testable import SwiftSnippets
import CustomDump

private func id(_ value: String) -> Snippets.IdentifierLiteral<String> {
	.init(snippetLiteral: value)
}

private func composed(_ value: String) -> Snippets.IdentifierLiteral<String>.Composed {
	.init(snippetLiteral: value)
}

private func type(_ value: String) -> Snippets.TypeExpr<String> {
	.init(snippetLiteral: value)
}

private func attr(_ value: String) -> Snippets.Attribute<String> {
	.init(snippetLiteral: value)
}

@Suite
struct SyntaxTests {
	@Test
	func typeExprPreservesComplexSyntax() {
		expectNoDifference(
			"(any Actor)?",
			type("(any Actor)?").render()
		)

		expectNoDifference(
			"@Sendable (String, Int...) async throws -> Void",
			type("@Sendable (String, Int...) async throws -> Void").render()
		)
	}

	@Test
	func callClauseRendersInlineAndMultilineArguments() {
		expectNoDifference(
			"(value)",
			Snippets.CallClause<String>([
				.init(value: "value")
			]).render()
		)

		expectNoDifference(
			"""
			(
				value,
				label: otherValue
			)
			""",
			Snippets.CallClause<String>([
				.init(value: "value"),
				.init(label: id("label"), value: "otherValue")
			]).render()
		)
	}

	@Test
	func functionParameterClauseRendersLabelsAndDefaults() {
		expectNoDifference(
			"(_ count: Int)",
			Snippets.FunctionParameterClause<String>([
				.init(label: id("_"), name: id("count"), type: type("Int"))
			]).render()
		)

		expectNoDifference(
			"""
			(
				for key: String = "example",
				value: Int,
				force: Bool = Self.isForceByDefault(
					calculationData: []
				)
			)
			""",
			Snippets.FunctionParameterClause<String>([
				.init(
					label: id("for"),
					name: id("key"),
					type: type("String"),
					defaultValue: #""example""#
				),
				.init(
					name: id("value"),
					type: type("Int")
				),
				.init(
					name: id("force"),
					type: type("Bool"),
					defaultValue: """
					Self.isForceByDefault(
						calculationData: []
					)
					"""
				)
			]).render()
		)
	}

	@Test
	func genericAndWhereClausesRenderMultiline() {
		expectNoDifference(
			"""
			<
				GenericArg0,
				GenericArg1: Type1 & Type2
			>
			""",
			Snippets.GenericClause<String>([
				.init(identifier: id("GenericArg0")),
				.init(identifier: id("GenericArg1"), constraints: [type("Type1"), type("Type2")])
			]).render()
		)

		expectNoDifference(
			"""
			where 
				SomeType: TypeConstraint,
				GenericArg0: AnotherConstraint & Sendable
			""",
			Snippets.WhereClause<String>([
				.init(subject: type("SomeType"), constraints: [type("TypeConstraint")]),
				.init(subject: type("GenericArg0"), constraints: [type("AnotherConstraint"), type("Sendable")])
			]).render()
		)
	}

	@Test
	func attributesRenderWithCallClauses() {
		expectNoDifference(
			"@MainActor",
			Snippets.Attribute<String>.mainActor.render()
		)

		expectNoDifference(
			"""
			@available(
				*,
				deprecated,
				message: "Use something else"
			)
			""",
			Snippets.Attribute<String>(
				type("available"),
				clause: [
					.init(value: "*"),
					.init(value: "deprecated"),
					.init(label: id("message"), value: #""Use something else""#)
				]
			).render()
		)
	}

	@Test
	func complexFunctionDeclMatchesReferenceFormatting() {
		let function: any Snippet<String> = Snippets.FunctionDecl(
			attributes: [
				.mainActor,
				.init(type("SomeMacro"), clause: [.init(value: #"\\.singleArg"#)]),
				.init(
					type("available"),
					clause: [
						.init(value: "*"),
						.init(value: "deprecated"),
						.init(
							label: id("message"),
							value: """
							\"\"\"
							Some message
							\"\"\"
							"""
						)
					]
				),
				attr("objc"),
				attr("inlinable")
			],
			isolation: .nonisolated(unsafe: true),
			accessLevel: .public,
			isStatic: true,
			identifier: id("someFunction"),
			genericClause: [
				.init(identifier: id("GenericArg0")),
				.init(identifier: id("GenericArg1"), constraints: [type("Type1"), type("Type2")]),
				.init(identifier: id("OtherArg"), constraints: [type("Sendable")])
			],
			parameters: [
				.init(
					name: id("isolation"),
					type: type("(any Actor)?"),
					defaultValue: "#isolation"
				),
				.init(
					label: id("for"),
					name: id("key"),
					type: type("String"),
					defaultValue: #""example""#
				),
				.init(label: id("_"), name: id("value"), type: type("Int")),
				.init(
					name: id("force"),
					type: type("Bool"),
					defaultValue: """
					Self.isForceByDefault(
						calculationData: []
					)
					"""
				)
			],
			returnType: type("OutputType"),
			whereClause: [
				.init(subject: type("SomeType"), constraints: [type("TypeConstraint")]),
				.init(subject: type("GenericArg0"), constraints: [type("AnotherConstraint"), type("Sendable")])
			]
		) {
			"""
			let output: OutputType = Worker.performWork(
				callExample: true
			)
			
			return output
			"""
		}

		expectNoDifference(
			"""
			@MainActor
			@SomeMacro(\\\\.singleArg)
			@available(
				*,
				deprecated,
				message: \"\"\"
				Some message
				\"\"\"
			)
			@objc
			@inlinable
			nonisolated(unsafe) public static func someFunction<
				GenericArg0,
				GenericArg1: Type1 & Type2,
				OtherArg: Sendable
			> (
				isolation: (any Actor)? = #isolation,
				for key: String = "example",
				_ value: Int,
				force: Bool = Self.isForceByDefault(
					calculationData: []
				)
			) -> OutputType where 
				SomeType: TypeConstraint,
				GenericArg0: AnotherConstraint & Sendable {
				let output: OutputType = Worker.performWork(
					callExample: true
				)

				return output
			}
			""",
			function.render()
		)
	}

	@Test
	func complexComputedPropertyDeclMatchesReferenceFormatting() {
		let property: any Snippet<String> = Snippets.ComputedPropertyDecl(
			attributes: [
				.mainActor,
				.init(type("SomeMacro"), clause: [.init(value: #"\\.singleArg"#)]),
				attr("objc"),
				attr("inlinable")
			],
			isolation: .nonisolated(unsafe: true),
			accessLevel: .public,
			isStatic: true,
			identifier: id("someVariable"),
			type: type("OutputType"),
			getter: .init {
				"""
				.init(
					"asd",
					value: 123,
					object: SomeNamespace.SomeObject.create()
				)
				"""
			}
		)

		expectNoDifference(
			"""
			@MainActor
			@SomeMacro(\\\\.singleArg)
			@objc
			@inlinable
			nonisolated(unsafe) public static var someVariable: OutputType {
				.init(
					"asd",
					value: 123,
					object: SomeNamespace.SomeObject.create()
				)
			}
			""",
			property.render()
		)
	}
}
