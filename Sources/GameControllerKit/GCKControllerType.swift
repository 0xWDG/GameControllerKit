//
//  GCKControllerType.swift
//  GameControllerKit
//
//  Created by Wesley de Groot on 2024-08-19.
//  https://wesleydegroot.nl
//
//  https://github.com/0xWDG/GameControllerKit
//  MIT License
//

import Foundation

/// Represents the type of game controller connected.
public enum GCKControllerType {
    /// A DualSense controller (PlayStation 5).
    case dualSense

    /// A DualShock controller (PlayStation 4).
    case dualShock

    /// An Xbox controller.
    case xbox

    /// An Siri Remote controller
    case siriRemote

    /// A generic controller type, for other controllers.
    case generic

    /// Description of the game controller
    public var description: String {
        switch self {
        case .dualSense:
            "DualSense"
        case .dualShock:
            "DualShock"
        case .xbox:
            "Xbox"
        case .siriRemote:
            "Siri Remote"
        case .generic:
            "Genric"
        }
    }
}
