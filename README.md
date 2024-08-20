# GameControllerKit

GameControllerKit is a Swift package that makes it easy to work with game controllers on iOS, macOS, and tvOS. It provides a simple API to connect to game controllers, read input from them, and control their lights and haptics.

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2F0xWDG%2FGameControllerKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/0xWDG/GameControllerKit)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2F0xWDG%2FGameControllerKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/0xWDG/GameControllerKit)
[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager)
![License](https://img.shields.io/github/license/0xWDG/GameControllerKit)

## Requirements

- Swift 5.9+ (Xcode 15+)
- iOS 13+, macOS 10.15+, tvOS 16+

## Installation (Pakage.swift)

```swift
dependencies: [
    .package(url: "https://github.com/0xWDG/GameControllerKit.git", branch: "main"),
],
targets: [
    .target(name: "MyTarget", dependencies: [
        .product(name: "GameControllerKit", package: "GameControllerKit"),
    ]),
]
```

## Installation (Xcode)

1. In Xcode, open your project and navigate to **File** → **Swift Packages** → **Add Package Dependency...**
2. Paste the repository URL (`https://github.com/0xWDG/GameControllerKit`) and click **Next**.
3. Click **Finish**.

## Usage

```swift
import SwiftUI
import GameControllerKit

struct ContentView: View {
    /// The game controller kit
    @State
    var gameController = GameControllerKit()

    /// Log
    @State
    var log: [String] = []

    var body: some View {
        VStack {
            Button {
                gameController.set(color: .GCKRandom)
            } label: {
                Text("Random Color")
            }

            Text("Controller: \(gameController.controller?.productCategory ?? "None"), " +
                 "\((gameController.controllerType ?? .generic).description)")
            Text("Last action:\n\(String(describing: gameController.lastAction)).")

            GCKControllerView()
                .environmentObject(gameController)

            List {
                ForEach(log.reversed(), id: \.self) { text in
                    Text(text)
                }
            }
        }
        .padding()
        .onAppear {
            gameController.set(handler: handler)
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }

    /// Handler
    ///
    /// - Parameters:
    ///   - action: action
    ///   - pressed: is the button pressed?
    ///   - controller: which controller?
    public func handler(
        action: GCKAction,
        pressed: Bool,
        controller: GCKController
    ) {
        log.append(
            "\(String(describing: action)), \(pressed ? "Pressed" : "Unpressed"), " +
            "Controller #id \(String(describing: controller.playerIndex.rawValue))"
        )

        if action == .buttonA && pressed {
            // set to a random color
            gameController.set(color: .GCKRandom)
        }
    }
}
```

## Image of Usage Demo App

![C65552DF-04CC-493E-AD73-C385A7CEC53C](https://github.com/user-attachments/assets/7bae192c-41ae-42d5-ad52-e204de73b3a0)

## Contact

We can get in touch via [Mastodon](https://mastodon.social/@0xWDG), [Twitter/X](https://twitter.com/0xWDG), [Discord](https://discordapp.com/users/918438083861573692), [Email](mailto:email@wesleydegroot.nl), [Website](https://wesleydegroot.nl).

Interested learning more about Swift? [Check out my blog](https://wesleydegroot.nl/blog/).
