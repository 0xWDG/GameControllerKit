import GameControllerKit
import SwiftUI

@main
struct GameControllerKitDemoApp: App {
    var body: some Scene {
        WindowGroup {
            DemoContentView()
        }
    }
}

private struct DemoContentView: View {
    @StateObject private var gameControllerKit = GameControllerKit()
    @State private var mockControllerType = GCKControllerType.dualSense

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                GCKControllerView(gameControllerKit)

                connectionControls
                mockInputControls
            }
            .padding()
        }
        .frame(minWidth: 520, minHeight: 720)
    }

    private var connectionControls: some View {
        GroupBox("Controller Source") {
            VStack(alignment: .leading, spacing: 12) {
                Picker("Mock controller", selection: $mockControllerType) {
                    ForEach(GCKControllerType.allCases) { controllerType in
                        Text(controllerType.description)
                            .tag(controllerType)
                    }
                }

                HStack {
                    Button("Use Mock Controller") {
                        gameControllerKit.mockController(type: mockControllerType)
                    }
                    Button("Use Connected Controllers") {
                        gameControllerKit.stopMockingController()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var mockInputControls: some View {
        GroupBox("Mock Input") {
            VStack(spacing: 12) {
                HStack {
                    mockButton("A", action: .buttonA)
                    mockButton("B", action: .buttonB)
                    mockButton("X", action: .buttonX)
                    mockButton("Y", action: .buttonY)
                    mockButton("Menu", action: .buttonMenu)
                }

                HStack {
                    mockButton("D-pad Up", action: .dpadUp)
                    mockButton("Left Stick ↗", action: .leftThumbstick(x: 0.8, y: 0.8))
                    mockButton("Right Stick ←", action: .rightThumbstick(x: -1, y: 0))
                    Button("Release") {
                        gameControllerKit.sendMockAction(.none, pressed: false)
                    }
                }
            }
        }
    }

    private func mockButton(_ label: String, action: GCKAction) -> some View {
        Button(label) {
            gameControllerKit.sendMockAction(action)
        }
    }
}
