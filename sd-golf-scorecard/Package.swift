// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SdGolfScorecard",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "SdGolfScorecard",
            path: "Sources/SdGolfScorecard"
        )
    ]
)
