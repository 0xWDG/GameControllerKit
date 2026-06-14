//
//  GCKControllerView.swift
//  GameControllerKit
//
//  Created by Wesley de Groot on 20/08/2024.
//

import GameController
import SwiftUI

/// A visual representation of the currently connected game controller.
///
/// The view adapts its controls and labels to PlayStation, Xbox, Siri Remote,
/// and generic controllers. The most recently used control is highlighted.
public struct GCKControllerView: View {
    @StateObject
    private var gameControllerKit: GameControllerKit

    /// Initialize a controller view with its own controller manager.
    public init() {
        _gameControllerKit = StateObject(wrappedValue: GameControllerKit())
    }

    /// Initialize a controller view using an existing controller manager.
    ///
    /// - Parameter gameControllerKit: The controller manager whose state the view displays.
    public init(_ gameControllerKit: GameControllerKit) {
        _gameControllerKit = StateObject(wrappedValue: gameControllerKit)
    }

    public var body: some View {
        GCKControllerContent(
            controllerType: gameControllerKit.controllerType,
            action: gameControllerKit.lastAction,
            lightColor: gameControllerKit.controller?.light?.color
        )
    }
}

private struct GCKControllerContent: View {
    let controllerType: GCKControllerType?
    let action: GCKAction
    let lightColor: GCColor?

    var body: some View {
        VStack(spacing: 16) {
            if let controllerType {
                GCKControllerHeader(controllerType: controllerType)

                if controllerType == .siriRemote {
                    GCKSiriRemote(action: action)
                } else {
                    GCKGamepad(
                        configuration: .configuration(for: controllerType),
                        action: action,
                        lightColor: lightColor
                    )
                }
            } else {
                GCKDisconnectedController()
            }
        }
        .padding()
        .frame(maxWidth: 640)
        .animation(.default, value: controllerType)
    }
}

private struct GCKControllerHeader: View {
    let controllerType: GCKControllerType

    var body: some View {
        Label {
            Text(controllerType.description)
                .font(.headline)
        } icon: {
            Image(systemName: controllerType == .siriRemote ? "appletvremote.gen4" : "gamecontroller.fill")
        }
        .foregroundStyle(.secondary)
        .accessibilityLabel("Connected controller: \(controllerType.description)")
    }
}

private struct GCKDisconnectedController: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "gamecontroller")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No Controller Connected")
                .font(.headline)
            Text("Connect a game controller to see its available controls.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(minHeight: 240)
    }
}

private struct GCKGamepad: View {
    let configuration: GCKGamepadConfiguration
    let action: GCKAction
    let lightColor: GCColor?

    var body: some View {
        VStack(spacing: 14) {
            GCKShoulderRow(
                leadingLabel: configuration.leftTriggerLabel,
                trailingLabel: configuration.rightTriggerLabel,
                leadingAction: .leftTrigger,
                trailingAction: .rightTrigger,
                action: action
            )
            GCKShoulderRow(
                leadingLabel: configuration.leftShoulderLabel,
                trailingLabel: configuration.rightShoulderLabel,
                leadingAction: .leftShoulder,
                trailingAction: .rightShoulder,
                action: action
            )

            GCKCenterButtons(configuration: configuration, action: action)

            if configuration.hasTouchpad {
                GCKTouchpad(action: action, lightColor: lightColor)
            }

            if configuration.usesAsymmetricLayout {
                GCKXboxControlLayout(configuration: configuration, action: action)
            } else {
                GCKSymmetricControlLayout(configuration: configuration, action: action)
            }

            if configuration.hasPaddles {
                GCKPaddleButtons(action: action)
            }
        }
        .padding(20)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 32))
        .overlay {
            RoundedRectangle(cornerRadius: 32)
                .stroke(.secondary.opacity(0.35), lineWidth: 2)
        }
    }
}

