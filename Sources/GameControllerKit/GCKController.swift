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
    /// Does the current controller has a touchpad?
    public var hasTouchPad: Bool {
        if self.physicalInputProfile as? GCDualSenseGamepad != nil {
            return true
        }

        if self.physicalInputProfile as? GCDualShockGamepad != nil {
            return true
        }

        return false
    }

    /// Does the current controller have paddle buttons?
    public var hasPaddleButtons: Bool {
        return self.physicalInputProfile as? GCXboxGamepad != nil
    }
}
