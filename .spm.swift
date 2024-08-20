#!/usr/bin/swift

//
//  spm.swift
//  This script will add a header to all .swift files in the current directory.
//  And can test the package for various platforms.
//
//  Created by Wesley de Groot on 2024-08-06.
//  https://wesleydegroot.nl
//
//  https://github.com/0xWDG/spm-template
//  MIT License

// To compile this script to a binary, run:
// swiftc .spm.swift -o spm

// swiftlint:disable all
import Foundation

let fileManager = FileManager.default
var internalProductName: String?
var productName: String {
    get {
        if let productName = internalProductName {
            return productName
        }

        if fileManager.fileExists(atPath: "Package.swift") {
            guard let package = try? String(contentsOf: URL(fileURLWithPath: "Package.swift"), encoding: .utf8),
                  let productName = package
                .components(separatedBy: .newlines)
                .first(where: { $0.contains("name:") })?
                .components(separatedBy: .whitespaces)
                .last?
                .replacingOccurrences(of: "\"", with: "")
                .replacingOccurrences(of: ",", with: "") else {
                printC("Could not find product name in Package.swift", color: CLIColors.red)
                exit(2)
            }

            return productName
        } else {
            printC("Package.swift not found, please provide package name", color: CLIColors.red)
            return ""
        }
    }
    set {
        internalProductName = newValue
    }
}

struct CLIColors {
    static let red = "\u{001B}[0;31m"
    static let green = "\u{001B}[0;32m"
    static let yellow = "\u{001B}[0;33m"
    static let orange = "\u{001B}[0;38;5;208m"
    static let blue = "\u{001B}[0;34m"
    static let magenta = "\u{001B}[0;35m"
    static let cyan = "\u{001B}[0;36m"
    static let white = "\u{001B}[0;37m"
    static let reset = "\u{001B}[0;0m"
    static let clear = "\u{001B}[0;0m"
}

func printUsage() {
    print("Usage: \(CommandLine.arguments[0]) <command>")
    print("Commands:")
    print("  create <package name> - Add a header to all .swift files in the current directory")
    print("  header - Update the header for all .swift files in the current directory")
    print("  readme - Generate a README.md file for the package")
    print("  build - Build the package for all platforms")
    print("  test - Test the package for all platforms")
}

func printC(_ text: String, terminator: String = "\n", color: String = CLIColors.reset) {
    if terminator == "\n" {
        print("\(color)\(text)                        \(CLIColors.reset)")
    } else {
        print("\(color)\(text)\(CLIColors.reset)", terminator: terminator)
        fflush(stdout)
    }
}

if CommandLine.argc < 2 {
    printUsage()
    exit(1)
}

if CommandLine.arguments[1] == "create" && CommandLine.argc < 3 {
    print("Usage: \(CommandLine.arguments[0]) create <package name>")
    exit(1)
}

if CommandLine.arguments[1] == "create" && CommandLine.argc == 3 {
    productName = CommandLine.arguments[2]

    if !fileManager.fileExists(atPath: "Package.swift") {
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = ["swift", "package", "init", "--name", productName]
        process.launch()
        process.waitUntilExit()
    }

    /// Change the first line of the Package.swift file
    let package = try String(contentsOf: URL(fileURLWithPath: "Package.swift"), encoding: .utf8)
    let newPackage = package
        .components(separatedBy: .newlines)
        .enumerated()
        .map { index, line in
            if index == 0 {
                return "// swift-tools-version: 5.8.0"
            } else {
                return line
            }
        }
        .joined(separator: "\n")
    try? newPackage.write(to: URL(fileURLWithPath: "Package.swift"), atomically: true, encoding: .utf8)
    printC("Downgraded swift-tools-version to 5.8.0", color: CLIColors.green)

    let spi = """
version: 1
builder:
  configs:
    - documentation_targets: [\(productName)]
"""
    try spi.write(to: URL(fileURLWithPath: ".spi.yml"), atomically: true, encoding: .utf8)

    header()
    generateReadme()
}

if CommandLine.arguments[1] == "header" {
    header()
}

if CommandLine.arguments[1] == "readme" {
    generateReadme()
}

if CommandLine.arguments[1] == "build" {
    if !fileManager.fileExists(atPath: "Package.swift") {
        printC("Package.swift not found", color: CLIColors.red)
        exit(2)
    }

    // Find platforms in Package.swift
    let package = try String(contentsOf: URL(fileURLWithPath: "Package.swift"), encoding: .utf8)
    var platforms: [String] = []
    var fails = 0

    if package.contains(".iOS") {
        platforms.append("iOS")
    }

    if package.contains(".macOS") {
        platforms.append("macOS")
    }

    if package.contains(".watchOS") {
        platforms.append("watchOS")
    }

    if package.contains(".visionOS") {
        platforms.append("xrOS")
    }

    if package.contains(".tvOS") {
        platforms.append("tvOS")
    }

    if package.contains(".maccatalyst") {
        platforms.append("MacCatalyst")
    }

    if package.contains(".driverkit") {
        printC("DriverKit is not supported, skipped", color: CLIColors.orange)
        // platforms.append("DriverKit")
    }

    if package.contains(".linux") {
        printC("Linux is not supported, skipped", color: CLIColors.orange)
        // platforms.append("Linux")
    }

    if package.contains(".android") {
        printC("Android is not supported, skipped", color: CLIColors.orange)
        // platforms.append("Android")
    }

    if platforms.isEmpty {
        printC("No platforms found in Package.swift, defaulting to all", color: CLIColors.orange)
        platforms = ["iOS", "tvOS", "xrOS", "watchOS", "macOS"]
    }

    printC("Build \(productName) for \(platforms.joined(separator: ", "))...")

    for (number, platform) in platforms.enumerated() {
        printC("Building \(productName) on \(platform). (\(number + 1)/\(platforms.count))", terminator: "\r")
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = [
            "xcrun",
            "xcodebuild",
            "clean",
            "build",
            "-quiet",
            "-scheme", productName,
            "-destination", "generic/platform=\(platform)"
        ]
        process.launch()
        process.waitUntilExit()
        // Check if the process was successful
        if process.terminationStatus != 0 {
            fails += 1
            printC("Failed to build for \(platform) (\(number + 1)/\(platforms.count))", color: CLIColors.red)
        } else {
            printC("Build for \(platform) successful (\(number + 1)/\(platforms.count)) ", color: CLIColors.green)
        }
    }

    if fails > 0 {
        printC("Failed to build for \(fails) platforms", color: CLIColors.red)
    } else {
        printC("Build for all platforms successful", color: CLIColors.green)
    }

    exit(0)
}