private struct GCKShoulderRow: View {
    let leadingLabel: String
    let trailingLabel: String
    let leadingAction: GCKAction
    let trailingAction: GCKAction
    let action: GCKAction

    var body: some View {
        HStack {
            GCKControlButton(
                label: leadingLabel,
                isActive: action == leadingAction,
                shape: .roundedRectangle
            )
            Spacer()
            GCKControlButton(
                label: trailingLabel,
                isActive: action == trailingAction,
                shape: .roundedRectangle
            )
        }
    }
}

private struct GCKCenterButtons: View {
    let configuration: GCKGamepadConfiguration
    let action: GCKAction

    var body: some View {
        HStack(spacing: 24) {
            GCKControlButton(
                label: configuration.optionsLabel,
                isActive: action == configuration.optionsAction,
                shape: .capsule,
                size: .small
            )
            GCKControlButton(
                label: configuration.homeLabel,
                isActive: action == .buttonHome,
                shape: .circle,
                size: .small
            )
            GCKControlButton(
                label: configuration.menuLabel,
                isActive: action == .buttonMenu,
                shape: .capsule,
                size: .small
            )
        }
    }
}

private struct GCKTouchpad: View {
    let action: GCKAction
    let lightColor: GCColor?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(action.touchpadAction ? Color.accentColor.opacity(0.35) : Color.clear)
            RoundedRectangle(cornerRadius: 12)
                .stroke(controllerLightColor, lineWidth: 3)
            Text(action.touchpadAction ? String(describing: action) : "Touchpad")
                .font(.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal)
        }
        .frame(maxWidth: 220, minHeight: 64)
        .accessibilityLabel("Touchpad")
        .accessibilityAddTraits(action.touchpadAction ? .isSelected : [])
    }

    private var controllerLightColor: Color {
        guard let lightColor else {
            return .secondary
        }

        return Color(
            red: Double(lightColor.red),
            green: Double(lightColor.green),
            blue: Double(lightColor.blue)
        )
    }
}

private struct GCKSymmetricControlLayout: View {
    let configuration: GCKGamepadConfiguration
    let action: GCKAction

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                GCKDirectionalPad(action: action)
                Spacer(minLength: 32)
                GCKFaceButtons(labels: configuration.faceButtonLabels, action: action)
            }

            HStack {
                GCKThumbstick(label: "L", side: .left, action: action)
                Spacer()
                GCKThumbstick(label: "R", side: .right, action: action)
            }
        }
    }
}

private struct GCKXboxControlLayout: View {
    let configuration: GCKGamepadConfiguration
    let action: GCKAction

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                GCKThumbstick(label: "L", side: .left, action: action)
                Spacer(minLength: 32)
                GCKFaceButtons(labels: configuration.faceButtonLabels, action: action)
            }

            HStack {
                GCKDirectionalPad(action: action)
                Spacer()
                GCKControlButton(
                    label: "Share",
                    isActive: action == .shareButton,
                    shape: .capsule,
                    size: .small
                )
                Spacer()
                GCKThumbstick(label: "R", side: .right, action: action)
            }
        }
    }
}

private struct GCKDirectionalPad: View {
    let action: GCKAction

