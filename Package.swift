// swift-tools-version: 5.9

import PackageDescription

let package = Package(
	name: "article-saviour",
	platforms: [
		.macOS(.v14)
	],
	products: [
		.library(
			name: "HabrDownloader" ,
			targets: [
				"Habr"
			]
		),
	],
	dependencies: [
		.package(url: "https://github.com/scinfu/SwiftSoup", from: "2.3.4"),
		.package(url: "https://github.com/apple/swift-argument-parser", exact: "1.3.0"),
		.package(url: "https://github.com/apple/swift-log", exact: "1.5.4"),
		.package(url: "https://github.com/adorkable/swift-log-format-and-pipe", exact: "0.1.1"),
	],
	targets: [
		.target(name: "Utils"),
		.target(
			name: "Services",
			dependencies: [
				.product(name: "Logging", package: "swift-log"),
			]
		),
		.target(
			name: "HabrCommand",
			dependencies: [
				"Utils",
				"Habr",
			]
		),
		.target(
			name: "Habr",
			dependencies: [
				"Utils",
				"Services",
				"SwiftSoup",
				.product(name: "Logging", package: "swift-log"),
			]
		),
		.target(
			name: "MediumCommand",
			dependencies: [
				"Utils",
				"Medium",
			]
		),
		.target(
			name: "Medium",
			dependencies: [
				"Utils",
				"Services",
				"SwiftSoup",
				.product(name: "Logging", package: "swift-log"),
			]
		),
		.executableTarget(
			name: "savea",
			dependencies: [
				"Utils",
				"HabrCommand",
				"MediumCommand",
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
				.product(name: "Logging", package: "swift-log"),
				.product(name: "LoggingFormatAndPipe", package: "swift-log-format-and-pipe"),
			]
		)
	]
)
