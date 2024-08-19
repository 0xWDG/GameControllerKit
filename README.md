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
    @State var gameController = GameControllerKit()

    @State var log: [String] = []

    func handler(action: GCKAction, pressed: Bool) {
        log.append(
            "\(String(describing: action)), \(pressed ? "Pressed" : "Unpressed")"
        )

        if action == .buttonA && pressed {
            // When pressed on A or X (on PlayStation controllers), set the color to a random color.
            // Colors are only supported on controllers that have a light, like DualShock and Dualsense controllers.
            gameController.set(color: .GCKRandom)
        }

        if case .rightThumbstick = action {
            log.append("Right thumbstick: " +
                String(
                    describing: gameController.translate(
                        action: action
                    )
                )
            )
        }

        if case .leftThumbstick = action {
            log.append("Left thumbstick: " +
                String(
                    describing: gameController.translate(
                        action: action
                    )
                )
            )
        }
    }

    var body: some View {
        VStack {
            Button {
                gameController.set(color: .GCKRandom)
            } label: {
                Text("Random Color")
            }

            Text("Controller: \(gameController.controller?.productCategory ?? "None"), \((gameController.controllerType ?? .generic).description)")
            Text("Left: \(String(describing: gameController.leftThumbstick))")
            Text("Right: \(String(describing: gameController.rightThumbstick)).")
            Text("Last action: \(String(describing: gameController.lastAction)).")

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
}
```

## Image of Usage Demo App
![78BFDAE4-FCC5-4C88-A818-CA921E1A1A06](https://github.com/user-attachments/assets/ef05f613-6b8d-4058-ac6d-db098b3e97b2)

## Contact

We can get in touch via [Mastodon](https://mastodon.social/@0xWDG), [Twitter/X](https://twitter.com/0xWDG), [Discord](https://discordapp.com/users/918438083861573692), [Email](mailto:email@wesleydegroot.nl), [Website](https://wesleydegroot.nl).

Interested learning more about Swift? [Check out my blog](https://wesleydegroot.nl/blog/).