    var body: some View {
        VStack(spacing: 3) {
            HStack(spacing: 3) {
                Color.clear.frame(width: 34, height: 34)
                GCKControlButton(label: "↑", isActive: action == .dpadUp, shape: .roundedRectangle)
                Color.clear.frame(width: 34, height: 34)
            }
            HStack(spacing: 3) {
                GCKControlButton(label: "←", isActive: action == .dpadLeft, shape: .roundedRectangle)
                Color.secondary.opacity(0.25).frame(width: 34, height: 34)
                GCKControlButton(label: "→", isActive: action == .dpadRight, shape: .roundedRectangle)
            }
            HStack(spacing: 3) {
                Color.clear.frame(width: 34, height: 34)
                GCKControlButton(label: "↓", isActive: action == .dpadDown, shape: .roundedRectangle)
                Color.clear.frame(width: 34, height: 34)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Directional pad")
    }
}

private struct GCKFaceButtons: View {
    let labels: GCKFaceButtonLabels
    let action: GCKAction

    var body: some View {
        VStack(spacing: 7) {
            HStack(spacing: 7) {
                Color.clear.frame(width: 34, height: 34)
                faceButton(labels.top, action: .buttonY)
                Color.clear.frame(width: 34, height: 34)
            }
            HStack(spacing: 7) {
                faceButton(labels.leading, action: .buttonX)
                Color.clear.frame(width: 34, height: 34)
                faceButton(labels.trailing, action: .buttonB)
            }
            HStack(spacing: 7) {
                Color.clear.frame(width: 34, height: 34)
                faceButton(labels.bottom, action: .buttonA)
                Color.clear.frame(width: 34, height: 34)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Face buttons")
    }

    private func faceButton(_ label: String, action buttonAction: GCKAction) -> some View {
        GCKControlButton(label: label, isActive: action == buttonAction, shape: .circle)
    }
}

private struct GCKThumbstick: View {
    enum Side {
        case left
        case right
    }

    let label: String
    let side: Side
    let action: GCKAction

    var body: some View {
        ZStack {
            Circle()
                .fill(isPressed ? Color.accentColor.opacity(0.35) : Color.secondary.opacity(0.12))
            Circle()
                .stroke(.secondary, lineWidth: 2)
            Text(direction.isEmpty ? label : direction)
                .font(.headline)
        }
        .frame(width: 58, height: 58)
        .accessibilityLabel(side == .left ? "Left thumbstick" : "Right thumbstick")
        .accessibilityValue(direction.isEmpty ? "Centered" : direction)
        .accessibilityAddTraits(isPressed ? .isSelected : [])
    }

    private var isPressed: Bool {
        switch side {
        case .left:
            action == .leftThumbstickButton
        case .right:
            action == .rightThumbstickButton
        }
    }

    private var direction: String {
        switch (side, action) {
        case (.left, .leftThumbstick), (.right, .rightThumbstick):
            action.position.arrowRepresentation
        default:
            ""
        }
    }
}

private struct GCKPaddleButtons: View {
    let action: GCKAction

    var body: some View {
        VStack(spacing: 8) {
            Text("Paddles")
                .font(.caption)
                .foregroundStyle(.secondary)

            VStack {
                HStack {
                    paddle("P1", action: .paddleButton1)
                    paddle("P2", action: .paddleButton2)
                }
                HStack {
                    paddle("P3", action: .paddleButton3)
                    paddle("P4", action: .paddleButton4)
                }
            }
        }
    }

    private func paddle(_ label: String, action paddleAction: GCKAction) -> some View {
        GCKControlButton(
            label: label,
            isActive: action == paddleAction,
            shape: .capsule,
            size: .small
        )
    }
}

private struct GCKSiriRemote: View {
    let action: GCKAction

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(action.touchpadAction ? Color.accentColor.opacity(0.35) : Color.secondary.opacity(0.12))
                Circle()
                    .stroke(.secondary, lineWidth: 2)
                GCKDirectionalPad(action: action)
                    .scaleEffect(0.72)
            }
            .frame(width: 150, height: 150)
            .accessibilityLabel("Clickpad")

            GCKControlButton(
                label: "Menu",
                isActive: action == .buttonMenu,
                shape: .circle
            )
            GCKControlButton(
                label: "Home",
                isActive: action == .buttonHome,
                shape: .circle
            )
        }
        .padding(20)
        .frame(width: 190)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 40))
        .overlay {
            RoundedRectangle(cornerRadius: 40)
                .stroke(.secondary.opacity(0.35), lineWidth: 2)
        }
    }
}

private struct GCKControlButton: View {
    enum Shape {
        case circle
        case capsule
        case roundedRectangle
    }

    enum Size {
        case standard
        case small
    }