if CommandLine.arguments[1] == "test" {
    printC("Testing is not yet implemented", color: CLIColors.red)
    exit(99)
}

func header() {
    // Search for all .swift files
    let enumerator = fileManager.enumerator(atPath: ".")
    while let element = enumerator?.nextObject() as? String {
        if element.hasSuffix(".swift") {
            var headerLines = 0

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.string(from: Date())

            var createdBy = "//  Created by Wesley de Groot on \(date)."
            let file = element
            let path = URL(fileURLWithPath: file)
            guard let contents = try? String(contentsOf: path, encoding: .utf8) else {
                printC("Failed to read \(file)", color: CLIColors.red)
                continue
            }
            let filename = file.components(separatedBy: "/").last
            var lines = contents.components(separatedBy: .newlines)

            if lines.isEmpty {
                break
            }

            if lines[0].hasPrefix("#!") || file == "Package.swift" {
                continue
            }

            for line in lines {
                if line.hasPrefix("//") {
                    if line.contains("Created by") {
                        createdBy = line
                    }

                    headerLines += 1
                } else {
                    break
                }
            }

            lines.removeFirst(Int(headerLines))

            let header = [
                "//",
                "//  \(filename ?? "")",
                "//  \(productName)",
                "//",
                createdBy,
                "//  https://wesleydegroot.nl",
                "//",
                "//  https://github.com/0xWDG/\(productName)",
                "//  MIT License",
                "//"
            ]

            lines.insert(contentsOf: header, at: 0)
            let newContents = lines.joined(separator: "\n")
            do {
                try newContents.write(to: path, atomically: true, encoding: .utf8)
                printC("Updated header for \(file)", color: CLIColors.green)
            } catch {
                printC("Failed to update header for \(file)", color: CLIColors.red)
            }
        }
    }
}

func generateReadme() {
    var readme = """
# PACKAGENAME

PACKAGENAME is a Swift Package for ...

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2F0xWDG%2FPACKAGENAME%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/0xWDG/PACKAGENAME)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2F0xWDG%2FPACKAGENAME%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/0xWDG/PACKAGENAME)
[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager)
![License](https://img.shields.io/github/license/0xWDG/PACKAGENAME)

## Requirements

- Swift 5.9+ (Xcode 15+)
- iOS 13+, macOS 10.15+

## Installation (Pakage.swift)

```swift
dependencies: [
    .package(url: "https://github.com/0xWDG/PACKAGENAME.git", branch: "main"),
],
targets: [
    .target(name: "MyTarget", dependencies: [
        .product(name: "PACKAGENAME", package: "PACKAGENAME"),
    ]),
]
```

## Installation (Xcode)

1. In Xcode, open your project and navigate to **File** → **Swift Packages** → **Add Package Dependency...**
2. Paste the repository URL (`https://github.com/0xWDG/PACKAGENAME`) and click **Next**.
3. Click **Finish**.

## Usage

```swift
import SwiftUI
import PACKAGENAME

struct ContentView: View {
    var body: some View {
        VStack {
            /// ...
        }
        .padding()
    }
}
```

## Contact

We can get in touch via [Mastodon](https://mastodon.social/@0xWDG), [Twitter/X](https://twitter.com/0xWDG), [Discord](https://discordapp.com/users/918438083861573692), [Email](mailto:email@wesleydegroot.nl), [Website](https://wesleydegroot.nl).

Interested learning more about Swift? [Check out my blog](https://wesleydegroot.nl/blog/).
"""

    readme = readme.replacingOccurrences(of: "PACKAGENAME", with: productName)

    try? readme.write(to: URL(fileURLWithPath: "README.md"), atomically: true, encoding: .utf8)
}

if CommandLine.arguments[1] != "executable" {
    let process = Process()
    process.launchPath = "/usr/bin/env"
    process.arguments = ["swiftc", CommandLine.arguments[0], "-o", "spm"]
    process.launch()
    process.waitUntilExit()

    if process.terminationStatus != 0 {
        printC("Failed to compile script", color: CLIColors.red)
        exit(4)
    } else {
        printC("Script compiled successfully", color: CLIColors.green)
    }
}
// swiftlint:enable all
