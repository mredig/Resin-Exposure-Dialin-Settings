// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "Resin Exposure Dialin Settings",
	platforms: [.macOS(.v10_13)],
	products: [
		// Products define the executables and libraries a package produces, and make them visible to other packages.
		.library(
			name: "Resin Exposure Dialin Settings-lib",
			targets: ["Resin Exposure Dialin Settings-lib"]),
		.executable(
			name: "Resin Exposure Dialin Settings",
			targets: ["Resin Exposure Dialin Settings"])
	],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
		.package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
		.executableTarget(
			name: "Resin Exposure Dialin Settings",
			dependencies: [
				"Resin Exposure Dialin Settings-lib",
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
			]),
        .target(
            name: "Resin Exposure Dialin Settings-lib",
            dependencies: []),
        .testTarget(
            name: "Resin Exposure Dialin SettingsTests",
            dependencies: ["Resin Exposure Dialin Settings"]),
    ]
)