    let label: String
    let isActive: Bool
    let shape: Shape
    var size: Size = .standard

    var body: some View {
        Text(label)
            .font(size == .small ? .caption : .body)
            .fontWeight(.semibold)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(width: width, height: height)
            .background(background)
            .overlay(border)
            .accessibilityAddTraits(isActive ? .isSelected : [])
    }

    @ViewBuilder
    private var background: some View {
        switch shape {
        case .circle:
            Circle().fill(fillColor)
        case .capsule:
            Capsule().fill(fillColor)
        case .roundedRectangle:
            RoundedRectangle(cornerRadius: 8).fill(fillColor)
        }
    }

    @ViewBuilder
    private var border: some View {
        switch shape {
        case .circle:
            Circle().stroke(.secondary, lineWidth: 1.5)
        case .capsule:
            Capsule().stroke(.secondary, lineWidth: 1.5)
        case .roundedRectangle:
            RoundedRectangle(cornerRadius: 8).stroke(.secondary, lineWidth: 1.5)
        }
    }

    private var fillColor: Color {
        isActive ? Color.accentColor.opacity(0.45) : Color.secondary.opacity(0.12)
    }

    private var width: CGFloat {
        switch (shape, size) {
        case (.capsule, .small):
            54
        case (.roundedRectangle, .standard):
            76
        default:
            34
        }
    }

    private var height: CGFloat {
        size == .small ? 30 : 34
    }
}

private struct GCKFaceButtonLabels {
    let top: String
    let trailing: String
    let bottom: String
    let leading: String
}

private struct GCKGamepadConfiguration {
    let faceButtonLabels: GCKFaceButtonLabels
    let leftShoulderLabel: String
    let rightShoulderLabel: String
    let leftTriggerLabel: String
    let rightTriggerLabel: String
    let optionsLabel: String
    let optionsAction: GCKAction
    let menuLabel: String
    let homeLabel: String
    let hasTouchpad: Bool
    let hasPaddles: Bool
    let usesAsymmetricLayout: Bool

    static func configuration(for controllerType: GCKControllerType) -> Self {
        switch controllerType {
        case .dualSense, .dualShock:
            Self(
                faceButtonLabels: .init(top: "△", trailing: "○", bottom: "×", leading: "□"),
                leftShoulderLabel: "L1",
                rightShoulderLabel: "R1",
                leftTriggerLabel: "L2",
                rightTriggerLabel: "R2",
                optionsLabel: "Create",
                optionsAction: .buttonOptions,
                menuLabel: "Options",
                homeLabel: "PS",
                hasTouchpad: true,
                hasPaddles: false,
                usesAsymmetricLayout: false
            )
        case .xbox:
            Self(
                faceButtonLabels: .init(top: "Y", trailing: "B", bottom: "A", leading: "X"),
                leftShoulderLabel: "LB",
                rightShoulderLabel: "RB",
                leftTriggerLabel: "LT",
                rightTriggerLabel: "RT",
                optionsLabel: "View",
                optionsAction: .buttonOptions,
                menuLabel: "Menu",
                homeLabel: "Xbox",
                hasTouchpad: false,
                hasPaddles: true,
                usesAsymmetricLayout: true
            )
        case .generic, .siriRemote:
            Self(
                faceButtonLabels: .init(top: "Y", trailing: "B", bottom: "A", leading: "X"),
                leftShoulderLabel: "L1",
                rightShoulderLabel: "R1",
                leftTriggerLabel: "L2",
                rightTriggerLabel: "R2",
                optionsLabel: "Options",
                optionsAction: .buttonOptions,
                menuLabel: "Menu",
                homeLabel: "Home",
                hasTouchpad: false,
                hasPaddles: false,
                usesAsymmetricLayout: false
            )
        }
    }
}

private struct GCKControllerViewPreview: PreviewProvider {
    static var previews: some View {
        GCKControllerView()
    }
}
// swiftlint:disable:this file_length
