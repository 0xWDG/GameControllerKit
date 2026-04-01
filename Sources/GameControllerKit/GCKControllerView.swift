//
//  ControllerView.swift
//  GCK
//
//  Created by Wesley de Groot on 20/08/2024.
//

import SwiftUI
import GameController

/// Controller view.
public struct GCKControllerView: View {
    // swiftlint:disable:previous type_body_length

    @EnvironmentObject
    var GCKit: GameControllerKit

    var action: GCKAction {
        GCKit.lastAction
    }

    /// Initialize a controller view.
    public init() { }

    public var body: some View {
        VStack {
            if GCKit.controller == nil {
                noControllerView
            } else {
                controllerTypeLabel

                GCKControllerShapeView(controllerType: GCKit.controllerType)
                    .padding(.bottom, 8)

                // L2, R2
                shoulder2
                shoulder1

                selectMenu

                HStack {
                    dPad
                    if let controller = GCKit.controller,
                       controller.hasTouchPad {
                        touchPad
                    }
                    controllerButtons
                }

                thumbSticks

                if let controller = GCKit.controller,
                   controller.hasPaddleButtons {
                    paddleButtons
                }
            }
        }
        .padding(50)
    }

    var noControllerView: some View {
        VStack(spacing: 16) {
            Image(systemName: "gamecontroller")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text("No Controller Connected")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("Connect a game controller to see its layout.")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var controllerTypeLabel: some View {
        HStack {
            Spacer()
            Text(GCKit.controllerType?.description ?? "Unknown Controller")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    /// Returns the appropriate button layout for the connected controller type.
    @ViewBuilder
    var controllerButtons: some View {
        if let controllerType = GCKit.controllerType {
            switch controllerType {
            case .dualSense, .dualShock:
                playstationButtons
            case .xbox:
                xboxButtons
            default:
                genericButtons
            }
        } else {
            genericButtons
        }
    }

    var shoulder2: some View {
        HStack {
            Text("L2")
                .padding(3)
                .frame(width: 75, height: 25)
                .background(Rectangle().stroke())
                .background(
                    Rectangle()
                        .fill()
                        .foregroundStyle(
                            action == .leftTrigger ? .yellow : .clear
                        )
                )

            Spacer()
            Text("R2")
                .padding(3)
                .frame(width: 75, height: 25)
                .background(Rectangle().stroke())
                .background(
                    Rectangle()
                        .fill()
                        .foregroundStyle(
                            action == .rightTrigger ? .yellow : .clear
                        )
                )
        }
    }

    var shoulder1: some View {
        HStack {
            Text("L1")
                .padding(3)
                .frame(width: 75, height: 25)
                .background(Rectangle().stroke())
                .background(
                    Rectangle()
                        .fill()
                        .foregroundStyle(
                            action == .leftShoulder ? .yellow : .clear
                        )
                )

            Spacer()
            Text("R1")
                .padding(3)
                .frame(width: 75, height: 25)
                .background(Rectangle().stroke())
                .background(
                    Rectangle()
                        .fill()
                        .foregroundStyle(
                            action == .rightShoulder ? .yellow : .clear
                        )
                )
        }
    }

    var selectMenu: some View {
        HStack {
            Spacer()

            Text("O")
                .padding(3)
                .frame(width: 25, height: 25)
                .background(Rectangle().stroke())
                .background(
                    Rectangle()
                        .fill()
                        .foregroundStyle(
                            action == .buttonOptions ? .yellow : .clear
                        )
                )

            Spacer()

            Text("M")
                .padding(3)
                .frame(width: 25, height: 25)
                .background(Rectangle().stroke())
                .background(
                    Rectangle()
                        .fill()
                        .foregroundStyle(
                            action == .buttonMenu ? .yellow : .clear
                        )
                )

            Spacer()
        }
    }

    var dPad: some View {
        VStack {
            Text("U")
                .padding(3)
                .frame(width: 25, height: 25)
                .background(Rectangle().stroke())
                .background(
                    Rectangle()
                        .fill()
                        .foregroundStyle(
                            action == .dpadUp ? .yellow : .clear
                        )
                )

            HStack {
                Text("L")
                    .padding(3)
                    .frame(width: 25, height: 25)
                    .background(Rectangle().stroke())
                    .background(
                        Rectangle()
                            .fill()
                            .foregroundStyle(
                                action == .dpadLeft ? .yellow : .clear
                            )
                    )
                    .padding(.trailing, 25)

                Text("R")
                    .padding(3)
                    .frame(width: 25, height: 25)
                    .background(Rectangle().stroke())
                    .background(
                        Rectangle()
                            .fill()
                            .foregroundStyle(
                                action == .dpadRight ? .yellow : .clear
                            )
                    )
            }

            Text("D")
                .padding(3)
                .frame(width: 25, height: 25)
                .background(Rectangle().stroke())
                .background(
                    Rectangle()
                        .fill()
                        .foregroundStyle(
                            action == .dpadDown ? .yellow : .clear
                        )
                )
        }
    }

    var touchPad: some View {
        HStack {
            Spacer()

            Text(
                action.touchPadAction
                ? String(describing: action)
                : "TouchPad"
            )
            .padding(3)
            .frame(minWidth: 100, minHeight: 50)
            .background(
                Rectangle()
                    .stroke()
                    .foregroundStyle(
                        Color(cgColor: .init(
                            red: CGFloat(GCKit.controller?.light?.color.red ?? 0),
                            green: CGFloat(GCKit.controller?.light?.color.green ?? 0),
                            blue: CGFloat(GCKit.controller?.light?.color.blue ?? 0),
                            alpha: 1
                        ))
                    )
            )
            .background(
                Rectangle()
                    .fill()
                    .foregroundStyle(action.touchPadAction ? .yellow : .clear)
            )
            .padding(.bottom, 50)

            Spacer()
        }
    }

    private func controllerButton(
        label: String,
        strokeColor: Color = .primary,
        activeColor: Color = .yellow,
        targetAction: GCKAction
    ) -> some View {
        Text(label)
            .padding(3)
            .frame(width: 25, height: 25)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(strokeColor)
            )
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill()
                    .foregroundStyle(
                        action == targetAction ? activeColor : .clear
                    )
            )
    }

    var playstationButtons: some View {
        VStack {
            // Triangle (top) - green
            controllerButton(label: "△", strokeColor: .green, activeColor: .green, targetAction: .buttonY)

            HStack {
                // Square (left) - pink
                controllerButton(label: "□", strokeColor: .pink, activeColor: .pink, targetAction: .buttonX)
                    .padding(.trailing, 25)

                // Circle (right) - red
                controllerButton(label: "○", strokeColor: .red, activeColor: .red, targetAction: .buttonB)
            }

            // Cross (bottom) - blue
            controllerButton(label: "✕", strokeColor: .blue, activeColor: .blue, targetAction: .buttonA)
        }
    }

    var xboxButtons: some View {
        VStack {
            // Y (top) - yellow
            controllerButton(label: "Y", strokeColor: .yellow, activeColor: .yellow, targetAction: .buttonY)

            HStack {
                // X (left) - blue
                controllerButton(label: "X", strokeColor: .blue, activeColor: .blue, targetAction: .buttonX)
                    .padding(.trailing, 25)

                // B (right) - red
                controllerButton(label: "B", strokeColor: .red, activeColor: .red, targetAction: .buttonB)
            }

            // A (bottom) - green
            controllerButton(label: "A", strokeColor: .green, activeColor: .green, targetAction: .buttonA)
        }
    }

    var genericButtons: some View {
        VStack {
            controllerButton(label: "Y", targetAction: .buttonY)

            HStack {
                controllerButton(label: "X", targetAction: .buttonX)
                    .padding(.trailing, 25)

                controllerButton(label: "B", targetAction: .buttonB)
            }

            controllerButton(label: "A", targetAction: .buttonA)
        }
    }

    var thumbSticks: some View {
        HStack {
            Spacer()

            Text("L")
                .padding(3)
                .frame(width: 50, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke()
                )
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill()
                        .foregroundStyle(
                            action == .leftThumbstickButton ? .yellow : .clear
                        )
                )
                .overlay {
                    if case .leftThumbstick = action {
                        switch action.position {
                        case .up:
                            Text("↑")
                                .padding(.bottom)

                        case .upRight:
                            Text("↗")
                                .padding(.bottom)
                                .padding(.leading)

                        case .right:
                            Text("→")
                                .padding(.leading)

                        case .downRight:
                            Text("↘")
                                .padding(.top)
                                .padding(.leading)

                        case .down:
                            Text("↓")
                                .padding(.top)

                        case .downLeft:
                            Text("↙")
                                .padding(.top)
                                .padding(.trailing)

                        case .left:
                            Text("←")
                                .padding(.trailing)

                        case .upLeft:
                            Text("↖")
                                .padding(.bottom)
                                .padding(.trailing)

                        default:
                            Text("")
                        }
                    }
                }

            Spacer()

            Text("H")
                .padding(3)
                .frame(width: 25, height: 25)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke()
                )
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill()
                        .foregroundStyle(
                            action == .buttonHome ? .yellow : .clear
                        )
                )

            Spacer()

            Text("R")
                .padding(3)
                .frame(width: 50, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke()
                )
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill()
                        .foregroundStyle(
                            action == .rightThumbstickButton ? .yellow : .clear
                        )
                )
                .overlay {
                    if case .rightThumbstick = action {
                        switch action.position {
                        case .up:
                            Text("↑")
                                .padding(.bottom)

                        case .upRight:
                            Text("↗")
                                .padding(.bottom)
                                .padding(.leading)

                        case .right:
                            Text("→")
                                .padding(.leading)

                        case .downRight:
                            Text("↘")
                                .padding(.top)
                                .padding(.leading)

                        case .down:
                            Text("↓")
                                .padding(.top)

                        case .downLeft:
                            Text("↙")
                                .padding(.top)
                                .padding(.trailing)

                        case .left:
                            Text("←")
                                .padding(.trailing)

                        case .upLeft:
                            Text("↖")
                                .padding(.bottom)
                                .padding(.trailing)

                        default:
                            Text("")
                        }
                    }
                }

