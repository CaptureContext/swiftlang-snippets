# swift-snippets

[![CI](https://github.com/capturecontext/swift-snippets/actions/workflows/ci.yml/badge.svg)](https://github.com/capturecontext/swift-snippets/actions/workflows/ci.yml) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fcapturecontext%2Fswift-snippets%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/capturecontext/swift-snippets) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fcapturecontext%2Fswift-snippets%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/capturecontext/swift-snippets)

## Table of Contents

- [Motivation](#motivation)
- [Usage](#usage)
- [Installation](#installation)
- [License](#license)

## Motivation

`swift-snippets` is a small, composable toolkit for declaring semantic output templates in Swift. It is primarily built for text generation: source code, comments, declarations, configuration files, diagnostics, or any other output where small reusable fragments need to be combined predictably.

The package is printing-only by design. If you need a bidirectional parser/printer system, [`pointfreeco/swift-parsing`](https://github.com/pointfreeco/swift-parsing) is a more complex alternative with a composable `ParserPrinter` protocol that can parse data and print it back. `swift-snippets` focuses on the other side of that tradeoff: lightweight semantic templates that render output, without requiring a parser model.

Although generating text is the main use case, the core abstractions are generic over snippet output. External conformances can extend the same composition model to other formats, including binary output or domain-specific encoders.

## Usage

Import the `Snippets` product and compose snippets with builder closures:

```swift
import Snippets

let output: String = .snippet {
	"public"
	" "
	"struct"
	" "
	"User"
}

print(output)
// public struct User
```

Use `Snippets.Join` when fragments should be separated by another snippet:

```swift
let parameters: String = .snippet {
	Snippets.Join(.const(", ")) {
		"id: String"
		"name: String"
		"isActive: Bool"
	}
}

print(parameters)
// id: String, name: String, isActive: Bool
```

Reusable snippets can be declared as regular Swift types:

```swift
struct FunctionCall<
	Arguments: Snippet<String>
>: Snippet {
	let name: String
	let arguments: Arguments

	init(
		_ name: String,
		@SnippetBuilder<String> arguments: () -> Arguments
	) {
		self.name = name
		self.arguments = arguments
	}

	var content: some Snippet<String> {
		name
		Snippets.Bracket(in: .parenthesis) {
			arguments.skipEmpty()
		}
	}
}

let call = FunctionCall("makeUser") {
	Join(", ") {
		#"id: "42""#
		#"name: "Blob""#
	}
}

print(call.render())
// makeUser(id: "42", name: "Blob")
```

If you want to create snippets that work with any `StringProtocol` you can use `SnippetRepresentableString` protocol

```swift
struct FunctionCall<
	Output: SnippetRepresentableString,
	Arguments: Snippet<Output>
>: Snippet {
	// ...
}
```

## Installation

Use one of the installation methods below, then add the `Snippets` product to the targets that render snippets.

## Installation

### Basic

You can add `swift-snippets` to an Xcode project by adding it as a package dependency.

1. From the **File** menu, select **Swift Packages › Add Package Dependency…**
2. Enter [`"https://github.com/capturecontext/swift-snippets"`](https://github.com/capturecontext/swift-snippets) into the package repository URL text field
3. Choose products you need to link to your project.

### Recommended

If you use SwiftPM for your project structure, add `swift-snippets` dependency to your package file

```swift
.package(
  url: "https://github.com/capturecontext/swift-snippets.git", 
  .upToNextMinor(from: "0.0.1")
)
```

Do not forget about target dependencies

```swift
.product(
  name: "Snippets", 
  package: "swift-snippets"
)
```

## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.
