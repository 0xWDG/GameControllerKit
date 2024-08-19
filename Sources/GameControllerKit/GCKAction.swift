//
//  GCKAction.swift
//  GameControllerKit
//
//  Created by Wesley de Groot on 2024-08-19.
//  https://wesleydegroot.nl
//
//  https://github.com/0xWDG/GameControllerKit
//  MIT License
//

import Foundation

/// Represents the names of buttons available on a standard game controller.
public enum GCKAction: Comparable {
    /// The A button, often used for main actions.
    /// ("Cross" on PlayStation Controllers)
    case buttonA

    /// The B button, often used for secondary actions or canceling.
    /// ("Circle" on PlayStation Controllers)
    case buttonB

    /// The X button, typically used for alternative actions.
    /// ("Square" on PlayStation Controllers)
    case buttonX

    /// The Y button, also used for alternative actions or menu navigation.
    /// ("Triangle" on PlayStation Controllers)
    case buttonY

    /// The left shoulder button, usually triggers shoulder actions or item switching.
    /// ("L1" on PlayStation Controllers)
    case leftShoulder

    /// The right shoulder button, similar to the left shoulder in use. ("R1" on PlayStation Controllers)
    case rightShoulder

    /// The left trigger, often used for actions like aiming or braking. ("L2" on PlayStation Controllers)
    case leftTrigger

    /// The right trigger, commonly used for actions such as shooting or accelerating. ("R2" on PlayStation Controllers)
    case rightTrigger

    /// The menu button, typically brings up in-game or app menus. ("Options" on PlayStation Controllers)
    case buttonMenu

    /// The options button, can be used for additional in-game options. ("Share" on PlayStation Controllers)
    case buttonOptions

    /// The home button, often used to exit to the main menu or dashboard. ("PlayStation" on PlayStation Controllers)
    case buttonHome

    /// The directional pad up button.
    case dpadUp

    /// The directional pad down button.
    case dpadDown

    /// The directional pad left button.
    case dpadLeft

    /// The directional pad right button.
    case dpadRight

    /// The left thumbstick click button, used for additional actions.
    case leftThumbstickButton

    /// The right thumbstick click button, similar to the left thumbstick button.
    case rightThumbstickButton

    /// The right thumbstick
    ///
    /// - Parameter x: X-axis
    /// - Parameter y: Y-axis
    case leftThumbstick(x: Float, y: Float)
    // swiftlint:disable:previous identifier_name

    /// The right thumbstick
    ///
    /// - Parameter x: X-axis
    /// - Parameter y: Y-axis
    case rightThumbstick(x: Float, y: Float)
    // swiftlint:disable:previous identifier_name

    /// PlayStation: The touchpad button, which can also act as a clickable button.
    case touchpadButton

    /// PlayStation: The top part of the touchpad,
    /// acting as the up directional input that is touched or pressed by the primary finger.
    case touchpadPrimaryUp

    /// PlayStation: The bottom part of the touchpad,
    /// acting as the up directional input that is touched or pressed by the primary finger.
    case touchpadPrimaryDown

    /// PlayStation: The left part of the touchpad,
    /// acting as the up directional input that is touched or pressed by the primary finger.
    case touchpadPrimaryLeft

    /// PlayStation: The right part of the touchpad,
    /// acting as the up directional input that is touched or pressed by the primary finger.
    case touchpadPrimaryRight

    /// PlayStation: The top part of the touchpad,
    /// acting as the up directional input that is touched or pressed by the secondary finger.
    case touchpadSecondaryUp

    /// PlayStation: The bottom part of the touchpad,
    /// acting as the up directional input that is touched or pressed by the secondary finger.
    case touchpadSecondaryDown

    /// PlayStation: The left part of the touchpad,
    /// acting as the up directional input that is touched or pressed by the secondary finger.
    case touchpadSecondaryLeft

    /// PlayStation: The right part of the touchpad,
    /// acting as the up directional input that is touched or pressed by the secondary finger.
    case touchpadSecondaryRight

    /// Xbox: The paddle 1 button element, which has a P1 label on the back of the controller.
    case paddleButton1

    /// Xbox: The paddle 2 button element, which has a P2 label on the back of the controller.
    case paddleButton2

    /// Xbox: The paddle 3 button element, which has a P2 label on the back of the controller.
    case paddleButton3

    /// Xbox: The paddle 4 button element, which has a P2 label on the back of the controller.
    case paddleButton4

    /// Xbox: The share button on an Xbox Series X|S controller or later.
    case shareButton

    /// None: initial value
    case none
}
