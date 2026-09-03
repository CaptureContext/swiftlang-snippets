// swift-tools-version: 6.1

import PackageDescription

let package = Package(
	name: "swiftlang-snippets",
	platforms: [
		.macOS(.v10_15),
		.macCatalyst(.v13),
		.iOS(.v13),
		.tvOS(.v13),
		.watchOS(.v6)
	],
	products: [
		.library(
			name: "SwiftSnippets",
			targets: ["SwiftSnippets"]
		),
	],
	dependencies: [
		.package(
			url: "https://github.com/capturecontext/swiftlang-keywords.git",
			.upToNextMinor(from: "0.0.4"),
			traits: ["Latest"]
		),
		.package(
			url: "https://github.com/capturecontext/swift-casification.git",
			.upToNextMinor(from: "0.7.0"),
		),
		.package(
			url: "https://github.com/capturecontext/swift-snippets.git",
			.upToNextMinor(from: "0.1.1")
		),
		.package(
			url: "https://github.com/capturecontext/swift-result-builders.git",
			.upToNextMinor(from: "0.0.3")
		),
		.package(
			url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
			.upToNextMajor(from: "1.19.4")
		),
	],
	targets: [
		.target(
			name: "SwiftSnippets",
			dependencies: [
				.product(
					name: "Snippets",
					package: "swift-snippets"
				),
				.product(
					name: "Casification",
					package: "swift-casification"
				),
				.product(
					name: "SwiftKeywords",
					package: "swiftlang-keywords"
				),
				.product(
					name: "ArrayBuilder",
					package: "swift-result-builders"
				),
			]
		),
		.testTarget(
			name: "SwiftSnippetsTests",
			dependencies: [
				.target(name: "SwiftSnippets"),
				.product(
					name: "SnapshotTestingCustomDump",
					package: "swift-snapshot-testing"
				),
			]
		),
	],
	swiftLanguageModes: [.v6]
)
