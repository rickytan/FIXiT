// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "FIXiT",
    platforms: [.iOS(.v10)],
    products: [
        .library(name: "FIXiT", targets: ["FIXiT"]),
    ],
    targets: [
        .target(
            name: "FIXiT",
            path: "FIXIT",
            exclude: ["Classes/FIXiT.mm"],
            sources: [
                "Classes/JSValue+FIXiT.m",
                "Classes/NSInvocation+FIXiT.m",
                "Classes/NSObject+FIXiT.mm",
                "SwiftPackage/FIXiT.mm",
            ],
            resources: [.copy("Assets/FIXiT.bundle")],
            publicHeadersPath: "SwiftPackage/include",
            linkerSettings: [
                .linkedFramework("Foundation"),
                .linkedFramework("JavaScriptCore"),
                .linkedFramework("UIKit"),
                .linkedLibrary("c++"),
            ]
        ),
        .testTarget(
            name: "FIXiTPackageTests",
            dependencies: ["FIXiT"]
        ),
    ]
)
