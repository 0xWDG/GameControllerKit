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

    var controller: GCKController {
        GCKit.controller ?? .withExtendedGamepad()
    }

    var action: GCKAction {
        GCKit.lastAction
    }

    /// Initialize a controller view.
    public init() { }

    public var body: some View {
        VStack {
            // L2, R2
            shoulder2
            shoulder1

            selectMenu

            HStack {
                dPad
                if controller.hasTouchPad {
                    touchPad
                }
                buttons
            }

            thumbSticks
        }
        .padding(50)
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
                            red: CGFloat(controller.light?.color.red ?? 0),
                            green: CGFloat(controller.light?.color.green ?? 0),
                            blue: CGFloat(controller.light?.color.blue ?? 0),
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

    var buttons: some View {
        VStack {
            Text("Y")
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
                            action == .buttonY ? .yellow : .clear
                        )
                )

            HStack {
                Text("X")
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
                                action == .buttonX ? .yellow : .clear
                            )
                    )
                    .padding(.trailing, 25)

                Text("B")
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
                                action == .buttonB ? .yellow : .clear
                            )
                    )
            }

            Text("A")
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
                            action == .buttonA ? .yellow : .clear
                        )
                )
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
