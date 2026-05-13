import Snippets
import Casification
import SwiftKeywords
import IssueReporting

extension Snippets {
	/// IdentifierLiteral type tries to render valid Swift identifiers
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
	/// // Explicit camel case mode (overrides environment)
	/// IdentifierLiteral("some arbitrary string", mode: .pascal).render() // "SomeArbitraryString"
	/// IdentifierLiteral("some arbitrary string", mode: .camel).render() // "someArbitraryString"
	/// IdentifierLiteral("some arbitrary string", mode: .automatic).render() // "someArbitraryString"
	///
	/// // Implicit camel case mode from the environment
	/// IdentifierLiteral("SOME ARBITRARY STRING`").camelCaseMode(.pascal).render() // "SomeArbitraryString"
	/// IdentifierLiteral("SOME ARBITRARY STRING`").camelCaseMode(.camel).render() // "someArbitraryString"
	/// IdentifierLiteral("SOME ARBITRARY STRING`").camelCaseMode(.automatic).render() // "SomeArbitraryString"
	///
	/// // Valid identifiers
	/// IdentifierLiteral("someValidIdentifier", mode: .pascal) // "someValidIdentifier", casing is not applied
	/// IdentifierLiteral("someValidIdentifier".case(.pascal)) // "SomeValidIdentifier"
	///
	/// // Reserved keywords
	/// IdentifierLiteral("default").render() // "`default`"
	/// ```
	///
	/// See `swift-casification` for more info about camelCase logic
	public struct IdentifierLiteral<
		Output: SnippetRepresentableString
	>: SnippetExpressibleByLiteral {
		@usableFromInline
		internal let literal: Output.SnippetRepresentation

		@usableFromInline
		internal let camelCaseMode: String.Casification.Configuration.CamelCase.Mode?

		/// Initializes a new instance of IdentifierLiteral with preferred camelCase mode
		///
		/// - Parameters:
		///   - literal: Identifier literal. Value is validated by the snippet, invalid literals are adjusted.
		///   - mode: CamelCase mode to apply to adjusted modifier, uses `currentCamelCaseMode`
		///           from ``SnippetEnvironment`` when the value is `nil` (default)
		public init(
			_ literal: Output,
			camelCase mode: String.Casification.Configuration.CamelCase.Mode? = nil
		) {
			if literal.isEmpty {
				reportIssue("""
				Identifier literal should not be empty, \
				it's likely to be a logical mistake in your code. \
				Ignore this message if it was intentional
				""")
			}
			self.literal = literal.makeSnippet()
			self.camelCaseMode = mode
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
			self.init(snippetLiteral)
		}

		/// Initializes a new instance of IdentifierLiteral with empty value
		///
		/// Required for compatibility with  ``SnippetExpressibleByLiteral`` protocol
		/// you shouldn't use this method directly as this will result in empty identifier
		@inlinable
		public init() {
			self.init(.const(""))
		}

		@inlinable
		public func render() -> Output {
			let rendered = casifiedIfNeeded()
			if rendered.isReservedSwiftKeyword {
				return Bracket(in: .backticks()) {
					rendered
				}.render()
			} else {
				return rendered
			}
		}

		@usableFromInline
		internal func casifiedIfNeeded() -> Output {
			// Escaping is applied later if needed
			let rendered = literal.render().trimmingCharacters(in: ["`"])

			guard !rendered.isEmpty else { return .const("") }

			let illegalCharacters = CharacterSet
				.illegalIdentifierHead
				.union(.illegalIdentifierTail)

			let components = rendered.components(separatedBy: illegalCharacters)

			if components.count > 1 {
				if let camelCaseMode {
					return literal.camelCase(camelCaseMode).render()
				} else {
					return literal.camelCase().render()
				}
			} else {
				return Output(stringLiteral: rendered)
			}
		}
	}

	/// Initializes a new instance of IdentifierLiteral with preferred camelCase mode
	///
	/// - Note: See ``IdentifierLiteral`` for more info
	public struct Identifier<
		Output: SnippetRepresentableString,
		Contents: Snippet<Output>
	>: Snippet {
		@usableFromInline
		internal let contents: Contents

		public init(_ content: Contents) {
			self.contents = content
		}

		@inlinable
		public init(
			@SnippetBuilder<Output> content: () -> Contents
		) {
			self.init(content())
		}

		@inlinable
		public func render() -> Output {
			IdentifierLiteral(snippetLiteral: contents.render()).render()
		}
	}
}

