//
//  GCKController.swift
//  GameControllerKit
//
//  Created by Wesley de Groot on 2024-08-19.
//  https://wesleydegroot.nl
//
//  https://github.com/0xWDG/GameControllerKit
//  MIT License
//

import Foundation
import GameController

/// Represents the names of buttons available on a standard game controller.
///
/// This is a typealias to ``GCController``.
public typealias GCKController = GCController

extension GCKController {
    /// Controller type inferred from the physical input profile.
    public var gckControllerType: GCKControllerType {
        switch physicalInputProfile {
        case is GCDualSenseGamepad:
            .dualSense
        case is GCDualShockGamepad:
            .dualShock
        case is GCXboxGamepad:
            .xbox
        case is GCMicroGamepad:
            .siriRemote
        default:
            .generic
        }
    }

    /// Does the current controller has a touchpad?
    public var hasTouchpad: Bool {
        gckControllerType == .dualSense || gckControllerType == .dualShock
    }

    /// Does the current controller have a touchpad?
    @available(*, deprecated, renamed: "hasTouchpad")
    public var hasTouchPad: Bool {
        hasTouchpad
    }

    /// Does the current controller have paddle buttons?
    public var hasPaddleButtons: Bool {
        physicalInputProfile is GCXboxGamepad
    }
}
