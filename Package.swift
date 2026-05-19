// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
   name: "CalendarKit",
   defaultLocalization: "en",
   platforms: [.iOS(.v18)],
   products: [
      // Products define the executables and libraries a package produces, making them visible to other packages.
      .library(
         name: "CalendarKit",
         targets: ["CalendarKit"]),
   ],
   dependencies: [
      .package(url: "https://github.com/thomasccpereira/tcp-core-resources", from: "1.2.2"),
   ],
   targets:[
      .target(
         name: "CalendarKit",
         dependencies: [
            .product(name: "CoreResources", package: "tcp-core-resources"),
         ],
         resources: [
            .process("../Resources/Localizable.xcstrings")
         ]
      ),
      .testTarget(
         name: "CalendarKitTests",
         dependencies: ["CalendarKit"]
      ),
   ]
)