// MARK: - Swift identifier validation

//
// StencilSwiftKit
// Copyright © 2022 SwiftGen
// MIT Licence

// https://github.com/SwiftGen/StencilSwiftKit/blob/da3885afb27d63a9e95a121177a9eb80d57f627a/Sources/StencilSwiftKit/SwiftIdentifier.swift

// MIT Licence
//
// Copyright (c) 2022 SwiftGen
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

typealias CharRange = CountableClosedRange<Int>

// Official list of valid identifier characters
// swiftlint:disable:next line_length
// from: https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/LexicalStructure.html#//apple_ref/doc/uid/TP40014097-CH30-ID410
private extension CharRange {
	static func mr(_ char: Int) -> CharRange {
		char...char
	}

	static let headRanges: [CharRange] = [
		0x61...0x7a as CharRange,
		0x41...0x5a as CharRange,
		mr(0x5f), mr(0xa8), mr(0xaa), mr(0xad), mr(0xaf),
		0xb2...0xb5 as CharRange,
		0xb7...0xba as CharRange,
		0xbc...0xbe as CharRange,
		0xc0...0xd6 as CharRange,
		0xd8...0xf6 as CharRange,
		0xf8...0xff as CharRange,
		0x100...0x2ff as CharRange,
		0x370...0x167f as CharRange,
		0x1681...0x180d as CharRange,
		0x180f...0x1dbf as CharRange,
		0x1e00...0x1fff as CharRange,
		0x200b...0x200d as CharRange,
		0x202a...0x202e as CharRange,
		mr(0x203F), mr(0x2040), mr(0x2054),
		0x2060...0x206f as CharRange,
		0x2070...0x20cf as CharRange,
		0x2100...0x218f as CharRange,
		0x2460...0x24ff as CharRange,
		0x2776...0x2793 as CharRange,
		0x2c00...0x2dff as CharRange,
		0x2e80...0x2fff as CharRange,
		0x3004...0x3007 as CharRange,
		0x3021...0x302f as CharRange,
		0x3031...0x303f as CharRange,
		0x3040...0xd7ff as CharRange,
		0xf900...0xfd3d as CharRange,
		0xfd40...0xfdcf as CharRange,
		0xfdf0...0xfe1f as CharRange,
		0xfe30...0xfe44 as CharRange,
		0xfe47...0xfffd as CharRange,
		0x10000...0x1fffd as CharRange,
		0x20000...0x2fffd as CharRange,
		0x30000...0x3fffd as CharRange,
		0x40000...0x4fffd as CharRange,
		0x50000...0x5fffd as CharRange,
		0x60000...0x6fffd as CharRange,
		0x70000...0x7fffd as CharRange,
		0x80000...0x8fffd as CharRange,
		0x90000...0x9fffd as CharRange,
		0xa0000...0xafffd as CharRange,
		0xb0000...0xbfffd as CharRange,
		0xc0000...0xcfffd as CharRange,
		0xd0000...0xdfffd as CharRange,
		0xe0000...0xefffd as CharRange
	]

	static let tailRanges: [CharRange] = [
		0x30...0x39, 0x300...0x36F, 0x1dc0...0x1dff, 0x20d0...0x20ff, 0xfe20...0xfe2f
	]
}

private extension CharacterSet {
	static let illegalIdentifierHead = setFromRanges(CharRange.headRanges).inverted
	static let illegalIdentifierTail = setFromRanges(CharRange.headRanges + CharRange.tailRanges).inverted

	static func setFromRanges(_ ranges: [CharRange]) -> CharacterSet {
		var result = CharacterSet()
		for range in ranges {
			guard
				let lower = Unicode.Scalar(range.lowerBound),
				let upper = Unicode.Scalar(range.upperBound)
			else { continue }
			result.insert(charactersIn: lower...upper)
		}
		return result
	}
}
