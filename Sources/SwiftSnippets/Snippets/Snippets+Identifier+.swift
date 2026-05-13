import Snippets
import Casification
import Foundation

extension Snippets.IdentifierLiteral {
	/// ComposedIdentifierLiteral type tries to render valid Swift type identifiers
	///
	/// - Reserved keywords are escaped with backticks (\`)
	/// - Arbitrary strings are camelCased, use environmental `camelCaseMode(_:)`
	///   and `casification(_:)`/`casification(_:_:)` overrides to adjust the behavior
	///   of camel case
	///
	/// - Note: This type respects provided literals and only invalid identifiers are camelCased,
	///         if you want explict casing, consider adjusting literal beforehand, for example
	///         using `.case(_:)` method from `swift-casification`
	///
	/// Examples:
	/// ```swift
	/// // Composed
	/// IdentifierLiteral.Composed(["CustomType", "property"]) // "CustomType.property"
	/// IdentifierLiteral.Composed(["CustomType.Subtype"]) // "CustomType.Subtype"
	///
	/// // Each separate component behavior matches `IdentifierLiteral`
	///
	/// // Explicit camel case mode (overrides environment)
	/// IdentifierLiteral.Composed("some arbitrary string", mode: .pascal).render() // "SomeArbitraryString"
	/// IdentifierLiteral.Composed("some arbitrary string", mode: .camel).render() // "someArbitraryString"
	/// IdentifierLiteral.Composed("some arbitrary string", mode: .automatic).render() // "someArbitraryString"
	///
	/// // Implicit camel case mode from the environment
	/// IdentifierLiteral.Composed("SOME ARBITRARY STRING`").camelCaseMode(.pascal).render() // "SomeArbitraryString"
	/// IdentifierLiteral.Composed("SOME ARBITRARY STRING`").camelCaseMode(.camel).render() // "someArbitraryString"
	/// IdentifierLiteral.Composed("SOME ARBITRARY STRING`").camelCaseMode(.automatic).render() // "SomeArbitraryString"
	///
	/// // Valid identifiers
	/// IdentifierLiteral.Composed("someValidIdentifier", mode: .pascal) // "someValidIdentifier", casing is not applied
	/// IdentifierLiteral.Composed("someValidIdentifier".case(.pascal)) // "SomeValidIdentifier"
	///
	/// // Reserved keywords
	/// IdentifierLiteral.Composed("default").render() // "`default`"
	/// ```
	///
	/// See `swift-casification` for more info about camelCase logic
	public struct Composed: SnippetExpressibleByLiteral {
		@usableFromInline
		internal let components: [Snippets.IdentifierLiteral<Output>]

		public init(
			_ components: [Output],
			camelCase mode: String.Casification.Configuration.CamelCase.Mode? = nil
		) {
			self.components = components.flatMap { component in
				String(component)
					.components(separatedBy: ["."])
					.filter { !$0.isEmpty }
					.map { component in
						Snippets.IdentifierLiteral(
							Output(stringLiteral: component),
							camelCase: mode
						)
					}
			}
		}

		@inlinable
		public init(
			_ components: Output...,
			camelCase mode: String.Casification.Configuration.CamelCase.Mode? = nil
		) {
			self.init(components, camelCase: mode)
		}

		/// Initializes a new instance of IdentifierLiteral
		///
		/// - Note: Empty identifiers will be rendered as empty strings without
		///         any adjustments
		///
		/// - Parameters:
		///   - literal: Identifier literal. Value is validated by the snippet, invalid literals are adjusted.
		@inlinable
		public init(snippetLiteral: Output) {
			self.init([snippetLiteral])
		}

		/// Initializes a new instance of IdentifierLiteral with empty value
		///
		/// Required for compatibility with  ``SnippetExpressibleByLiteral`` protocol
		/// you shouldn't use this method directly as this will result in empty identifier
		@inlinable
		public init() {
			self.init(.const(""))
		}

		public var content: some Snippet<Output> {
			Snippets.Join(.const(.dot)) {
				components
			}
		}
	}

	public struct AccessExpr: SnippetExpressibleByLiteral {
		public struct Options: OptionSet, Snippet {
			public var rawValue: UInt

			public init(rawValue: UInt) {
				self.rawValue = rawValue
			}


			public init(detectIn literal: Output) {
				self = switch true {
				case literal.hasPrefix("\\."): [.implicit, .keyPath]
				case literal.hasPrefix("\\"): .keyPath
				case literal.hasPrefix("."): .implicit
				default: []
				}
			}

			static var implicit: Self { .init(rawValue: 1 << 0) }
			static var keyPath: Self { .init(rawValue: 1 << 1) }

			public var content: some Snippet<Output> {
				if contains(.keyPath) { "\\" }
				if contains(.implicit) { "." }
			}
		}

		@usableFromInline
		internal let options: Options

		@usableFromInline
		internal let identifier: Composed

		public init(_ literal: Output) {
			self.options = .init(detectIn: literal)
			self.identifier = .init(literal)
		}

		@inlinable
		public init(snippetLiteral: Output) {
			self.init(snippetLiteral)
		}

		@inlinable
		public init() {
			self.init(snippetLiteral: .const(.empty))
		}

		@inlinable
		public var content: some Snippet<Output> {
			Snippets.Join {
				options
				identifier
			}
			.skipEmpty()
		}
	}
}