            Spacer()
        }
    }

    var paddleButtons: some View {
        VStack {
            HStack {
                Text("Paddle 1")
                    .padding(3)
                    .frame(width: 75, height: 25)
                    .background(Rectangle().stroke())
                    .background(
                        Rectangle()
                            .fill()
                            .foregroundStyle(
                                action == .paddleButton1 ? .yellow : .clear
                            )
                    )

                Spacer()
                Text("Paddle 2")
                    .padding(3)
                    .frame(width: 75, height: 25)
                    .background(Rectangle().stroke())
                    .background(
                        Rectangle()
                            .fill()
                            .foregroundStyle(
                                action == .paddleButton2 ? .yellow : .clear
                            )
                    )
            }
            HStack {
                Text("Paddle 3")
                    .padding(3)
                    .frame(width: 75, height: 25)
                    .background(Rectangle().stroke())
                    .background(
                        Rectangle()
                            .fill()
                            .foregroundStyle(
                                action == .paddleButton3 ? .yellow : .clear
                            )
                    )

                Spacer()
                Text("Paddle 4")
                    .padding(3)
                    .frame(width: 75, height: 25)
                    .background(Rectangle().stroke())
                    .background(
                        Rectangle()
                            .fill()
                            .foregroundStyle(
                                action == .paddleButton4 ? .yellow : .clear
                            )
                    )
            }
        }
    }
}

struct GCKControllerViewPreview: PreviewProvider {
    static var previews: some View {
        GCKControllerView()
            .environmentObject(GameControllerKit())
    }
}
// swiftlint:disable:this file_length
