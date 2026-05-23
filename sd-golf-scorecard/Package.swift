// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SdGolfScorecard",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    targets: [
        .target(
            name: "SdGolfScorecardUI",
            path: "Sources/SdGolfScorecardUI"
        ),
        .executableTarget(
            name: "SdGolfScorecard",
            dependencies: ["SdGolfScorecardUI"],
            path: "Sources/SdGolfScorecard"
        )
    ]
)
