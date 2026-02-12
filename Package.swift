// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "OneWP",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "OneWP",
            exclude: ["Resources/Info.plist"],
            resources: [.copy("Resources/wallpaper.html")],
            swiftSettings: [.swiftLanguageMode(.v5)]
        )
    ]
)
