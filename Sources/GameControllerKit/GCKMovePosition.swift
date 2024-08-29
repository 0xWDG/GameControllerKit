//
//  GCKMovePosition.swift
//  GameControllerKit
//
//  Created by Wesley de Groot on 2024-08-19.
//  https://wesleydegroot.nl
//
//  https://github.com/0xWDG/GameControllerKit
//  MIT License
//

import Foundation

/// Moding position of the thumbstick.
public enum GCKMovePosition: Comparable {
    /// The thumbstick position is up
    case up
    // swiftlint:disable:previous identifier_name

    /// The thumbstick position is up - right
    case upRight

    /// The thumbstick position is right
    case right

    /// The thumbstick position is down - right
    case downRight

    /// The thumbstick position is down
    case down

    /// The thumbstick position is down - left
    case downLeft

    /// The thumbstick position is left
    case left

    /// The thumbstick position is up - left
    case upLeft

    /// The thumbstick position is centered
    case centered

    /// The thumbstick position is unknown (usually a phase in between a position and center)
    /// if it keeps being unknown, check if the event you are sending is correct.
    case unknown

    public var arrowRepresentation: String {
        switch self {
        case .up:
            "↑"
        case .upRight:
            "↗"
        case .right:
            "→"
        case .downRight:
            "↘"
        case .down:
            "↓"
        case .downLeft:
            "↙"
        case .left:
            "←"
        case .upLeft:
            "↖"
        case .centered:
            "•"
        case .unknown:
            ""
        }
    }
}
